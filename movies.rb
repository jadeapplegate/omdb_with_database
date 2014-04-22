require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

# A setup step to get rspec tests running.
configure do
  root = File.expand_path(File.dirname(__FILE__))
  set :views, File.join(root,'views')
end

get '/' do
  erb :search
end

get '/results' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  @movies = c.exec_params("select * from movies WHERE title = $1;", [params[:title].capitalize])
  c.close
  erb :results
end

get '/title/:id' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  movies = c.exec_params("select * from movies WHERE id = $1;", [params[:id]])
  @movie = movies[0]

  # @actors = c.exec_params("select * from actors inner join movies_actors ON movies_actors.movie_id = $1;", [params[:id]])

  c.close
  erb :show
end

get '/movies/new' do
  erb :new
end

post '/movies' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  c.exec_params("INSERT INTO movies (title, descriptioon) VALUES ($1, $2)",
                  [params["title"], params["description"]])
  c.close
  redirect '/'
  erb :new
end

def dbname
  "testdb"
end

def create_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec %q{
  CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    title varchar(255),
    year varchar(255),
    plot text,
    genre varchar(255)
  );
  }
  connection.close
end

def drop_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec "DROP TABLE movies;"
  connection.close
end

def seed_movies_table
  movies = [["Glitter", "2001"],
              ["Titanic", "1997"],
              ["Sharknado", "2013"],
              ["Jaws", "1975"]
             ]
 
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  movies.each do |p|
    c.exec_params("INSERT INTO movies (title, year) VALUES ($1, $2);", p)
  end
  c.close
end

# binding.pry
