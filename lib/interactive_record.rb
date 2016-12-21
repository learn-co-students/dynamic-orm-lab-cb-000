require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = <<-SQL
      PRAGMA table_info('#{self.table_name}')
    SQL
    DB[:conn].execute(sql).map do |result|
      result["name"]
    end.compact
  end

  def last_row_id
    DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def save
    if self.id
      self.update
    else
      self.insert
      @id = self.last_row_id
    end
    self
  end

  def insert
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
  end

  def table_name_for_insert
    self.class.table_name
  end
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == 'id'}.join(', ')
  end

  def values_for_insert
    self.col_names_for_insert.split(', ').map do |col|
      "'#{self.send(col)}'"
    end.compact.join(', ')
  end

  def update
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new(row)
    end.first
  end

  def self.find_by(attribute)
    key = attribute.keys.first
    value = attribute.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{key} = "#{formatted_value}"
      LIMIT 1
    SQL
    binding.pry
    DB[:conn].execute(sql).map do |row|
      self.new(row)
    end.first
  end

end
