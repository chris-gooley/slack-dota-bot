module DotaBot
  class Report
    def self.since_last_reported
      # Fetch last seen mach id
      last_seen_match_id = File.open('last_seen_match_id').read.to_i

      num_victories = 0
      num_losses    = 0

      print "  [REPORT] Preparing report from match id: #{last_seen_match_id}\n"

      # Collate matches from all players where two or more known players participated
      DotaBot::Player.all.each { |p| p.matches }

      DotaBot::Player.all.each do |player|
        if last_seen_match_id != 0
          player.matches.select!{ |m| m.match_id > last_seen_match_id }
        else
          player.matches.slice!(5..-1)
        end
      end

      matches = DotaBot::Player.all.map(&:matches).flatten.sort_by(&:start_time)

      matches.uniq!(&:match_id)

      # Load additional details for these matches we'll report on
      matches.each { |m| m.load_match_details! }

      return if matches.empty?

      if (own_matches = DotaBot::Player.all.select(&:has_own_matches?)).any?
        players_matches = [{
          title: 'Matches with randoms',
          value: own_matches.map(&:to_report).join("\n"),
          short: false
        }]

        own_matches.each do |p|
          p.own_matches.each do |m|
            if m.team_we_played_on == m.winning_team
              num_victories += 1
            elsif m.team_we_played_on != 'mixed'
              num_losses += 1
            end
          end
        end
      else
        players_matches = []
      end

      last_match_id = matches.last.match_id

      matches.select!(&:more_than_one_known_player?)

      matches.each do |m|
        if m.team_we_played_on == m.winning_team
          num_victories += 1
        elsif m.team_we_played_on != 'mixed'
          num_losses += 1
        end
      end

      summary_line = [{
        title: 'Summary',
        value: "#{num_victories}/#{num_victories+num_losses} matches won",
        short: false
      }]

      DotaBot::SlackAPI.instance.post({
        username:    "dotabot",
        text:        "Last Night's Dota Shennanigans (#{Date.yesterday.strftime('%e %B %Y')})",
        icon_emoji:  ":dota_icon:",
        link_names:  1,
        attachments: [
          fields: matches.flat_map(&:to_report) + players_matches + summary_line,
          mrkdwn_in: [ 'fields' ]
        ]
      })

      print "  [REPORT] Recording seen up until match id: #{last_match_id}\n"

      # Persist last seen match id
      File.open('last_seen_match_id', 'w') do |f|
        f << last_match_id
      end
    end
  end
end
