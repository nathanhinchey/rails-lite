require 'json'
require 'webrick'
require 'byebug'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      cookies = req.cookies
      cookie_index = cookies.find_index do |el|
        el.name == "_rails_lite_app"
      end

      if cookie_index
        cookie = cookies[cookie_index]
        @values = JSON.parse(cookie.value)
      else
        @values = {}
      end
    end

    def [](key)
      @values[key]
    end

    def []=(key, val)
      @values[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      res.cookies << WEBrick::Cookie.new("_rails_lite_app", @values.to_json)
    end
  end
end
