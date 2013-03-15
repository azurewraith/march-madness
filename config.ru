require 'sinatra'
 
set :run, false
set :env, :production
 
require File.dirname(__FILE__) + '/bracket.rb'
run Sinatra::Application
