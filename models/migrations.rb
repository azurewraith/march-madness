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
    integer     :home_points
    integer     :state_id
    integer     :home_team_id
    integer     :visitor_points
    integer     :visitor_team_id
    integer     :swap
  end
end

migration "create the teams table" do
  database.create_table :teams do
    primary_key :id
    text        :school
    integer     :seed
    text        :link
    text        :abbrev
    text        :short
    integer     :user_id
    integer     :eliminated
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
    integer     :bracket_id
    integer     :user_id
    integer     :team_id
  end
end

migration "create the regions table" do
  database.create_table :regions do
    primary_key :id
    text        :name
    text        :abbrev
  end

  database[:regions].insert(:name => 'First Four', :abbrev => "")

  # nw quad
  database[:regions].insert(:name => 'South', :abbrev => "S")
  # sw quad
  database[:regions].insert(:name => 'East', :abbrev => "E")
  # ne quad
  database[:regions].insert(:name => 'West', :abbrev => "W")
  # se quad
  database[:regions].insert(:name => 'Midwest', :abbrev => "MW")

  database[:regions].insert(:name => 'Final Four', :abbrev => "")
  database[:regions].insert(:name => 'Championship', :abbrev => "")
end

migration "create the states table" do
  database.create_table :states do
    primary_key :id
    text        :name
  end

  database[:states].insert(:name => 'pre')
  database[:states].insert(:name => 'scheduled')
  database[:states].insert(:name => 'in_between')
  database[:states].insert(:name => 'in_progress')
  database[:states].insert(:name => 'final')
  database[:states].insert(:name => 'live')
end

migration "create the brackets table" do
  database.create_table :brackets do
    primary_key :id
    text        :users
  end

  database[:brackets].insert(:users => "[1, 2, 3, 4, 5, 6]")
end

migration "create the users table" do
  database.create_table :users do
    primary_key :id
    text        :name
    text        :color
    integer     :points
  end
end

Game.dataset = Game.dataset

migration "populate initial data" do
  BracketData.update_bracket_data
end

User.dataset = User.dataset
Pick.dataset = Pick.dataset

migration "add users" do
  User.create(:name => 'Ashley', :color => '#BDFFFF', :points => 0)
  User.create(:name => 'Jenny', :color => '#FFBDD1', :points => 0)
  User.create(:name => 'Steve', :color => '#FFBF8A', :points => 0)
  User.create(:name => 'Papa', :color => '#EDFFAA', :points => 0)
  User.create(:name => 'Ben', :color => '#8BD9A4', :points => 0)
  User.create(:name => 'Joe', :color => '#D99595', :points => 0)
end

migration "set random picks to users" do
  seed_groups = [1..3, 4..6, 7..9, 10..12, 13..15, 16..16]
  index = 0
  seed_groups.each do |range|
    Team.where(:eliminated => 0, :seed => range).order(Sequel.lit('RANDOM()')).all do |t|
      Pick.create(:bracket_id => 1, :user_id => ((index % 6) + 1), :team_id => t.id)
      index = index + 1
    end
  end
end