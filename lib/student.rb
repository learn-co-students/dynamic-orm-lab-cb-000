require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def self.find_by(hash)
    col_name = hash.keys[0].to_s.sub(/:/,"")
    val = hash.values[0].is_a?(String) ? "'#{hash.values[0]}'" : hash.values[0]
    sql = "SELECT * FROM #{self.table_name} WHERE #{col_name} = #{val}"
    DB[:conn].execute(sql)
  end
end
