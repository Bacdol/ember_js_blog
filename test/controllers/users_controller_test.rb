require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "#create" do
    post 'create', {
      user: {
        username: 'billy',
        name: 'Billy Blowers',
        email: 'billy_blowers@example.com',
        password: 'secret',
        password_confirmation: 'secret'
      }
    }
    results = JSON.parse(response.body)
    assert results['api_key']['access_token'] =~ /\S{32}/
    assert results['api_key']['user_id'] > 0
  end

  test "#create with invalid data" do
    post 'create', {
      user: {
        username: '',
        name: '',
        email: 'foo',
        password: 'secret',
        password_confirmation: 'something_else'
      }
    }
    results = JSON.parse(response.body)
    assert results['errors'].size == 3
  end

  test "#show" do
    cycy = users(:cycy)
    post 'show', { id: cycy.id }
    results = JSON.parse(response.body)
    assert results['user']['id'] == cycy.id
    assert results['user']['name'] == cycy.name
  end

  test "#index without token in header" do
    get 'index'
    assert response.status == 401
  end

  test "#index with invalid token" do
    get 'index', {}, { 'Authorization' => "Bearer 12345" }
    assert response.status == 401
  end

  test "#index with expired token" do
    cycy = users(:cycy)
    expired_api_key = cycy.api_keys.session.create
    expired_api_key.update_attribute(:expired_at, 30.days.ago)
    assert !ApiKey.active.map(&:id).include?(expired_api_key.id)
    get 'index', {}, { 'Authorization' => "Bearer #{expired_api_key.access_token}" }
    assert response.status == 401
  end

  test "#index with valid token" do
    cycy = users(:cycy)
    api_key = cycy.session_api_key
    get 'index', {}, { 'Authorization' => "Bearer #{api_key.access_token}" }
    results = JSON.parse(response.body)
    assert results['users'].size == 2
  end
end
