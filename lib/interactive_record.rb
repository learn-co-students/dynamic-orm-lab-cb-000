require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  # Creates a downcased, plural table name based on the Class name
  def self.table_name
    self.to_s.downcase.pluralize
  end

  # Returns an array of SQL column names
  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)

    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact
  end

  # Creates attr_accessors for each column name from database
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(attributes = {})
    attributes.each do |attribute, key|
      self.send("#{attribute}=", key)
    end
  end

  # Saves instance attributes to database and updates the object's id
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  # Returns the column names that will be used to insert values into database
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  # Formats the column names to be used in a SQL statement
  def values_for_insert
    values = []

    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end

    values.join(", ")
  end

  # Returns the table name
  def table_name_for_insert
    self.class.table_name
  end

  # Finds a row by name
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  # Finds a row by the attribute passed into the method
  def self.find_by(attribute)
    column = attribute.keys[0]
    value = attribute[column]

    sql = "SELECT * FROM #{self.table_name} WHERE #{column.to_s} = '#{value}'"
    DB[:conn].execute(sql)
  end
end
