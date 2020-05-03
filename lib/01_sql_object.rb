require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.
require 'byebug'
class SQLObject
  def self.columns
    # ...
    return @columns unless @columns.nil?
    result = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      "#{table_name}" 
    SQL
    @columns = result.first.map { |ele| ele.to_sym}
  end

  def self.finalize!
    self.columns.each do |name| 
      define_method(name) { self.instance_variable_get("@#{name}")}
      define_method("#{name}=") { |val| self.instance_variable_set("@#{name}", val) }
      define_method(name) { self.attributes["#{name}".to_sym]}
      define_method("#{name}=") { |val| self.attributes[name] = val }
    end 
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name ||= self.to_s.tableize
  end

  def self.all
    # ... 
    @all_rows = DBConnection.execute(<<-SQL)
    SELECT 
      #{table_name}.*
    FROM 
      #{table_name}
    SQL
    self.parse_all(@all_rows)
  end

  def self.parse_all(results)
    # ...
    result = [] 
    results.each do |row| 
      result << self.new(row)
    end 
    result 
  end

  def self.find(id)
    # ...
    result = DBConnection.execute(<<-SQL, id)
    SELECT 
      *
    FROM 
      #{table_name} 
    WHERE 
      id = ? 
    SQL
    return nil if result.empty? 
    self.new(result.first)
  end

  def initialize(params = {})
    # ...
    self.class.finalize!

    params.each do | col, val | 
      col_sym = col.to_sym
      raise "unknown attribute '#{col}'" unless self.class.columns.include?(col_sym)
      self.send("#{col_sym}=", val)
    end 
  end

  def attributes
    # ...
    @attributes ||= {} 
  end

  def attribute_values
    # ...
    self.class.columns.map { |method| self.send(method)}
  end

  def insert
    # ...
    col_names = self.class.columns.join(",")
    question_marks = ["?"] * (self.class.columns.length)
    
    question_marks = question_marks.join(",")

    values = attribute_values

    
    DBConnection.execute(<<-SQL, *values)
    INSERT INTO
    #{self.class.table_name} (#{col_names})
    VALUES
    (#{question_marks})
    SQL
    
    @attributes[:id] = self.class.all.length 
    # debugger 
  end

  def update
    # ...
    col_names = self.class.columns.map { |col| "#{col} = ?"}.join(",")
    values = attribute_values 
    id = self.send(:id) 

    DBConnection.execute(<<-SQL, *values, id)
    UPDATE
      #{self.class.table_name}
    SET
      #{col_names}
    WHERE
      id = ?
    SQL
    
  end

  def save
    # ...
    # @all_rows = self.class.all 
    id = self.send(:id)
    # debugger
    if id.nil? 
      self.send("id=", nil)
      self.insert
    else 
      self.update 
    end 
  
  end
end
