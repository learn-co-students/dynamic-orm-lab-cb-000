require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    table_info = DB[:conn].execute("pragma table_info(#{table_name});")

    column_names = table_info.collect do |column|
      column["name"]
    end.compact
  end

  def initialize(options={})
    options.each do |prop, value|
      self.send("#{prop}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    col_names = self.class.column_names
    col_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end

  def values_for_insert
    self.class.column_names.collect do |col_name|
      send(col_name).nil? ? nil : "'#{send(col_name)}'"
    end.compact.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    self
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE name = '#{name}';
    SQL

    DB[:conn].execute(sql)
  end

  def self.find_by(options)
    column = options.keys[0]
    if options.values[0].is_a? String
      value = "'#{options.values[0]}'"
    else
      value = options.values[0]
    end

    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{column} = #{value};
    SQL

    DB[:conn].execute(sql)
  end
end
