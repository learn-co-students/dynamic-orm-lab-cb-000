require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord


  def initialize (options = {})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end


  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info(#{self.table_name})"
    table_info = DB[:conn].execute(sql)
    columns = []
    table_info.each do |col_info|
      columns << col_info["name"]
    end
    columns.compact 
  end


  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = [] 
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil? 
    end
    values.join(", ")
  end


  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0].values[0]
    self
  end


  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name)
  end
  

  def self.find_by(attributes)

    values_to_search = []
    attributes.each do |key, value|
      values_to_search << "#{key} = '#{value}'"
    end
    sql = "SELECT  * FROM #{self.table_name} WHERE  #{values_to_search.join(",")} LIMIT 1"
    DB[:conn].results_as_hash = true
    DB[:conn].execute(sql)
  end
end
