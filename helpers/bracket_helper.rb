require 'net/http'
require 'crack'

class BracketData
  def init_time_zone
    Time.zone = 'America/Chicago'
  end
  
  def BracketData.get_initial_bracket_data
    json = BracketData.get_json_data('teams')
    tournament_hash = Crack::JSON.parse(json)
    teams = tournament_hash['teams']
    
    teams.each do |team|
      t = Team.create do |t|
        t.school = team.names.full
        t.link = team.names.seo
        t.abbrev = team.names.char6
      end
      t.save
    end

    json = get_json_data('data')
    bracket_hash = Crack::JSON.parse(json)
    games = bracket_hash['games']
    
    games.each do |game|
      g = Game.create do |g|
        g.id = game.watchLiveUrl.split("=")[1].to_i
        g.swap = (game.home.isTop == "T" or game.away.isTop == "F") ? "0" : "1"
        
        unless (game.startTimeShort == "")
          t_str = game.startTimeShort.gsub('P', ' P').gsub('.', '')
          d_str = game.gameDate.gsub(/\s+/, ' ')
          td_str = "#{d_str} 2012 #{t_str} -0500"

          g.time = DateTime.strptime(td_str, "%A , %B %d %Y %I:%M %p %z")
        else
          d_str = game.gameDate.gsub(/\s+/, ' ')
          g.time = DateTime.strptime(d_str + " 2012", "%A , %B %d %Y")
        end
        
        case game.currentPeriod
        when 1..2
          g.period_id = game.currentPeriod
        when "1st"
          g.period_id = 1
        when "2nd"
          g.period_id = 2
        when "Final"
          g.period_id = 2
        when /(\d)OT/
          g.period_id = 2 + $1.to_i
        end
        
        # This is now a text field
        g.state_id = State.where(:name => game.gameState).first.id
        
        if (game.home.names.seo != "")
          t = Team.where(:link => game.home.names.seo).first
          g.home_team_id = t.id
          t.seed = (g.swap == 0) ? game.seedTop : game.seedBottom
          t.save
        end
        g.home_points = game.home.score
        
        if (game.away.names.seo != "")
          t = Team.where(:link => game.away.names.seo).first
          g.visitor_team_id = t.id
          t.seed = (g.swap != 0) ? game.seedTop : game.seedBottom
          t.save
        end
        g.visitor_points = game.away.score
      end
      g.save
      BracketData.add_winner_if_needed(g)
    end
  end

  def BracketData.update_bracket_data
    User.all.each do |u|
      u.points = 0
      u.save
    end
    
    json = get_json_data('data')
    bracket_hash = Crack::JSON.parse(json)
    games = bracket_hash['games']

    games.each do |game|
      id = game.watchLiveUrl.split("=")[1].to_i
      g = Game[id]
      g.swap = (game.home.isTop == "T" or game.away.isTop == "F") ? "0" : "1"
      
      unless (game.startTimeShort == "")
        t_str = game.startTimeShort.gsub('P', ' P').gsub('.', '')
        d_str = game.gameDate.gsub(/\s+/, ' ')
        td_str = "#{d_str} 2012 #{t_str} -0500"

        g.time = DateTime.strptime(td_str, "%A , %B %d %Y %I:%M %p %z")
      else
        d_str = game.gameDate.gsub(/\s+/, ' ')
        g.time = DateTime.strptime(d_str + " 2012", "%A , %B %d %Y")
      end
      
      case game.currentPeriod
      when 1..2
        g.period_id = game.currentPeriod
      when "1st"
        g.period_id = 1
      when "2nd"
        g.period_id = 2
      when "Final"
        g.period_id = 2
      when /(\d)OT/
        g.period_id = 2 + $1.to_i
      end
      
      # This is now a text field
      g.state_id = State.where(:name => game.gameState).first.id
      
      if (game.home.names.seo != "")
        t = Team.where(:link => game.home.names.seo).first
        g.home_team_id = t.id
        t.seed = (g.swap == 0) ? game.seedTop : game.seedBottom
        t.save
      end
      g.home_points = game.home.score
      
      if (game.away.names.seo != "")
        t = Team.where(:link => game.away.names.seo).first
        g.visitor_team_id = t.id
        t.seed = (g.swap != 0) ? game.seedTop : game.seedBottom
        t.save
      end
      
      g.visitor_points = game.away.score
      g.save
      BracketData.add_winner_if_needed(g)
    end

    #can be changed later: http://railsforum.com/viewtopic.php?id=10992
    #Game.all.each do |g|
    #  BracketData.add_winner_if_needed(g)
    #end

    #calculate points
    Winner.all.each do |w|
      u = w.user
      points = u.points
      if w.round_id == 6
        points = points + 100;
      else
        points = points + (w.round_id * 10)
      end
      u.points = points
      u.save
      end
    end
    
    def BracketData.add_winner_if_needed(g)
      w = Winner.where(:game_id => g.id).first
      if (w.nil? and g.home_points != nil and g.visitor_points != nil and g.state.name == 'final')
          winning_team_id = g.home_points > g.visitor_points ? g.home_team_id : g.visitor_team_id
          round_id = (g.id / 100) - 1
          user_id = Pick.where(:team_id => winning_team_id, :bracket_id => 1).first.user.id
          #user_id = Team[winning_team_id].user.id
          w = Winner.create do |w|
            w.game_id = g.id
            w.round_id = round_id
            w.user_id = user_id
            w.team_id = winning_team_id
          end
          w.save
      end
    end
    
    def BracketData.get_social_blurb
      #json = BracketData.get_json_data('current')
      #current_hash = Crack::JSON.parse(json)
      #if current_hash['current']['social']['post']
      #  current_hash['current']['social']['post']['content']
      #else
      #  ""
      #end
      ""
    end

    def BracketData.get_json_data(key)
      Net::HTTP.start("data.ncaa.com") { |http|
        resp = http.get("http://data.ncaa.com/sites/default/files/data/gametool/brackets/championships/basketball-men/d1/2011/#{key}.json")
        resp.body
      }
    end
end

class Time
  def to_datetime
    # Convert seconds + microseconds into a fractional number of seconds
    seconds = sec + Rational(usec, 10**6)

    # Convert a UTC offset measured in minutes to one measured in a
    # fraction of a day.
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end
end

# turn hash attributes from a json file into accessors
# given my_hash = { :a => :b, :c => {:d => :e, :f => :g} }
# d can be accessed with the following 'my_hash.c.d'
class Hash
    # Allow my_hash.c.d to behave as if it was my_hash[ c ][ d ]
    #
    # ====Inputs
    # [name]    Symbol representing the missing method
    #
    # ====Returns
    # The hash value accessed by name.
    # 
    def method_missing( name )
        return self[name] if key? name
        self.each { |k,v| return v if k.to_s.to_sym == name }
        super.method_missing name
    end
end