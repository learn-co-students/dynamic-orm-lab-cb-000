require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        sql = <<-SQL
            PRAGMA table_info (#{self.table_name})
        SQL
        hash_array = DB[:conn].execute(sql)
        col_names = []
        hash_array.each do |column|
            col_names << column["name"]
        end
        col_names.compact
    end

    def initialize(attributes={})
        attributes.each{|attribute, value|
            send("#{attribute}=", value)
        }
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names[1..-1].join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names[1..-1].each do |column|
            value = self.send("#{column}")
            values << "'#{value}'"
        end
        values.join(", ")
    end

    def save
        sql = <<-SQL
            INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})
        SQL
        DB[:conn].execute(sql)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].results_as_hash
        sql = <<-SQL
            SELECT * FROM #{self.table_name} WHERE name = ?
        SQL
        DB[:conn].execute(sql, name)
    end

    def self.find_by(att_hash={})
        key = att_hash.keys[0].to_s
        value = att_hash[att_hash.keys[0]]
        DB[:conn].results_as_hash
        sql = "SELECT * FROM #{self.table_name} WHERE #{key} = #{value}"

        key == "name" ? self.find_by_name(value) :  DB[:conn].execute(sql)
    end

end
