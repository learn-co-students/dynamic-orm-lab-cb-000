require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
      pragma table_info('#{table_name}')
    SQL
    table_info = DB[:conn].execute(sql)

    columns = []
    table_info.each { |row| columns << row["name"] }
    columns.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def col_names_for_insert
    # self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    table_columns = []
    self.class.column_names.each do |attribute|
      table_columns << attribute.to_s if attribute.to_s != "id"
    end
    table_columns_names = table_columns.join(", ")
  end

  def values_for_insert
    self_values = []
    col_names_for_insert.split(", ").each { |col_name| self_values << "'#{self.send(col_name)}'"}
    "#{self_values.join(", ")}"
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM '#{table_name}'
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)=
  end

  def table_name_for_insert
    self.class.table_name
  end


  def self.find_by(option)
    key, value = option.first
    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE #{key} = '#{value}'
    SQL
    object_instance = DB[:conn].execute(sql)
  end
end
