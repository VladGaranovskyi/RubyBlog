require 'mongo'
require 'sinatra'
require 'json'

require 'sinatra/flash'
require 'digest'

require_relative './helpers'

require_relative './lib/models/base'
require_relative './lib/models/post'
require_relative './lib/models/user'

set :public_folder, File.dirname(__FILE__) + '/static'
set :views, settings.root + '/templates'

enable :sessions

PROTECTED_ROUTES = [
  '/create', '/delete', '/logout', '/create/comment', '/users'
]

before do
  if session['name'].nil? && PROTECTED_ROUTES.include?(request.path_info)
    flash[:notice] = "you should login first"
    redirect '/'
  end
end

get '/' do
  erb :main, layout: :layout, locals: {
    posts: Post.all(page_number),
    username: session['name'],
    count: Post.count
  }
end

get '/search/:criteria' do
  erb :main, layout: :layout, locals: {
    posts: Post.get_by(params['criteria'], params['value'], page_number),
    username: session['name'],
    count: Post.count
  }
end

get '/create' do
  erb :create, layout: :layout
end

get '/post' do
  erb :post, layout: :layout, locals: { post: Post.get(params['name']) }
end

post '/create' do
  post = {
    name: params['name'],
    body: params['body'],
    author: session['name'],
    time: Time.now.strftime('%H:%M:%S %d %B %Y'),
    comments: []
  }

  Post.save(post)
  redirect '/'
end

post '/delete' do
  if session['name'] == Post.get(params['name'])['author']
    Post.delete(params['name'])
  end

  redirect '/'
end

post '/delete/comment' do
  Post.delete_comment(params['post_name'], params['comment'], session['name'])

  redirect '/post?name=' + params['post_name']
end

post '/create/comment' do
  comment = {
    author: session['name'],
    text: params['text']
  }

  Post.add_comment(params['name'], comment)
  redirect "/post?name=#{params['name']}"
end

get '/register' do
  erb :register, layout: :layout
end

post '/register' do
  errors = User.register(params['username'], params['password'])
  if errors.empty?
    redirect '/login'
  else
    errors.each { |e| flash[e.to_sym] = e }
    redirect '/register'
  end
end

get '/login' do
  erb :login, layout: :layout
end

post '/login' do
  if user = User.login(params['username'], params['password'])
    session['name'] = user['name']
    redirect '/'
  else
    flash[:notice] = 'cannot login with this username or password'
    redirect '/login'
  end
end

post '/logout' do
  session.clear # session['name'] = nil
  redirect '/'
end

get '/users' do
  if user != 'admin'
    flash[:error] = 'you do not have rights to see other users list'
    redirect '/'
  end

  erb :users, layout: :layout, locals: { users: User.users, user_posts: Post.get_by_user }
end
