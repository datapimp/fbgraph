require "#{ File.dirname(__FILE__) }/test_helper"
require 'socket'

class FacebookGraphTunnelTest < Test::Unit::TestCase
  context "the callback server" do
    setup do
      # TODO - use testing framework to only have one setup block per context
      # e.g. fast context for shoulda for rails
      
      @port = 10000 + ( rand * 10**4 )
      @server = FacebookGraph::Callback::Server.new :port => @port.to_i
      sleep 1
    end

    should "provide access to the tunnel" do
      assert_not_nil @server.tunnel
      assert @server.use_tunnel?, "The server should be configured to use the tunnel"
      assert_not_nil @server.tunnel.callback_uri

      puts "Attempting Tunneled GET Request at #{ @server.tunnel.callback_uri }"
      @tunneled_get = JSON.parse( RestClient.get(@server.tunnel.callback_uri + "?from_tunnel") )
      assert @tunneled_get["success"], "Should be able to access the callback server over the tunnel"
      assert_equal "GET", @tunneled_get["method"], "Should be able to access the callback server over the tunnel"
    end
    
    teardown do
      @server.shutdown
    end  
  end
end

