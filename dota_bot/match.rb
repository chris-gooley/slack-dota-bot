module DotaBot
  class Match
    include DotaBot::Attributes

    GAME_MODES = {
      0  => { short: '--',     long: 'Unknown' },
      1  => { short: 'AP',     long: 'All Pick' },
      2  => { short: 'CM',     long: 'Captains Mode' },
      3  => { short: 'RD',     long: 'Random Draft' },
      4  => { short: 'SD',     long: 'Single Draft' },
      5  => { short: 'AR',     long: 'All Random' },
      6  => { short: '--',     long: '?? INTRO/DEATH ??' },
      7  => { short: '--',     long: 'The Diretide' },
      8  => { short: '--',     long: 'Reverse Captains Mode' },
      9  => { short: '--',     long: 'Greeviling' },
      10 => { short: '--',     long: 'Tutorial' },
      11 => { short: 'MO',     long: 'Mid Only' },
      12 => { short: 'LP',     long: 'Least Played' },
      13 => { short: 'NPP',    long: 'New Player Pool' },
      14 => { short: '--',     long: 'Compendium Matchmaking' },
      15 => { short: '--',     long: 'Custom' },
      16 => { short: 'CD',     long: 'Captains Draft' },
      17 => { short: 'BD',     long: 'Balanced Draft' },
      18 => { short: 'AD',     long: 'Ability Draft' },
      19 => { short: '--',     long: '?? Event ??' },
      20 => { short: 'DM',     long: 'All Random Death Match' },
      21 => { short: '1v1',    long: '1vs1 Solo Mid' },
      22 => { short: 'Ranked', long: 'Ranked All Pick' }
    }


    attribute :match_id, :start_time, :players, :duration, :winning_team, :game_mode


    def players=(players)
      @players = players.map { |p| DotaBot::MatchPlayer.new(p) }
    end

    def load_match_details!
      DotaBot::SteamAPI.instance.match_details(match_id).tap do |details|
        self.attributes = details
      end
    end

    def radiant_win=(v)
      self.winning_team = v ? 'radiant' : 'dire'
    end

    def more_than_one_known_player?
      players.count(&:player) > 1
    end

    def known_players_string
      players.map(&:player).compact.map(&:name).to_sentence
    end

    def radiant_players
      players.select(&:radiant?)
    end

    def dire_players
      players.select(&:dire?)
    end

    def team_we_played_on
      teams_we_played_on = players.map { |p| p.team if p.player }.compact.uniq

      if teams_we_played_on.size > 1
        'mixed'
      else
        teams_we_played_on.first
      end
    end

    def formatted_start_time
      Time.at(start_time).in_time_zone('Australia/Adelaide').strftime("%l:%M %p").strip
    end

    def formatted_duration
      [
        [ 'h', duration / (60*60) ],
        [ 'm', (duration / 60) - ((duration / (60*60)) * 60) ],
        [ 's', duration % 60 ]
      ].select { |v| v[1] > 0 }.map { |v| "#{v[1]}#{v[0]}" }.join(' ')
    end

    def long_game_mode
      GAME_MODES[game_mode][:long]
    end

    def short_game_mode
      GAME_MODES[game_mode][:short]
    end

    def to_report
      [
        {
          title: "#{long_game_mode} @ #{formatted_start_time}",
          value: "#{known_players_string} played in this game (http://dotabuff.com/matches/#{match_id})",
          short: false
        },
        team_report('radiant'),
        team_report('dire'),
        {
          title: "Winner",
          value: "#{winning_team == 'radiant' ? ':deciduous_tree:' : ':volcano:'} #{winning_team.upcase} VICTORY in #{formatted_duration}\n\n:nbsp:",
          short: false
        }
      ]
    end

    def team_report(team)
      players = (team == 'radiant' ? radiant_players : dire_players)

      report_string = ''
      report_string << players.map(&:hero_emoji).join(' ')

      players.each do |player|
        report_string << "\n" + player.to_report
      end

      {
        title: team.titleize,
        value: report_string,
        short: true
      }
    end
  end
end
