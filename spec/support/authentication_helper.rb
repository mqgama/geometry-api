module AuthenticationHelper
  def auth_headers(user = nil)
    user ||= create(:user)
    token = user.generate_jwt_token
    { 'Authorization' => "Bearer #{token}" }
  end

  def authenticated_request(method, path, user: nil, **options)
    headers = auth_headers(user)
    options[:headers] = (options[:headers] || {}).merge(headers)
    send(method, path, **options)
  end
end
