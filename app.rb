require "sinatra"
require_relative "onelogin"

enable :sessions

get "/" do
  @user = session[:user]
  erb :index
end

get "/login" do
  redirect "/"
end

post "/login" do
  onelogin_session = onelogin_session_token(params[:email], params[:password])
  @user = session[:user] = onelogin_session[:user]
  @session_token = onelogin_session[:token]
  erb :index
end

get "/logout" do
  user = session.delete(:user)
  onelogin_logout(user[:id])
  redirect "/"
end
