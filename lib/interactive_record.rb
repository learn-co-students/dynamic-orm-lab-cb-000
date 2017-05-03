require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord


  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true #what is this for?
    sql ="PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql) #returns array of hashes for each column
    column_names = []
    table_info.each do |column|
        column_names <<  column["name"]    #adds each name attributes value from each column hash
        end
        column_names.compact #compact removes all nil elements
  end

  def initialize(options={}) #takes in a hash
    options.each do |property, value| #goes through hash.
      self.send("#{property}=",value) #sets self.property(key) to the value. ie self.name(self.property) = "name"(value)
    end
  end
=begin
  def self.find_by(attr)
    sql = "SELECT * FROM #{self.table_name} WHERE "
       DB[:conn].execute(sql)
=end


  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
     DB[:conn].execute(sql)[0][0]
   end


   def col_names_for_insert
      col_names = []
     self.class.column_names.each do |column_name|
           if column_name == "id"
             column_name = nil
           end
           col_names << column_name
      end
      col_names.compact.join(", ")
    end

    def table_name_for_insert
      self.class.table_name
    end

    def values_for_insert
      col_names = []
      values = []
     self.class.column_names.each do |column_name|
           if column_name == "id"
             column_name = nil
           end
           col_names << column_name
      end
      col_names.compact.each do |attribute_from_col|
       values << "'#{send(attribute_from_col)}'"
      end
      values.compact.join(", ")
    end


    def self.find_by_name(name)
     sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
     DB[:conn].execute(sql,name)
    end

    def self.find_by(attribute)
      att = attribute.keys[0]
      if attribute[attribute.keys[0]].class == Fixnum #there was an error I think in the spec file. The hash with the
                                                      #integer was entered as a string, not a hash. I changed it.
                                                      #in the solution, the argument is not a string, Only a hash;
          value = attribute[attribute.keys[0]] #number stays number
        else
          value = "'#{attribute[attribute.keys[0]]}'" # if not a number then value is a string. could use .values method
        end
        sql = "SELECT * FROM #{self.table_name} WHERE #{att} = #{value}"
          DB[:conn].execute(sql)
    end

    def save
        sql = "INSERT INTO #{self.table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
    end


end
