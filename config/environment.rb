require 'sqlite3'
require 'pry'

DB = {:conn => SQLite3::Database.new("db/students.db")}
DB[:conn].execute("DROP TABLE IF EXISTS students")

sql = File.read('sql/create_students_table.sql')

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true
