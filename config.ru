
# This file goes in domain.com/config.ru
require 'rubygems'
require 'sinatra'
 
set :run, false
set :env, :production
 
require 'bracket.rb'
run Sinatra::Application
