require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |column|
        column_names << column["name"]
    end
    column_names.compact
  end
  def initialize(options = {})
    options.each do |property, value|
        self.send("#{property}=", value)
    end
  end
  def table_name_for_insert
    Student.table_name
  end
  def col_names_for_insert
    array = Student.column_names
    array.delete("id")
    array.join(", ")
  end
  def values_for_insert
    return "'#{@name}', '#{@grade}'"
  end
  def save
    sql = "INSERT INTO #{Student.table_name} (name, grade) VALUES (?, ?)"
    DB[:conn].execute(sql, [self.name, self.grade])
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{Student.table_name}")[0]["last_insert_rowid()"]
  end
  def self.find_by_name(name)
    sql = <<-SQL
        SELECT *
        FROM #{Student.table_name}
        WHERE #{Student.table_name}.name = '#{name}'
    SQL
    DB[:conn].execute(sql)
  end
  def self.find_by(input_hash)
    key = input_hash.keys[0]
    value = input_hash[key.to_sym]
    sql = <<-SQL
        SELECT *
        FROM #{self.table_name}
        WHERE #{self.table_name}.#{key} = '#{value}'
    SQL
    DB[:conn].execute(sql)
  end
end