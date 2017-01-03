require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require_relative 'validator'
require 'active_support/inflector'

class SQLObject
  extend Searchable
  extend Associatable
  extend Validation
  include Valid

  def self.columns
    @cols ||= DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
        LIMIT 1
      SQL

    @cols.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column_name|

      define_method(column_name) do
        attributes[column_name]
      end

      define_method("#{column_name.to_s}=".to_sym) do |new_value|
        attributes[column_name] = new_value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ? @table_name : self.name.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    parse_all(data)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.first
    data = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      LIMIT 1
    SQL
    data.empty? ? nil : self.new(data.first)
  end

  def self.last
    data = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      ORDER BY
        id DESC
      LIMIT 1
    SQL
    data.empty? ? nil : self.new(data.first)
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    parse_all(data)[0]
  end

  def self.find_by(search_field)
    search_col_name = search_field.keys.first.to_s
    search_value = search_field.values.first
    data = DBConnection.execute(<<-SQL, search_value)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{search_col_name} = ?
    SQL
    parse_all(data)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      name_sym = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(name_sym)
      send("#{attr_name}=".to_sym, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |column_name|
      send(column_name.to_sym)
    end
  end

  def save!
    id ? update : insert
  end

  private

  def insert
    col_names = self.class.columns.join(", ")
    questions_marks = (["?"] * self.class.columns.length).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{questions_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns.map{|name| "#{name} = ?"}.join(",")
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = ?
    SQL
  end

end
