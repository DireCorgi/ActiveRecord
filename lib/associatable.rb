require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end

end

class BelongsToOptions < AssocOptions

  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] ?  options[:foreign_key] : "#{name}_id".to_sym
    @primary_key = options[:primary_key] ? options[:primary_key]  : :id
    @class_name = options[:class_name] ? options[:class_name] : name.to_s.singularize.capitalize
  end

end

class HasManyOptions < AssocOptions

  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] ?  options[:foreign_key] : "#{self_class_name.to_s.downcase}_id".to_sym
    @primary_key = options[:primary_key] ? options[:primary_key]  : :id
    @class_name = options[:class_name] ? options[:class_name] : name.to_s.singularize.capitalize
  end

end

module Associatable

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      model = options.model_class
      foreign_key_val = send(options.foreign_key)
      model.where(options.primary_key => foreign_key_val).first
    end

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name,  options)

    define_method(name) do
      model = options.model_class
      primary_key_vals = send(options.primary_key)
      model.where(options.foreign_key => primary_key_vals)
    end

  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_opts = self.class.assoc_options[through_name]
      source_opts = through_opts.model_class.assoc_options[source_name]
      foreign_key_val = send(through_opts.foreign_key)

      data = DBConnection.execute(<<-SQL, foreign_key_val)
        SELECT
          #{source_opts.table_name}.*
        FROM
          #{through_opts.table_name}
        JOIN
          #{source_opts.table_name}
          ON #{through_opts.table_name}.#{source_opts.foreign_key}
          = #{source_opts.table_name}.#{source_opts.primary_key}
        WHERE
          #{through_opts.table_name}.#{through_opts.primary_key} = ?
      SQL
      source_opts.model_class.new(data.first)
    end

  end

end
