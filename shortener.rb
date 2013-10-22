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
    @links = [] # FIXME
    puts Link.where(url: 'www.google.com').inspect
    erb :index
end

get '/new' do
    erb :form
end

post '/new' do
  url = request.POST['url']
  hashedURL = Digest::SHA1.hexdigest url
  Link.create(url: url, shortened: hashedURL)
end

# MORE ROUTES GO HERE