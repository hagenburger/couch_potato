module CouchPotato
  module Persistence
    class SimpleProperty  #:nodoc:
      attr_accessor :name, :type
      
      def initialize(owner_clazz, name, options = {})
        self.name = name
        self.type = options[:type]
        
        define_accessors accessors_module_for(owner_clazz), name, options
      end
      
      # def build(object, json)
      #   value = json[name.to_s] || json[name.to_sym]
      #   typecast_value =  if type
      #                         type.json_create value
      #                       else
      #                         value
      #                       end
      #   object.send "#{name}=", typecast_value
      # end
      
      def build(object, json)
        value = json[name.to_s] || json[name.to_sym]
        typecast_value =  if type
                            type.json_create value
                          else
                            build_value(value)
                          end
        object.send "#{name}=", typecast_value
      end
      
      def build_value(value)
        if value.is_a?(Hash)
          build_hash(value)
        elsif value.is_a?(Array)
          build_array(value)
        else
          value
        end
      end
      
      def build_array(array)
        array.collect do |value|
          build_value(value)
        end
      end
    
      def build_hash(hash)
        hash.symbolize_keys!
        if hash[:ruby_class]
          klass = eval(hash.delete(:ruby_class))
          klass.new(hash)
        else
          hash.each_pair do |key, value|
            hash[key] = build_value(value)
          end
          hash
        end
      end

      def dirty?(object)
        object.send("#{name}_changed?")
      end
      
      def save(object)
        
      end
      
      def destroy(object)
        
      end
      
      def serialize(json, object)
        json[name] = object.send name
      end
      
      private
      
      def accessors_module_for(clazz)
        unless clazz.const_defined?('AccessorMethods')
          accessors_module = clazz.const_set('AccessorMethods', Module.new) 
          clazz.send(:include, accessors_module)
        end
        clazz.const_get('AccessorMethods')
      end
      
      def define_accessors(base, name, options)
        base.class_eval do
          attr_reader "#{name}_was"

          define_method "#{name}" do
            value = self.instance_variable_get("@#{name}")
            if value.blank? && options[:default]
              default = clone_attribute(options[:default])
              self.instance_variable_set("@#{name}", default)
              default
            else
              value
            end
          end
          
          define_method "#{name}=" do |value|
            self.instance_variable_set("@#{name}", value)
          end
          
          define_method "#{name}?" do
            !self.send(name).nil? && !self.send(name).try(:blank?)
          end
          
          define_method "#{name}_changed?" do
            !self.instance_variable_get("@#{name}_not_changed") && self.send(name) != self.send("#{name}_was")
          end
          
          define_method "#{name}_not_changed" do
            self.instance_variable_set("@#{name}_not_changed", true)
          end
        end
      end
    end
  end
end
