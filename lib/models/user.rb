class User < Base
  class << self
    # here could be Hash
    def register(username, password)
      errors = []

      if username.length < 4
        errors << 'username is too short'
      end

      if connection[USER_COLLECTION_NAME].find({ name: username }).count > 0
        errors << 'user with this name exists'
      end

      if password.length < 5
        errors << 'the password is too short'
      end

      return errors unless errors.empty?

      user = {
        name: username,
        password: Digest::SHA256.hexdigest(password)
      }

      connection[USER_COLLECTION_NAME].insert_one(user)

      errors
    end

    def login(username, password)
      connection[USER_COLLECTION_NAME].find({
        name: username, password: Digest::SHA256.hexdigest(password)
      }).first
    end

    def users
      connection[USER_COLLECTION_NAME].find({ name: { '$ne' => 'admin' } })
    end

    def users_post_count
      users.to_a.map do |user|
        connection[POST_COLLECTION_NAME].count_documents({ 'author' => user['name'] })
      end
    end
  end
end
