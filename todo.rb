require 'sinatra'
require 'data_mapper'
require 'haml'

# Make sure your DataMapper models are defined *before* the configure
# block, otherwise your DB won't be updated and you're in for trouble and
# what-not.
class Todo
  include DataMapper::Resource
  property :id, Serial
  property :text, String
end

configure do
  # Heroku has some valuable information in the environment variables.
  # DATABASE_URL is a complete URL for the Postgres database that Heroku
  # provides for you, something like: postgres://user:password@host/db, which
  # is what DM wants. This is also a convenient check wether we're in production
  # / not.
  DataMapper.setup(:default, (ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/development.sqlite3"))
  DataMapper.auto_upgrade!
end

get '/' do
  @todos = Todo.all
  haml :index
end

post '/' do
  Todo.create(:text => params['todo'])
  redirect '/'
end

# Inspect the environment for additional information. This should *not* be
# accessible in a production app.
get '/env' do
  content_type 'text/plain'
  ENV.inspect
end

__END__

@@ index
!!!
%html
  %head
    %title Toodeloo
  %body
    %h1 Toodeloo
    %ul
      - @todos.each do |todo|
        %li= todo.text
    %form{:action => '/', :method => 'POST'}
      %input{:type => 'text', :name => 'todo'}
      %input{:type => 'submit', :name => 'Todo!'}
    %a{:href => 'http://gist.github.com/68277'} Read more..