require 'rubygems'
require "bundler/setup"

require 'sqlite3'
require 'sinatra/sequel'
require 'sinatra'
set :database, 'sqlite://march-madness-2012.db'

require 'date'
require 'helpers/bracket_helper.rb'
require 'helpers/render_helper.rb'
require 'models/models.rb'
require 'models/migrations.rb'
  
get '/' do
  BracketData.update_bracket_data
  @blurb = BracketData.get_social_blurb
  if @blurb == nil
    @blurb = ""
  end

  @users = User.order("points desc").all

  @regions = Region.all
  @e_round_1 = Game.where(:id => 201..208)
  @w_round_1 = Game.where(:id => 209..216)
  @sw_round_1 = Game.where(:id => 217..224)
  @se_round_1 = Game.where(:id => 225..232)

  @e_round_2 = Game.where(:id => 301..304)
  @w_round_2 = Game.where(:id => 305..308)
  @sw_round_2 = Game.where(:id => 309..312)
  @se_round_2 = Game.where(:id => 313..316)

  @e_round_3 = Game.where(:id => 401..402)
  @w_round_3 = Game.where(:id => 403..404)
  @sw_round_3 = Game.where(:id => 405..406)
  @se_round_3 = Game.where(:id => 407..408)

  @e_round_4 = Game.where(:id => 501)
  @w_round_4 = Game.where(:id => 502)
  @sw_round_4 = Game.where(:id => 503)
  @se_round_4 = Game.where(:id => 504)

  @final_four = Game.where(:id => 601..602)

  @final = Game.where(:id => 701)
  erb :bracket
end

get '/gmtoffset' do
  session[:gmtoffset] = -params[:gmtoffset].to_i*60 if !params[:gmtoffset].nil? # notice that the javascript version of gmtoffset is in minutes ;-)
  session[:time_zone_name] = ActiveSupport::TimeZone.all.select{|t|t.utc_offset == params[:gmtoffset]}.first
  render :nothing => true # this can be improved by being able to return xml or json output to inform the client side whether the offset was successfully set on the server or not.
end

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
    "<img class='image' src='http://i.turner.ncaa.com/dr/ncaa/ncaa/release/sites/default/files/images/logos/schools/#{letter}/#{abbrev}.17.png'>"
  end
  
  def user_for_pick(team, bracket_id)
    Pick.where(:team_id => team.id, :bracket_id => bracket_id).first.user
  end
end
