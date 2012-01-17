class Game < ActiveRecord::Base
  belongs_to :region
  belongs_to :state
  belongs_to :home_team, :class_name => 'Team', :foreign_key => 'home_team_id'
  belongs_to :visitor_team, :class_name => 'Team', :foreign_key => 'visitor_team_id'
end

class Period < ActiveRecord::Base
end

class Pick < ActiveRecord::Base
end

class Region < ActiveRecord::Base
  belongs_to :team
  belongs_to :game
end

class State < ActiveRecord::Base
  has_many :games
end

class Team < ActiveRecord::Base
  has_one :region
  belongs_to :user
end

class User < ActiveRecord::Base
  has_many :teams
end

class Winner < ActiveRecord::Base
  belongs_to :user
end