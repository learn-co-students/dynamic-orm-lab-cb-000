require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  # returns the table_name
  def self.table_name
    self.to_s.downcase.pluralize
  end

  # returns an array of column_names
  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{self.table_name}')"
    columns = []
    DB[:conn].execute(sql).each do |col|
      columns << col["name"]
    end

    columns.compact
  end
  
  # initialize attributes dynamically
  def initialize(data={})
    data.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == 'id'}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |data|
      values << "'#{self.send(data)}'" unless send(data) == nil
    end

    values.join(", ")
  end

  # Saves our current instance object and declares our @id attribute after inserting into the table
  def save
    sql ="
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert});"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  # Since this method specifies its finding by name it the name column will be explicit
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = (?);"

    DB[:conn].execute(sql, name)
  end

  # This method accepts a hash as an argument and returns a hash of rows
  def self.find_by(data={})
    data.each do |key, value|
      return DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key.to_s} = '#{value}'")
    end
  end

end
