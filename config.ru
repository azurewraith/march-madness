# Fix for dreamhost
# http://nathanhoad.net/no-such-file-to-load-sinatra-on-dreamhost
ENV['GEM_HOME'] ||= `gem env path`.strip.split(':').first
ENV['GEM_PATH'] ||= `gem env path`.strip
Gem.clear_paths

# This file goes in domain.com/config.ru
require 'rubygems'
require 'sinatra'
 
set :run, false
set :env, :production
 
require File.dirname(__FILE__) + '/bracket.rb'
run Sinatra::Application
