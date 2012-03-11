require 'net/http'
require 'crack'

class BracketData
  def init_time_zone
    Time.zone = 'America/Chicago'
  end
  
  def BracketData.get_initial_bracket_data
    json = BracketData.get_json_data('tournament')
    tournament_hash = Crack::JSON.parse(json)
    teams = tournament_hash['tournament']['teams']['team']
    
    teams.each do |team|
      t = Team.create do |t|
        t.id = team['id']
        t.school = team['school']
        t.nickname = team['nick']
        t.color = team['color']
        t.seed = team['seed']
        t.link = team['link']
        t.abbrev = team['abbrev']
      end
      t.save
    end
    
    regions = tournament_hash['tournament']['regions']['region']

    json = get_json_data('bracket')
    bracket_hash = Crack::JSON.parse(json)
    games = bracket_hash['bracket']['game']

    games.each do |game|
      g = Game.create do |g|
        g.id = game['id']
        g.time = Time.at(game['time'].to_i).to_datetime
        g.period_id = game['per']
        g.region_id = game['reg']
        g.home_points = game['ptsH']
        g.state_id = game['state']
        g.home_team_id = game['tmH']
        g.visitor_points = game['ptsV']
        g.visitor_team_id = game['tmV']
        g.swap = game['swap']
      end
      g.save
      BracketData.add_winner_if_needed(g)
    end
  end

  def BracketData.update_bracket_data
    json = BracketData.get_json_data('bracket')
    bracket_hash = Crack::JSON.parse(json)
    games = bracket_hash['bracket']['game']
    
    User.all.each do |u|
      u.points = 0
      u.save
    end

    games.each do |game|
      g = Game.find(game['id'])
      g.id = game['id']
      g.time = Time.at(game['time'].to_i).to_datetime
      g.period_id = game['per']
      g.region_id = game['reg']
      g.home_points = game['ptsH']
      g.state_id = game['state']
      g.home_team_id = game['tmH']
      g.visitor_points = game['ptsV']
      g.visitor_team_id = game['tmV']
      g.swap = game['swap']
      g.save
    end

    #can be changed later: http://railsforum.com/viewtopic.php?id=10992
    Game.all.each do |g|
      BracketData.add_winner_if_needed(g)
    end

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
      puts w
      if (w.nil? and g.home_points != nil and g.visitor_points != nil and g.state.name == 'complete')
          winning_team_id = g.home_points > g.visitor_points ? g.home_team_id : g.visitor_team_id
          round_id = (g.id / 100) - 1
          user_id = Team[winning_team_id].user.id
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
      json = BracketData.get_json_data('current')
      current_hash = Crack::JSON.parse(json)
      if current_hash['current']['social']['post']
        current_hash['current']['social']['post']['content']
      else
        ""
      end
    end

    def BracketData.get_json_data(key)
      Net::HTTP.start("data.ncaa.com") { |http|
        resp = http.get("/jsonp/mmod/2011/mobile/#{key}.json")
        # remove javascript
        json = resp.body.gsub(/callbackWrapper\(/, "")
        json = json.gsub(/\);/, "")
        json
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