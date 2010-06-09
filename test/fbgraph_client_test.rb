require 'test_helper'

class FacebookGraphClientTest < Test::Unit::TestCase
  context "the graph client" do
    setup do
      @client = FacebookGraph::Client.new 
    end
    
    should "be able to parse a user object" do
      @object = @client.get("datapimp")
      assert_equal "Jonathan", @object["first_name"]
      assert_equal "Soeder", @object["last_name"]
    end
    
    should "be able to request a friends list" do
    end
  end
end
