require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    table_info = DB[:conn].execute("PRAGMA table_info('#{self.table_name}')")
    column_names = []

    table_info.each do |hash|
      column_names << hash['name']
    end
  #  binding.pry

    column_names.compact
  end



  def initialize(options = {})
    options.each{|property,value|self.send("#{property}=", value)}
  end



  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?",name)
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
     values.join(", ")
  end

  def save
    DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})")
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
  end

  def self.find_by(hash)
    key = hash.keys[0].to_s
    value = hash.values[0]
    #binding.pry
    DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'")

  end

  def col_names_for_insert
    cols = self.class.column_names.delete_if{|col|col=='id'}.join(", ")
  end



end
