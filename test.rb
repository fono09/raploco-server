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

    def test_get_status
        get '/ok'
        assert last_response.ok?
        assert_equal '{"message":"ok"}', last_response.body, 'Server Health Check failed.'
    end

    @@token = nil
    def test_0010_create_user
        post '/users', params={name: "foo"}.to_json
        assert last_response.ok?
        response_data = JSON.parse(last_response.body)
        assert_not_nil response_data["token"]
        assert_equal response_data["name"], "foo"
        @@token = response_data["token"]
    end

    def test_0011_get_a_user
        header 'X-Token', @@token
        get '/users/1'
        assert last_response.ok?
        response_data = JSON.parse(last_response.body)
        assert_not_nil response_data
    end

    def test_0020_create_task
        header 'X-Token', @@token
        header 'Content-Type', 'application/json'
        post '/tasks', {name:"task_name", cost:20, genre: 0, deadline: Time.now()}.to_json
        assert last_response.ok?
        response_data = JSON.parse(last_response.body)
        assert_equal response_data["name"], 'task_name'
    end

    @@task = nil
    def test_0021_get_all_task
        header 'X-Token', @@token
        get '/tasks'
        assert last_response.ok?
        response_data = JSON.parse(last_response.body)
        assert_equal response_data.length, 1
        @@task = response_data["tasks"][0]
    end

    def test_0022_update_a_task
        @@task["name"] = "task_name2"
        header 'X-Token', @@token
        put "/tasks/#{@@task["id"]}", params = @@task.to_json
        assert last_response.ok?
        response_data = JSON.parse(last_response.body)
        assert_equal response_data["name"], 'task_name2'
    end

    def test_0023_delete_a_task
        header 'X-Token', @@token
        delete "/tasks/#{@@task["id"]}"
        assert last_response.ok?
    end
        
    
    def test_0030_create_favorite_user
        header 'X-Token', @@token
        header 'Content-Type', 'application/json'
        post '/users/favorites', {id: 1}.to_json
        assert last_response.ok?
        response_data = JSON.parse(last_response.body)
    end

    @@favorite_user = nil
    def test_0031_get_favorite_users
        header 'X-Token', @@token
        get '/users/favorites'
        assert last_response.ok?
        response_data = JSON.parse(last_response.body)
        @@favorite_user = response_data["users"].find{|user| user["id"] == 1}
        assert_not_nil @@favorite_user 
    end

    def test_0032_delete_favorite_user
        header 'X-Token', @@token
        delete '/users/favorites/1'
        assert last_response.ok?
    end

    @@genre = nil
    def test_0040_create_genre
        header 'X-Token', @@token
        header 'Content-Type', 'application/json'
        post '/genres', {name: '大学'}.to_json
        assert last_response.ok?
        response_data = JSON.parse(last_response.body)
        @@genre = response_data
        assert_not_nil @@genre
    end

    def test_0041_get_genres
        header 'X-Token', @@token
        header 'Content-Type', 'application/json'
        get '/genres'
        assert last_response.ok?
        response_data = JSON.parse(last_response.body)
        match_genre = response_data["genres"].find{|genre| genre["name"] == @@genre["name"]}
        assert_not_nil match_genre
    end

end
