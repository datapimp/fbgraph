require "#{ File.dirname(__FILE__) }/test_helper"

class FacebookGraphAuthorizationTest < Test::Unit::TestCase
  context "a user authorizing this library" do
    setup do
      @client = FacebookGraph::Client.new
      @authorization = @client.authorization
    end
    
    should "be given a url to use to authorize this application to access their profile" do
      assert_not_nil @authorization.authorization_code_uri
    end
    
    should "be given a url to request an access token" do
      assert_not_nil @authorization.access_token_uri
    end
  end
end