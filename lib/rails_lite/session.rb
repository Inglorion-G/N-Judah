require 'json'
require 'webrick'
require 'forwardable'

class Session
  extend Forwardable
  def_delegators :@cookie, :[], :[]=
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == "_rails_lite_app"
        @cookie = JSON.parse(cookie.value)
      end
    end
    @cookie ||= {}
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @cookie.to_json)
  end
end
