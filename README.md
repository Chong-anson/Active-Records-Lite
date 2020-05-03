# Active-Records-Lite
A lite version of Active Record(ORM) - mapping SQL databases data into Ruby objects

### Using metaprogramming 
```
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name| 
      define_method(name) {self.instance_variable_get("@#{name}")}
      define_method("#{name}=") { |val| self.instance_variable_set("@#{name}", val)}
    end 
  end
```

### Mapping ActiveRecord association 
```
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
  ```
