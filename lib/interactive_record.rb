require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def initialize(options = {})
    options.each {|k,v| self.send("#{k}=",v)}
  end

  def col_names_for_insert
    self.class.column_names.find_all {|col| col != "id"}.join(", ")
  end

  def values_for_insert
    columns = self.class.column_names.find_all {|col| col != "id"}
    
    Array.new.tap do |a|    
      columns.map {|k| a << "'#{self.send("#{k}")}'"}
    end.join(", ")
  end

  def table_name_for_insert
    self.class.table_name
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) 
          VALUES (#{self.values_for_insert})"
  
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end  

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name=?"
    DB[:conn].execute(sql, name)
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    table_info = DB[:conn].execute("PRAGMA table_info(#{self.table_name})")

    Array.new.tap do |a|
    table_info.each {|column| a << column["name"] }
    end
  end

  def self.find_by(hash)
    sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys[0].to_s}=?"
    DB[:conn].execute(sql, hash.values[0])
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end
  
end