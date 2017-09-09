require 'bundler'
Bundler.require

require 'json'
require 'securerandom'


helpers do
    def auth
        p request
        user = Users.get_one_by_token(request.env["HTTP_X_TOKEN"]) 
        halt 401, 'Unauthorized.' unless user
        user
    end
end

class Users
    attr_accessor :id, :token, :name
    @@users = []
    
    MASK_VARIABLES = [:@token]

    def initialize(name)
        raise 'Type error.'  if !name.kind_of?(String)
        @name = name
        @token = self.generate_token
        @@users.push(self)
        @id = @@users.find_index{|user| user == self }
    end

    def self.get_one_by_token(token)
        raise 'Type error.' if !token.kind_of?(String)
        @@users.find{|user| user.token == token }
    end

    def self.get_one(id)
        raise 'Type error.' if !id.kind_of?(Integer)
        user = @@users[id]
        raise 'User not found' if !user
    end

    def to_h
        self.instance_variables.each_with_object(Hash.new()) {|tv,h| h.store(tv.to_s.gsub(/\@/,''), self.instance_variable_get(tv))}
    end

    def to_json(*options)
        j_user = self.clone
        j_user.to_h.to_json(*options)
    end

    def remove_mask_variables
        j_user = self.clone
        MASK_VARIABLES.each do |attr|
            j_user.remove_instance_variable(attr)
        end

        j_user
    end

    protected

    def generate_token
        t = nil
        loop do
            t = SecureRandom.hex(16)
            break unless Users.get_one_by_token(t)
        end
        t
    end
end


class Tasks
    attr_accessor :id, :name, :deadline, :user_id
    @@tasks = []

    MASK_VARIBLES = [:@user_id]

    def initialize(name, deadline, user_id)
        raise "Type error." if !name.kind_of?(String) || !deadline.kind_of?(Time) || !user_id.kind_of(Integer)
        @name = name
        @deadline = deadline
        @@tasks.push(self)
    end
end

get '/ok' do
    '{"message":"ok"}'
end

post '/users' do
    user = JSON.parse(request.body.read)
    halt 400, 'Bad request.' if user["name"] == "" || !user

    user = Users.new(user["name"])
    JSON.generate(user)
end

get '/users/:id' do
    auth
    begin
        user = Users.get_one(params[:id].to_i)
    rescue
        halt 404, 'User not found.'
    end
    
    j_user = user.remove_mask_variables
    JSON.generate(j_user)
end

