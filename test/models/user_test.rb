require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "#session" do
    cycy = users(:cycy)
    api_key = cycy.session_api_key
    assert api_key.access_token =~ /\S{32}/
    assert api_key.user_id == cycy.id
  end
end
