source "http://rubygems.org"

ruby '2.2.6'

gem "sinatra"
gem "sinatra-sequel"
gem "crack"
gem "thin"
gem "json"
gem "haml"
gem "sequel", "~> 3.44"
gem "bacon"

group :production, :staging do
  gem 'newrelic_rpm'
  gem "pg"
end

group :development, :test do
  gem "sqlite3"
  gem "pry"
end

