require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    col_names = []
    table_info = DB[:conn].execute(sql)
    table_info.each do |col|
      col_names << col["name"]
    end
    col_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    #get table name from self.table_name? and return it
    # Important to include self.class. to call correctly
    self.class.table_name
  end

  def col_names_for_insert
    #get column names and return in the correct format (what format?)
    #gets values, but not formatted correctly.  Include doesn't find them.
    #So probably they should be in an array, but I think they are.
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    # binding.pry

  end

  def values_for_insert
    # describe '#values_for_insert' do
    #   it 'formats the column names to be used in a SQL statement' do
    #     expect(new_student.values_for_insert).to eq("'Sam', '11'")
    #   end
    # end

    #So take values and join or something
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
    # binding.pry
  end

  def save
    #Instance method to insert data into db; saves the student to the db
    # write sql query and then execute with methods as variables
    sql = "INSERT INTO  #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    #expect id from save
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    # expect(Student.find_by_name("Jan")).to eq([{"id"=>1, "name"=>"Jan", "grade"=>10, 0=>1, 1=>"Jan", 2=>10}])
    # returns student from db
    # create sql query

    sql = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE name = ?
    LIMIT 1
    SQL
    DB[:conn].execute(sql, name)
  end

  def self.find_by(row)
    # expect(Student.find_by({name: "Susan"})).to eq([{"id"=>1, "name"=>"Susan", "grade"=>10, 0=>1, 1=>"Susan", 2=>10}])
    # binding.pry
    sql = <<-SQL
    SELECT *
    FROM #{self.table_name}
    WHERE #{row.keys[0]} = ?
    LIMIT 1
    SQL
    DB[:conn].execute(sql, row.values[0])
  end

end
