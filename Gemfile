source "http://rubygems.org"

gem "sinatra"
gem "sinatra-sequel"
gem "crack"
gem "thin"
gem "json"
gem "haml"
gem "sequel", "~> 3.44"

group :production, :staging do
  gem 'newrelic_rpm'
  gem "pg"
end

group :development, :test do
  gem "sqlite3"
  gem "pry"
end

