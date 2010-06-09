require "#{ File.dirname(__FILE__) }/test_helper"

class FacebookGraphAuthorizationTest < Test::Unit::TestCase
  context "a user authorizing this library" do
    setup do
      @client = FacebookGraph::Client.new
      @authorization = @client.authorization
    end
    
    should "be given a url to use to authorize this application to access their profile" do
      assert_not_nil @authorization.application_authorization_code
    end
  end
end