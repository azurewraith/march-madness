module Sequel
  class Model
    def method_missing(name, *args, &blk)
      column_name = name.to_s.gsub('=', '').to_sym
      if columns.include? column_name
        self[column_name] = args.slice(0)
      else
        super
      end
    end
  end
end

class Game < Sequel::Model
  unrestrict_primary_key
  many_to_one :region
  many_to_one :state
  many_to_one :home_team, :class_name => 'Team', :foreign_key => 'home_team_id'
  many_to_one :visitor_team, :class_name => 'Team', :foreign_key => 'visitor_team_id'
end

class Period < Sequel::Model
end

class Pick < Sequel::Model
  many_to_one :team
  many_to_one :user
end

class Region < Sequel::Model
  many_to_one :team
  many_to_one :game
end

class State < Sequel::Model
  one_to_many :games
end

class Team < Sequel::Model
  one_to_many :region
  #many_to_one :user
end

class User < Sequel::Model
  #many_to_one :teams
  many_to_one :picks
end

class Winner < Sequel::Model
  many_to_one :user
end