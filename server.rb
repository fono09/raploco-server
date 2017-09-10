require 'bundler'
Bundler.require

require 'json'
require 'securerandom'

helpers do
    def auth
        p request
        user = User.where(token: request.env["HTTP_X_TOKEN"])
        halt 401, 'Unauthorized.' if user.empty?
        user.first
    end
end

class User < ActiveRecord::Base
    has_many :favorites
    has_many :favorite_users, through: :favorites, source: 'favorite_user'

    def self.generate_token
        t = nil
        loop do
            t = SecureRandom.hex(16)
            break if User.where(token: t).empty?
        end
        t
    end
end


class Task < ActiveRecord::Base
end

class Favorite < ActiveRecord::Base
    belongs_to :user
    belongs_to :favorite_user, class_name: 'User', foreign_key: 'favorite_user_id'
end

class Genre < ActiveRecord::Base
end

get '/ok' do
    {message: 'ok'}.to_json
end

post '/users/favorites' do
    current_user = auth
    user = JSON.parse(request.body.read)

    user = User.where(id: user["id"])
    halt 404, 'User not found.' if user.empty?
    user = user.first

    if Favorite.where(user_id: current_user.id, favorite_user_id:user.id).empty? then
        favorite = Favorite.new(user: current_user, favorite_user:user)
        favorite.save
    end

    user.to_json(except:[:token])
end


get '/users/favorites' do
    current_user = auth

    users = current_user.favorite_users
    {users: users}.to_json(except:[:token])
end

delete '/users/favorites/:id' do
    current_user = auth

    favorites = Favorite.where(user_id: current_user.id, favorite_user_id: params[:id])
    halt 404, 'Favorite not found.' if favorites.empty?

    favorites.first.destroy
    
    body ''
    status 200
end
post '/users' do
    user = JSON.parse(request.body.read)
    halt 400, 'Bad request.' if user["name"] == "" || !user

    user = User.new(name: user["name"], token: User.generate_token)
    user.save

    p user

    user.to_json
end

get '/users/:id' do
    current_user = auth
    user = User.where(id: params[:id].to_i)
    halt 404, 'User not found.' if user.empty?
    user = user.first

    user.to_json(except:[:token])
end

post '/tasks' do
    current_user = auth
    task = JSON.parse(request.body.read)
    task = Task.new(name: task["name"], user_id: current_user.id, deadline: task["deadline"], cost: task["cost"], genre_id: task["genre"])
    task.save
    
    task.to_json(except:[:user_id])
end

put '/tasks/:id' do
    current_user = auth
    task = JSON.parse(request.body.read)

    t = Task.where(id: params[:id].to_i)
    halt 404, 'Task not found.' if t.empty?
    target_task = t.first

    target_task.update(task)

    target_task.to_json
end

get '/tasks' do
    current_user = auth
    tasks = Task.where(user_id: current_user.id)
    { tasks: tasks }.to_json(except:[:user_id])
end


post '/genres' do 
    current_user = auth

    genre = JSON.parse(request.body.read)
    e_genre = Genre.where(name: genre["name"])

    if e_genre.empty? then
        genre = Genre.new(name: genre["name"])
        genre.save
    else
        genre = e_genre.first
    end

    genre.to_json
end

get '/genres' do
    current_user = auth
    genres = Genre.all
    {"genres": genres }.to_json
end
    
