class Base
  class << self
    USER_COLLECTION_NAME = :users
    POST_COLLECTION_NAME = :posts

    def connection
      Mongo::Client.new(['127.0.0.1:27017'], database: 'blog')
    end
  end
end
