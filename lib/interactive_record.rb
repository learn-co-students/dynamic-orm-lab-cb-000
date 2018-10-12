require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{self.table_name}')"
    table_info = DB[:conn].execute(sql)
    table_info.collect{|col| col['name']}.compact
  end

  def initialize(data = {})
    data.each{|attr, value| self.send("#{attr}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.collect{|col| col unless col == "id"}.compact.join(", ")
  end

  def values_for_insert
    self.class.column_names.collect{|col| "'#{self.send(col)}'" unless self.send(col).nil?}.compact.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert})
      VALUES (#{self.values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(data)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{data.keys[0]} = ?
    SQL
    DB[:conn].execute(sql, data.values[0])
  end

end
