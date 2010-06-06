require 'test_helper'

class FacebookGraphTest < Test::Unit::TestCase
  context "the callback server" do
    setup do
      @server = FacebookGraph::Callback::Server.new
    end
    
    should "respond to requests" do
      @get = JSON.parse(RestClient.get "http://localhost:8000/callback")
      assert @get["success"]
      assert_equal "GET", @get["method"]
      
      @post = JSON.parse(RestClient.post "http://localhost:8000/callback", {})
      assert @post["success"]
      assert_equal "POST", @post["method"]
      
      @tunneled_get = JSON.parse( RestClient.get(@server.tunnel.callback_uri + "?from_tunnel") )
      assert @tunneled_get["success"], "Should be able to access the callback server oer the tunnel"
      assert_equal "GET", @tunneled_get["method"], "Should be able to access the callback server over the tunnel"
    end
    
    teardown do
      @server.shutdown
    end
  end

  context "the graph client" do
    setup do
      @client = FacebookGraph::Client.new
    end
    
    should "be able to parse a user object" do
      @object = @client.get("datapimp")
      assert_equal "Jonathan", @object["first_name"]
      assert_equal "Soeder", @object["last_name"]
    end
  end
end