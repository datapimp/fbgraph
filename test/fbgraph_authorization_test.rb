require "#{ File.dirname(__FILE__) }/test_helper"

class FacebookGraphAuthorizationTest < Test::Unit::TestCase
  context "a user authorizing this library" do
    setup do
      @client = FacebookGraph::Client.new
    end
  end
end