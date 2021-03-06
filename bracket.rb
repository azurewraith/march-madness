require "bundler/setup"
require "sinatra/sequel"
require "sinatra"
require "json"

set :database, ENV['DATABASE_URL'] || 'sqlite://march-madness-2018.db'

require 'date'
require './helpers/bracket_helper.rb'
require './helpers/render_helper.rb'
require './models/models.rb'

begin
  User.first
rescue Sequel::DatabaseError
  require './models/migrations.rb'
end

get '/' do
  #@users = User.order("points desc").all
  @users = User.all.sort! { |a,b| b.points <=> a.points }

  # sort regions by ordering
  @regions = Region.all

  @nw_quad_round_1 = Game.where(:id => 201..208).order(:id)
  @sw_quad_round_1 = Game.where(:id => 209..216).order(:id)
  @ne_quad_round_1 = Game.where(:id => 217..224).order(:id)
  @se_quad_round_1 = Game.where(:id => 225..232).order(:id)

  @nw_quad_round_2 = Game.where(:id => 301..304).order(:id)
  @sw_quad_round_2 = Game.where(:id => 305..308).order(:id)
  @ne_quad_round_2 = Game.where(:id => 309..312).order(:id)
  @se_quad_round_2 = Game.where(:id => 313..316).order(:id)

  @nw_quad_round_3 = Game.where(:id => 401..402).order(:id)
  @sw_quad_round_3 = Game.where(:id => 403..404).order(:id)
  @ne_quad_round_3 = Game.where(:id => 405..406).order(:id)
  @se_quad_round_3 = Game.where(:id => 407..408).order(:id)

  @nw_quad_round_4 = Game.where(:id => 501).order(:id)
  @sw_quad_round_4 = Game.where(:id => 502).order(:id)
  @ne_quad_round_4 = Game.where(:id => 503).order(:id)
  @se_quad_round_4 = Game.where(:id => 504).order(:id)

  @final_four = Game.where(:id => 601..602).order(:id)

  @final = Game.where(:id => 701)

  @tz_offset = "-04:00"
  erb :bracket
end

get '/update' do
  BracketData.update_bracket_data
  @blurb = BracketData.get_social_blurb
  if @blurb == nil
    @blurb = ""
  end
  content_type :json
  { :result => 'success'}.to_json
end

# get '/gmtoffset' do
#   session[:gmtoffset] = -params[:gmtoffset].to_i*60 if !params[:gmtoffset].nil? # notice that the javascript version of gmtoffset is in minutes ;-)
#   session[:time_zone_name] = ActiveSupport::TimeZone.all.select{|t|t.utc_offset == params[:gmtoffset]}.first
#   render :nothing => true # this can be improved by being able to return xml or json output to inform the client side whether the offset was successfully set on the server or not.
# end

get '/picks/edit' do
  @users = User.all
  @picks = Pick.where(:bracket_id => 1)
  haml :edit_picks
end

post '/picks/edit' do
  if params['secret'] != 'xyzzy'
    return "invalid secret"
  end
  params.delete('secret')

  params.each do |k, v|
    p = Pick[k.to_i]
    p.user_id = v.to_i
    p.save
  end
  "update successful"
end

helpers do
  include RenderHelpers

  def icon_for_team(team_abbrev)
    abbrev = team_abbrev.downcase
    letter= abbrev[0,1]
    "<img class='image' src='http://i.turner.ncaa.com/sites/default/files/images/logos/schools/#{letter}/#{abbrev}.17.png'>"
  end

  def user_for_pick(team, bracket_id)
    if Pick.count == 0
      User.new(:name => "Nobody", :color => "#ECECEC", :points => 0)
    else
      Pick.where(:team_id => team.id, :bracket_id => bracket_id).first.user
    end
  end
end
