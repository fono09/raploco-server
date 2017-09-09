require 'bundler'
Bundler.require

require 'json'
require 'securerandom'

class Users
    attr_reader :id, :token, :name
    @@users = []

    def initialize(name)
        @name = name
        @token = self.generate_token
        @@users.push(self)
        @id = @@users.find_index{|user| user == self }
    end


    def get_one(id)
        return nil unless id.kind_of?(Integer)
        @@users[id]
    end

    def to_h
        { "id": @id,
          "name": @name,
          "token": @token }
    end

    def to_json(*options)
        self.to_h.to_json(*options)
    end

    protected

    def generate_token
        t = nil
        loop do
            t = SecureRandom.hex(16)
            break unless @@users.find{|user| user.token == token }
        end
        t
    end
end

get '/ok' do
    '{"message":"ok"}'
end

post '/users' do
    user = JSON.parse(request.body.read)
    user = Users.new(user["name"])
    return JSON.generate(user)
end



