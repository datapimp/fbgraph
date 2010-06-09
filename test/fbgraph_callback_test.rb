require "#{ File.dirname(__FILE__) }/test_helper"

class FacebookGraphCallbackTest < Test::Unit::TestCase
  class << self
    attr_accessor :server, :last_test
  end
  
  context "the callback server" do
    setup do
      @server ||= self.class.server ||= FacebookGraph::Callback::Server.new
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
      
      self.class.last_test = true
    end
    
    teardown do
      @server.shutdown if self.class.last_test
    end
  end
end