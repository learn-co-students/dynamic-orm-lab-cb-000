require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def initialize(attributes = {})
    attributes.each do |key,value|
      self.send("#{key}=", value)
    end
  end

  def self.column_names
    #set the db conn to return as hash
    DB[:conn].results_as_hash = true

    #use praga query to get list of table columns
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)

    #table info is a hash, we are looking for {:name} for column names
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    #we have array of column names but we call .compact to get rid of any nil values
    column_names.compact
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    #need to remove id from column_names and join with ,
    self.class.column_names.delete_if{|col| col == "id"}.join(', ')
  end

  def values_for_insert
    #here we have to loop through column_names called send to get value back from attribute= call
    values = []
    self.class.column_names.each do |col|
      #we need values to be surrounded by ' ' and value can't be nil
      values << "'#{send(col)}'" unless send(col).nil?
    end
    #return the values joined by ,
    values.join(', ')
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    #have to use self.table_name method call here because of class scope
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql,name)
  end

  def self.find_by(attribute)
    #attribute is a hash,
    #select * FROM {table_name} where attribute = attribute.value
    value = attribute.values.first
    #we test if it is a fixnum , else we have to evaluate it
    fm_value = value.class == Fixnum ? value : "#{value}"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first} = ?"
    #safer to not directly eval code in sql statement
    DB[:conn].execute(sql,fm_value)
  end

end
