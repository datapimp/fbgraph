require 'test_helper'

class FacebookGraphTest < Test::Unit::TestCase
  context "the callback server" do
    setup do
      @server = FacebookGraph::Callback::Server.new
    end
    
    should "respond to requests" do
      @response = JSON.parse(RestClient.get "http://localhost:8000/callback")
      assert @response["success"]
      assert_equal "GET", @response["method"]
      
      @response = JSON.parse(RestClient.post "http://localhost:8000/callback", {})
      assert @response["success"]
      assert_equal "POST", @response["method"]
    end
    
    teardown do
      @server.kill
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