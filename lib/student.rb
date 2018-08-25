require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
  
  def self.find_by(column)
    row = {}
    column.each do |x,y|
      sql = "SELECT * FROM #{self.table_name} WHERE #{x} = '#{y}'"
     row =  DB[:conn].execute(sql)
     end
    row
  end
  

end
