require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
      PRAGMA table_info(#{table_name})
    SQL

    column_names = []
    DB[:conn].execute(sql).each do |column|
      column_names << column["name"]
    end
    column_names
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == 'id'}.join(', ')
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{self.send(col)}'" unless self.send(col) == nil
    end
    values.join(', ')
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(a_name)
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE name = ?
    SQL
    DB[:conn].execute(sql, a_name)
  end

  def self.find_by(attr)
    sql = <<-SQL
      SELECT * FROM #{table_name} WHERE #{attr.keys[0]} = ?
    SQL
    DB[:conn].execute(sql, attr.values[0])
  end
end
