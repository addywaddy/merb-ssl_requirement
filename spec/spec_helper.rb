$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'merb-core'
require 'merb_ssl_requirement'

Spec::Runner.configure do |config|
  config.include(Merb::Test::ControllerHelper)
end

class Merb::Controller; end