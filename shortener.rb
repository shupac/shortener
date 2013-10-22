require 'sinatra'
require 'active_record'
require 'pry'
require 'digest/sha1'
require 'json'


# Digest::SHA1.hexdigest 'www.google.com'


###########################################################
# Configuration
###########################################################

set :public_folder, File.dirname(__FILE__) + '/public'

configure :development, :production do
    ActiveRecord::Base.establish_connection(
       :adapter => 'sqlite3',
       :database =>  'db/dev.sqlite3.db'
     )
end

# Handle potential connection pool timeout issues
after do
    ActiveRecord::Base.connection.close
end

###########################################################
# Models
###########################################################
# Models to Access the database through ActiveRecord.
# Define associations here if need be
# http://guides.rubyonrails.org/association_basics.html

class Link < ActiveRecord::Base
  self.table_name = 'link'
end

###########################################################
# Routes
###########################################################

get '/' do
    @links = Link.all # FIXME
    erb :index
end

get '/new' do
    erb :form
end

post '/new' do
  url = request.POST['url']
  puts url[0..3]
  if url[0..3] != 'http'
    url = 'http://' + url
  end
  hashedURL = (Digest::SHA1.hexdigest url)[0..5]
  if Link.find_by_url(url) == nil
    Link.create(url: url, shortened: hashedURL)
  else
    puts 'Duplicate url entered'
  end
  #respond with data object
  Link.find_by_url(url)['shortened']
end

get '/*' do
  shortened = params[:splat].first
  puts shortened
  if Link.find_by_shortened(shortened) == nil
    puts 'Shortened URL not found'
    #return 404
  else
    puts Link.find_by_shortened(shortened)['url']
    redirect(Link.find_by_shortened(shortened)['url'])
  end
end












