module DotaBot
  class Player < Entity
    attribute :id, :name, :show_own


    def matches(opts={})
      @matches ||= begin
        DotaBot::SteamAPI.instance.match_history(id, opts)['matches'].map { |match_data| DotaBot::Match.new(match_data) }
      end

    rescue
      print "  [ERROR]  (#{self.id}:#{self.name})\t#{DotaBot::SteamAPI.instance.match_history(id, opts).inspect}\n"

      # Remove self from the store
      Player.direct_data_store.delete(self)
    end

    def own_matches
      matches.select{|m| !m.more_than_one_known_player? }
    end

    def has_own_matches?
      own_matches.count > 0 && show_own
    end

    def to_report
      match_summary = own_matches.map do |match|
        plyr = match.players.select{|p| p.player.try(:id) == id }.first

        team = match.radiant_players.include?(plyr) ? 'radiant' : 'dire'

        "#{plyr.hero_emoji} (#{plyr.kda} - #{match.short_game_mode} - <http://dotabuff.com/matches/#{match.match_id}|#{team == match.winning_team ? 'win' : 'loss'}>)"
      end.join(', ')

      "@#{name} played #{own_matches.count} #{own_matches.count != 1 ? 'games' : 'game'}: #{match_summary}"
    end

  private
    def self.load_into_data_store
      YAML.load_file('config/players.yml').each do |data|
        direct_data_store << new({ id: data['steam_id'], name: data['name'], show_own: data['show_own'] })
      end
    end
  end
end
