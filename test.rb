ENV['RAcK_ENV'] = 'test'

require 'json'
require './server'
require 'test/unit'
require 'rack/test'

class ServerTest < Test::Unit::TestCase
    include Rack::Test::Methods

    def app
        Sinatra::Application
    end

    def test_it_says_ok
        get '/ok'
        assert last_response.ok?
        assert_equal '{"message":"ok"}', last_response.body, 'Server Health Check failed.'
    end

    @@token = ''
end
