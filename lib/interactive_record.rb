require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names # returns an ARRAY <- important
        sql = "PRAGMA table_info('#{table_name}')"
        ((DB[:conn].execute(sql)).map {|row| row["name"]}).compact
    end
        # formerly
        #               DB[:conn].results_as_hash = true #why? we want an array back anyway
        #               sql = "pragma table_info('#{table_name}')"
        #               table_info = DB[:conn].execute(sql)
        #               column_names = []
        #               table_info.each do |row|
        #                   column_names << row["name"]
        #               end
        #               column_names.compact # sandwiching BAD
        #               end

    def initialize(options={})
        options.each do |property, value|
            self.send("#{property}=", value)
            #the attr accessor creation for each class goes in THAT CLASS
        end
    end

    def table_name_for_insert #self.class turns table_name from a class method to an instance method
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
        # we don't want ID, that stays the same no matter what. then comma separated.
    end

    def values_for_insert
        (self.class.column_names.map {|col_name| 
        "'#{send(col_name)}'" unless send(col_name).nil?}).compact.join(", ") #compact to get rid of the nil before joining
        # Formerly
        # values = []
        # self.class.column_names.each do |col_name| #why not collect?
        #     binding.pry
        #     values << "'#{send(col_name)}'" unless send(col_name).nil?
        # end
        # binding.pry
        # values.join(", ")
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name) #for this table only
        sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
        DB[:conn].execute(sql, name)
    end

    def self.find_by(attrib) #for this table only
        sql = "SELECT * FROM #{self.table_name} WHERE #{attrib.keys.first.to_s} = '#{attrib.values.first}'"
        # attribute keys are symbols, need to be strings
        # values is always in quotes, and we are using string interpolation anyway
        DB[:conn].execute(sql)
    end
  
end