require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...

    through_option = @belongs[through_name]
    define_method(name) do 
      # debugger
      through_foreign_key = through_option.send(:foreign_key)
      through_object_id = self.attributes[through_foreign_key]
      through_object = through_option.model_class.where(id: through_object_id)

      source_option = through_option.model_class.assoc_options[source_name]
      source_foreign_id = source_option.send(:foreign_key)
      source_id = through_object.first.attributes[source_foreign_id]
     
      result = source_option.model_class.where(id: source_id)
      result.nil? ? nil : result.first 
    end 
  end
end
