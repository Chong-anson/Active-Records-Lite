require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'
# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    class_name.constantize 
  end

  def table_name
    # ...
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    @class_name = options[:class_name] || name.to_s.singularize.camelcase 
    @foreign_key = options[:foreign_key] || "#{name.to_s}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions

  def initialize(name, self_class_name, options = {})
    # ...
    @class_name = options[:class_name] || name.to_s.singularize.camelcase 
    @foreign_key = options[:foreign_key] || "#{self_class_name.to_s.downcase}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    option = BelongsToOptions.new(name, options)
    assoc_options
    @belongs[name] = option
    define_method(name) do 
      col = option.send(:foreign_key)
      target_class = option.model_class
      foreign_value = self.attributes[col]
      result = target_class.where({id: foreign_value})
      result.nil? ? nil : result.first
    end 
  end

  def has_many(name, options = {})
    # ...
    option = HasManyOptions.new(name, self, options)
  
    define_method(name) do 
      target_col = option.send(:foreign_key)
      target_class = option.model_class
      id = self.attributes[:id]
      # debugger
      result = target_class.where({target_col => id})
      result.nil? ? [] : result
    end

  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @belongs ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
