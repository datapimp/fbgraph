require "#{ File.dirname(__FILE__) }/test_helper"
require 'socket'

class FacebookGraphCallbackTest < Test::Unit::TestCase
  context "the callback server" do
    setup do
      # TODO - use testing framework to only have one setup block per context
      # e.g. fast context for shoulda for rails
      
      @port = 10000 + ( rand * 10**4 )
      @server = FacebookGraph::Callback::Server.new :port => @port.to_i
      sleep 1
    end
    
    should "instantiate itself and listen on the specified port" do
      assert_not_nil @server
      assert_nothing_raised do
        @connection = TCPSocket.open("localhost",@port.to_i)
      end
      
    end
    
    should "provide a callback uri" do
    #  assert_not_nil @server.callback_uri, "Should provide a callback URI"
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