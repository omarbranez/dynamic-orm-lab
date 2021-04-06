require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
#size of keys without ID, .times.collect{"?"}.join(",")
class Student < InteractiveRecord

    self.column_names.each do |col_name|
        attr_accessor col_name.to_sym
    end
    
end
