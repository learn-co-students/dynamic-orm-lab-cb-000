require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = <<-SQL
      PRAGMA table_info('#{self.table_name}')
    SQL
    DB[:conn].execute(sql).map do |row|
      row["name"]
    end.compact
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end
  def last_insert_rowid
    DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = last_insert_rowid
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
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(', ')
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = '#{name}'
    SQL
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    key = attribute.keys.first
    value = attribute.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM '#{self.table_name}' WHERE #{key} = #{formatted_value}"
    DB[:conn].execute(sql)
  end

end
