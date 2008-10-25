module CouchPotato
  module Persistence
    module Callbacks
      def self.included(base)
        base.extend ClassMethods
        
        base.class_eval do
          def self.callbacks
            @@callbacks ||= {}
            @@callbacks[self.name] ||= {:before_validation_on_create => [], 
              :before_validation_on_update => [], :before_validation_on_save => [], :before_create => [], 
              :after_create => [], :before_update => [], :after_update => [],
              :before_save => [], :after_save => [],
              :before_destroy => [], :after_destroy => []}
          end
        end
      end
      
      private
      
      def run_callbacks(name)
        self.class.callbacks[name].each do |callback|
          self.send callback
        end
      end
      
      module ClassMethods
        def before_validation_on_create(name)
          callbacks[:before_validation_on_create] << name
        end
        
        def before_validation_on_update(name)
          callbacks[:before_validation_on_update] << name
        end
        
        def before_validation_on_save(name)
          callbacks[:before_validation_on_save] << name
        end
        
        def before_create(name)
          callbacks[:before_create] << name
        end
        
        def before_save(name)
          callbacks[:before_save] << name
        end
        
        def before_update(name)
          callbacks[:before_update] << name
        end
        
        def before_destroy(name)
          callbacks[:before_destroy] << name
        end

        def after_update(name)
          callbacks[:after_update] << name
        end
        
        def after_save(name)
          callbacks[:after_save] << name
        end
        
        def after_create(name)
          callbacks[:after_create] << name
        end

        def after_destroy(name)
          callbacks[:after_destroy] << name
        end
      end
    end
  end
end