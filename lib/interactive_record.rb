require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    # self.class.to_s.downcase.pluralize
    "#{self.to_s.downcase}s"
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
    table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
    column_names = []
    table_info.each do |row|
      column_names << row['name']
    end
    # Remove nil values
    column_names.compact
  end 

  def self.find_by_name(name)
    sql = <<-SQL
          SELECT * FROM #{self.table_name}
          WHERE name = '#{name}'
          SQL
    DB[:conn].execute(sql)
  end
  
  # INSTANCE METHODS
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    # We must exclude the id column !!
    self.class.column_names.delete_if {|row| row == 'id'}.join(', ')
  end

  def values_for_insert
    values = []
    # We call on instance the col names
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
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
  
  def self.find_by(attribute_hash)
    value = attribute_hash.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
    DB[:conn].execute(sql)
  end
  
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end


end