require "#{ File.dirname(__FILE__) }/test_helper"

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
    
    should "not be able to request a friends list without authorization" do
      assert_raise RestClient::InternalServerError do
        @client.get("datapmp/friends")
      end
    end
  end
end
