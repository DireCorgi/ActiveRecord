require_relative 'searchable'
require 'active_support/inflector'

class Validator
  attr_reader :col_names, :presence, :length, :uniqueness, :errors

  def initialize(col_names, options)
    @col_names = col_names
    @presence = options[:presence] ? options[:presence] : nil
    @length = options[:length] ? options[:length] : nil
    @uniqueness = options[:uniqueness] ? options[:uniqueness] : nil
    @errors = []
  end

  def is_valid?(sql_object)
    verify_validations(sql_object)
    return errors.empty?
  end

  private

  attr_writer :errors

  def blank?(value)
    value == nil || value == ""
  end

  def verify_validations(sql_object)
    self.errors = []
    col_names.each do |col_name|
      presence?(sql_object.send(col_name), col_name)
      length?(sql_object.send(col_name), col_name)
      uniqueness?(sql_object.send(col_name), sql_object.send(:id), sql_object.class.table_name, col_name)
    end
  end

  def presence?(value, col_name)
    return unless presence
    if blank?(value)
      errors.push("#{col_name} cannot be blank")
    end
  end

  def length?(value, col_name)
    return unless length
    max_length = length[:maximum]
    min_length = length[:minimum]
    if max_length && value.length > max_length
      errors.push("#{col_name} is greater than the max length of #{max_length}")
    end
    if min_length && value.length < min_length
      errors.push("#{col_name} is less than the min length of #{min_length}")
    end
  end

  def uniqueness?(value, id, table_name, col_name)
    return unless uniqueness
    id ||= 0
    data = DBConnection.execute(<<-SQL, value, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        name = ? AND id != ?
    SQL
    errors.push("#{value} already exists in the DB") unless data.empty?
  end

end

module Validation

  def validations
    @validations ||= []
  end

  def validates(*col_names, options)
    validations.push(Validator.new(col_names, options))
  end

end

module Valid

  def validations
    self.class.validations
  end

  def valid?
    valid = true
    validations.each do |validation|
      valid = false unless validation.is_valid?(self)
    end
    return valid
  end

  def errors
    object_errors = []
    validations.each do |validation|
      object_errors.concat(validation.errors)
    end
    object_errors
  end

end
