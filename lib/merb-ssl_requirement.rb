# make sure we're running inside Merb
if defined?(Merb::Plugins)

  module Merb
    module ControllerMixin
      module SslRequirement
        def self.included(base)
          base.send(:extend, ClassMethods)
          base.send(:include, InstanceMethods)
          base.send(:before, :ensure_proper_protocol)
        end

        module ClassMethods
          attr_accessor :ssl_required_actions
          attr_accessor :ssl_allowed_actions
          # Specifies that the named actions requires an SSL connection to be 
          # performed (which is enforced by ensure_proper_protocol).
          def ssl_required(*actions)
            self.ssl_required_actions = actions
          end

          def ssl_allowed(*actions)
            self.ssl_allowed_actions = actions
          end
        end
        
        module InstanceMethods
          
          protected
          # Returns true if the current action is supposed to run as SSL
          def ssl_required?
            (self.class.ssl_required_actions || []).include?(action_name.to_sym)
          end

          def ssl_allowed?
            (self.class.ssl_allowed_actions || []).include?(action_name.to_sym)
          end

          private
          def ensure_proper_protocol
            return true if ssl_allowed?

            if ssl_required? && !request.ssl?
              throw :halt, proc {|c| c.redirect "https://" + request.host + request.path}
              return false
            elsif request.ssl? && !ssl_required?
              throw :halt, proc {|c| c.redirect "http://" + request.host + request.path}
              return false
            end
          end
            
        end

      end

    end
  end
  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:merb_ssl_requirement] = {
    :chickens => false
  }
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
  Merb::Plugins.add_rakefiles "merb-ssl_requirement/merbtasks"
end