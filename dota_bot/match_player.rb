module DotaBot
  class MatchPlayer
    include DotaBot::Attributes

    attribute :player, :team, :hero, :level, :kills, :deaths, :assists


    def account_id=(id)
      self.player = DotaBot::Player.find_by_id(id)
    end

    def hero_id=(id)
      self.hero = DotaBot::Hero.find_by_id(id)
    end

    def player_slot=(val)
      self.team = val < 5 ? 'radiant' : 'dire'
    end

    def player_name
      player ? "@#{player.name}" : "#{self.team.capitalize} Player"
    end

    def radiant?
      self.team == 'radiant'
    end

    def dire?
      self.team == 'dire'
    end

    def kda
      "#{kills}/#{deaths}/#{assists}"
    end

    def to_report
      "#{player_name} #{hero_emoji} lvl #{level} (#{kda})"
    end

    def hero_emoji
      hero.emoji
    rescue
      ":dota_icon:"
    end
  end
end
