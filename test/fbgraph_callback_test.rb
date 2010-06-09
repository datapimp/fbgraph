require "#{ File.dirname(__FILE__) }/test_helper"

class FacebookGraphCallbackTest < Test::Unit::TestCase
  context "the callback server" do
    setup do
      @server = FacebookGraph::Callback::Server.new :port => 8000
    end
    
    should "provide a callback uri" do
      assert_not_nil @server.callback_uri, "Should provide a callback URI"
    end
    
    should "respond to requests" do
      @get = JSON.parse(RestClient.get @server.callback_uri)
      assert @get["success"]
      assert_equal "GET", @get["method"]
      
      @post = JSON.parse(RestClient.post @server.callback_uri, {})
      assert @post["success"]
      assert_equal "POST", @post["method"]
    end
    
    teardown do
      @server.shutdown
    end
  end
end