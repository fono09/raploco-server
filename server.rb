require 'bundler'
Bundler.require

require 'json'
require 'securerandom'

set :database, {adapter: "sqlite3", database: "raploco.sqlite3"}

helpers do
    def auth
        p request
        user = Users.where(token: request.env["HTTP_X_TOKEN"]).first
        user
    end
end

class Users < ActiveRecord::Base
    def self.generate_token
        t = nil
        loop do
            t = SecureRandom.hex(16)
            break if Users.where(token: t).empty?
        end
        t
    end
end


class Tasks < ActiveRecord::Base
end

get '/ok' do
    '{"message":"ok"}'
end

post '/users' do
    user = JSON.parse(request.body.read)
    halt 400, 'Bad request.' if user["name"] == "" || !user

    user = Users.new(name: user["name"], token: Users.generate_token)
    user.save

    p user

    user.to_json
end

get '/users/:id' do
    current_user = auth
    user = Users.where(params[:id].to_i)
    halt 404, 'User not found.' if user.empty?

    user.to_json(except:[:token])
end

post '/tasks' do
    current_user = auth
    task = JSON.parse(request.body.read)
    task = Tasks.new(name: task["name"], user_id: current_user.id, deadline: task["deadline"], cost: task["cost"])
    task.save
    
    task.to_json(except:[:user_id])
end

