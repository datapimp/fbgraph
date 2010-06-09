require "#{ File.dirname(__FILE__) }/test_helper"

class FacebookGraphTest < Test::Unit::TestCase
  context "the callback server" do
    setup do
      @server = FacebookGraph::Callback::Server.new
    end
    
    should "respond to requests" do
      @get = JSON.parse(RestClient.get @server.callback_uri)
      assert @get["success"]
      assert_equal "GET", @get["method"]
      
      @post = JSON.parse(RestClient.post @server.callback_uri, {})
      assert @post["success"]
      assert_equal "POST", @post["method"]
      
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