require_relative "../config/environment.rb"
require_relative 'interactive_record.rb'
require 'active_support/inflector'


class Student < InteractiveRecord

  # Create our attribute dynamically
  self.column_names.each do |col|
    attr_accessor col.to_sym
  end

end
