require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

	def initialize(options = {}) #3
		options.each do |attr, value|
			self.send("#{attr}=", value)
		end
	end

	def self.table_name #1
		self.to_s.downcase.pluralize
	end

	def self.column_names #2
		DB[:conn].results_as_hash = true

		sql = "pragma table_info(#{table_name})"
		table_info =  DB[:conn].execute(sql)

		column_names = []

		table_info.each do |row|
			column_names << row["name"]
		end
		column_names.compact
	end

	def table_name_for_insert #5
		self.class.table_name
	end

	def col_names_for_insert #6
		self.class.column_names.delete_if {|col| col == "id"}.join(", ")
	end

	def values_for_insert  #7
		values = []
		self.class.column_names.each do |col_name|
			values << "'#{send(col_name)}'" unless send(col_name).nil?
		end
		values.join(", ")
	end

	def save #8
	  sql = <<-SQL 
	  INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
	  VALUES (#{values_for_insert})
	  SQL

	  DB[:conn].execute(sql)

	  @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
	end

	def self.find_by(attribute)
		sql = "SELECT * FROM #{table_name} WHERE #{attribute.keys.join} = '#{attribute.values.first}'"
		DB[:conn].execute(sql)
	end

	def self.find_by_name(name)
		sql = "SELECT * FROM #{table_name} WHERE name = '#{name}'" 
		DB[:conn].execute(sql)
	end
  
end

#ORDER OF METHODS TO CREATE.....
# 1. self.table_name
# 2. self.column_names
# 3. initialize
# 4. set attr_accessor of Class
# 5. table_name_for_insert
# 6. column_name_for_insert
# 7. values_for_insert
# 8. save