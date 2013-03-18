source "http://rubygems.org"

gem "sinatra"
gem "sinatra-sequel"
gem "crack"
gem "thin"
gem "json"
gem "haml"

group :production, :staging do
  gem 'newrelic_rpm'
  gem "pg"
end

group :development, :test do
  gem "sqlite3"
  gem "pry"
end

