require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  def initialize(attr = {})
    attr.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

end
