module DotaBot
  class Discord < Service

    def post(args = {})
      matches = args[:matches]
      players_matches = args[:players_matches]
      num_victories = 0
      num_losses = 0

      matches.each do |m|
        if m.team_we_played_on == m.winning_team
          num_victories += 1
        elsif m.team_we_played_on != 'mixed'
          num_losses += 1
        end
      end

      output = "```Markdown
__**Last Night's Dota Shennanigans (#{Date.yesterday.strftime('%e %B %Y')})**__

#{matches.flat_map(&:to_discord_report).join('\n')}


**Summary**
#{num_victories}/#{num_victories+num_losses} matches won
```"

      perform_request(output)
    end

  private
    def perform_request(payload="")
      uri     = URI.parse "https://discordapp.com/api/webhooks/#{token}"
      request = Net::HTTP::Post.new(uri.path)
      request.add_field('Content-Type', 'application/json')
      request.set_form_data({ content: payload })

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      path = uri.path
      data = request.body

      print "  [#{self.class}]  #{uri}\n"

      response = http.post(uri, data)

    end
  end
end
