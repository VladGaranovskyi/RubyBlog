class Post < Base
  class << self
    PAGE_SIZE = 5

    def all(page_number)
      connection[POST_COLLECTION_NAME].find
        .skip(PAGE_SIZE * (page_number - 1)).limit(PAGE_SIZE)
    end

    def count
      connection[POST_COLLECTION_NAME].count
    end

    def get(name)
      connection[POST_COLLECTION_NAME].find({ name: name }).first
    end

    def get_by(criteria, value, page_number)
      connection[POST_COLLECTION_NAME].find({ criteria.to_sym => value })
        .skip(PAGE_SIZE * (page_number - 1)).limit(PAGE_SIZE)
    end

    def save(post)
      connection[POST_COLLECTION_NAME].insert_one(post)
    end

    def delete(name)
      connection[POST_COLLECTION_NAME].delete_one({ name: name })
    end

    def add_comment(post_name, comment)
      connection[POST_COLLECTION_NAME].update_one(
        { name: post_name },
        { '$push' => { 'comments' => comment } }
      )
    end

    def delete_comment(post_name, comment, author)
      connection[POST_COLLECTION_NAME].update_one(
        { name: post_name },
        { '$pull' => {
          'comments' => { 'text' => comment, 'author' => author } }
        }
      )
    end

    def get_by_user
      all = connection[POST_COLLECTION_NAME].find
      user_posts = Hash.new(0)

      all.each { |post| user_posts[post['author']] += 1 }

      user_posts
    end
  end
end
