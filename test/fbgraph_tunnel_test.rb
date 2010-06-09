require "#{ File.dirname(__FILE__) }/test_helper"

class FacebookGraphTunnelTest < Test::Unit::TestCase
  context "the callback server" do
    setup do
      unless File.exists?( File.dirname(__FILE__) + '/../config/fbgraph_client.yaml' )
        raise "You need to generate a configuration file for testing purposes.  See the README"
      end
      
      @server = FacebookGraph::Callback::Server.new
    end
    
    should "provide access to the tunnel" do
      assert_not_nil @server.tunnel
      assert @server.use_tunnel?, "The server should be configured to use the tunnel"
    end
  
    should "provide a valid uri for callback" do
      assert_not_nil @server.tunnel.callback_uri
      assert @server.tunnel.callback_uri.match( VALID_URI_REGEX ),
        "Server should provide a valid URI"
    end

    should "respond to tunneled requests" do
      if @server.use_tunnel?
        @tunneled_get = JSON.parse( RestClient.get(@server.tunnel.callback_uri + "?from_tunnel") )
        assert @tunneled_get["success"], "Should be able to access the callback server over the tunnel"
        assert_equal "GET", @tunneled_get["method"], "Should be able to access the callback server over the tunnel"
      end
    end
    
    teardown do
      @server.shutdown
    end
  end
end
