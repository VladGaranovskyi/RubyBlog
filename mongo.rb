require 'mongo'

client = Mongo::Client.new(['127.0.0.1:27017'], database: 'blog')

db = client.database
db.collections

# data = { name: 'Vasiliy', age: 15 }
# client[:test].insert_one(data)

# client[:test].find.each do |record|
#   p record
# end
# client[:test].insert_one({ name: 'Ann', age: 18 })
# client[:test].find({ name: 'Ann' }).each do |record|
#   p record
# end

p client[:posts].count_documents({ 'author' => 'nikita' })
