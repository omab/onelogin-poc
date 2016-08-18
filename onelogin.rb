require "json"
require "rest-client"

ONELOGIN_SUBDOMAIN = ENV["SUBDOMAIN"]
ONELOGIN_API_CLIENT_ID = ENV["CLIENT_ID"]
ONELOGIN_API_CLIENT_SECRET = ENV["CLIENT_SECRET"]

def onelogin_session_token(email, password)
  response = RestClient.post(onelogin_api_url("api/1/login/auth"), {
    :username_or_email => email,
    :password => password,
    :subdomain => ONELOGIN_SUBDOMAIN
  }.to_json, onelogin_api_headers)

  content = JSON.parse(response, :symbolize_names => true)
  {
    :user => content[:data].first[:user],
    :token => content[:data].first[:session_token]
  }
end

def onelogin_logout(onelogin_id)
  RestClient.put(
    onelogin_api_url("api/1/users/#{onelogin_id}/logout"),
    "",
    onelogin_api_headers
  )
end

def onelogin_api_url(path)
  "https://api.us.onelogin.com/#{path}"
end

def onelogin_access_token
  response = RestClient.post(
    onelogin_api_url("auth/oauth2/token"),
    { :grant_type => "client_credentials" }.to_json,
    onelogin_oauth2_headers
  )
  content = JSON.parse(response, :symbolize_names => true)
  content[:data].first[:access_token]
end

def onelogin_api_headers(authorization = nil)
  {
    :Authorization => authorization || "bearer:#{onelogin_access_token}",
    :content_type => :json,
    :accept => :json
  }
end

def onelogin_oauth2_headers
  onelogin_api_headers(
    "client_id:#{ONELOGIN_API_CLIENT_ID}, client_secret:#{ONELOGIN_API_CLIENT_SECRET}"
  )
end
