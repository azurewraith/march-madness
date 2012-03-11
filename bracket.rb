require 'rubygems'
require 'sqlite3'
require 'sinatra/sequel'
require 'sinatra'
set :database, 'sqlite://march-madness-2012.db'

require 'date'
require 'helpers/bracket_helper.rb'
require 'models/models.rb'
require 'helpers/render_helper.rb'
require 'pry'

migration "create the winners table" do
  database.create_table :winners do
    primary_key :id
    integer     :game_id
    integer     :team_id
    integer     :round_id
    integer     :user_id
  end
end

migration "create the games table" do
  database.create_table :games do
    primary_key :id
    timestamp   :time
    integer     :period_id
    integer     :region_id
    integer     :home_points
    integer     :state_id
    integer     :home_team_id
    integer     :visitor_points
    integer     :visitor_team_id
    integer     :swap
  end
end

migration "create the periods table" do
  database.create_table :periods do
    primary_key   :id
    text          :name
  end
  
  database[:periods].insert(:name => '1st')
  database[:periods].insert(:name => '2nd')
  database[:periods].insert(:name => '1OT')
  database[:periods].insert(:name => '2OT')
end

# TODO: this wasn't used...
migration "create the picks table" do
  database.create_table :picks do
    primary_key :id
    text        :name
  end
end

migration "create the regions table" do
  database.create_table :regions do
    primary_key :id
    text        :name
    text        :abbrev
  end
  
  database[:regions].insert(:name => 'First Four', :abbrev => "")
  database[:regions].insert(:name => 'East', :abbrev => "E")
  database[:regions].insert(:name => 'West', :abbrev => "W")
  database[:regions].insert(:name => 'Southwest', :abbrev => "SW")
  database[:regions].insert(:name => 'Southeast', :abbrev => "SE")
  database[:regions].insert(:name => 'Final Four', :abbrev => "")
  database[:regions].insert(:name => 'Championship', :abbrev => "")
end

migration "create the states table" do
  database.create_table :states do
    primary_key :id
    text        :name
  end
  
  database[:states].insert(:name => 'scheduled')
  database[:states].insert(:name => 'in_between')
  database[:states].insert(:name => 'in_progress')
  database[:states].insert(:name => 'complete')
end

migration "create the teams table" do
  database.create_table :teams do
    primary_key :id
    text        :school
    text        :nickname
    text        :color
    integer     :seed
    text        :link
    text        :abbrev
    integer     :user_id
  end
end

migration "create the users table" do
  database.create_table :users do
    primary_key :id
    text        :name
    text        :color
    integer     :points
  end
end

migration "populate initial data" do
  BracketData.get_initial_bracket_data
end

migration "add users" do
  User.create(:name => 'Ashley', :color => '#BDFFFF', :points => 0)
  User.create(:name => 'Jenny', :color => '#FFBDD1', :points => 0)
  User.create(:name => 'Steve', :color => '#FFBF8A', :points => 0)
  User.create(:name => 'Papa', :color => '#EDFFAA', :points => 0)
end

picks_2011 = {}
picks_2011[5]	= 2
picks_2011[7]	= 3
picks_2011[9]	= 4
picks_2011[29]	= 2
picks_2011[32]	= 3
picks_2011[68]	= 4
picks_2011[77]	= 3
picks_2011[83]	= 3
picks_2011[87]	= 1
picks_2011[104]	= 2
picks_2011[110]	= 1
picks_2011[140]	= 4
picks_2011[147]	= 4
picks_2011[164]	= 4
picks_2011[193]	= 2
picks_2011[234]	= 2
picks_2011[235]	= 1
picks_2011[248]	= 3
picks_2011[251]	= 3
picks_2011[257]	= 1
picks_2011[260]	= 4
picks_2011[270]	= 4
picks_2011[301]	= 1
picks_2011[305]	= 1
picks_2011[327]	= 2
picks_2011[328]	= 3
picks_2011[334]	= 4
picks_2011[361]	= 4
picks_2011[367]	= 3
picks_2011[387] = 3
picks_2011[404]	= 4
picks_2011[416]	= 4
picks_2011[418]	= 3
picks_2011[434]	= 2
picks_2011[444]	= 1
picks_2011[456]	= 3
picks_2011[457]	= 1
picks_2011[465]	= 2
picks_2011[502]	= 3
picks_2011[513]	= 1
picks_2011[514]	= 1
picks_2011[518]	= 4
picks_2011[523]	= 2
picks_2011[539]	= 1
picks_2011[545]	= 3
picks_2011[554]	= 1
picks_2011[559]	= 4
picks_2011[575]	= 4
picks_2011[603]	= 4
picks_2011[617]	= 3
picks_2011[626]	= 2
picks_2011[657]	= 2
picks_2011[688]	= 2
picks_2011[690]	= 1
picks_2011[694]	= 2
picks_2011[697]	= 4
picks_2011[703]	= 3
picks_2011[706]	= 3
picks_2011[731]	= 2
picks_2011[736]	= 2
picks_2011[739]	= 4
picks_2011[740]	= 2
picks_2011[756]	= 3
picks_2011[768]	= 1
picks_2011[796]	= 1
picks_2011[812]	= 1
picks_2011[2915] = 2
picks_2011[14927] = 3

migration "set picks from 2011 temporarily" do
  Team.all do |t|
    t.user_id = picks_2011[t.id]
    t.save
  end
end

#before '/' do
#  init_time_zone
#end
#before_filter :init_time_zone
  
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
  #binding.pry

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

helpers do
  include RenderHelpers
  
  def icon_for_team(team_abbrev)
    abbrev = team_abbrev.downcase
    letter = abbrev[0,1]
    "&nbsp;<img width=17px src='http://i.turner.ncaa.com/dr/ncaa/ncaa/release/sites/default/files/images/logos/schools/#{letter}/#{abbrev}.17.png'>&nbsp;"
  end
end
