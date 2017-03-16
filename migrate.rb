require 'sinatra'
require 'sinatra/sequel'

set :database, ENV['DATABASE_URL'] || 'sqlite://march-madness-2017.db'

require './helpers/bracket_helper.rb'
require './models/models.rb'
require './models/migrations.rb'
