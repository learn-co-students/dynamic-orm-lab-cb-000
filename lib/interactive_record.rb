require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.column_names
    DB[:conn].results_as_hash = true;
    sql = "PRAGMA table_info('#{table_name}')"
    DB[:conn].execute(sql).map {|column| column["name"]}.compact
  end

  def initialize(options={})
    options.each do |key,value|
      self.send("#{key}=", value)
    end
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|c|c == 'id'}.join(', ')
  end

  def values_for_insert
    self.class.column_names.map{|cn| self.send(cn) ? "'#{send(cn)}'" : nil}.compact.join(', ')
  end

  def save
    if self.id
      update
    else
      sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end
  end

  def update

  end

  def self.find_by(hash)
    sql = "SELECT * FROM #{table_name} WHERE #{hash.keys[0]} = ? LIMIT 1"
    DB[:conn].execute(sql, hash.values[0].to_s)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    row = DB[:conn].execute(sql,name)
  end
  
end