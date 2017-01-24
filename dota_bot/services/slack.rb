module DotaBot
  class Slack < Service

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

      summary_line = [{
        title: 'Summary',
        value: "#{num_victories}/#{num_victories+num_losses} matches won",
        short: false
      }]

      perform_request({
        username:    "dotabot",
        channel:     channel,
        text:        "Last Night's Dota Shennanigans (#{Date.yesterday.strftime('%e %B %Y')})",
        icon_emoji:  ":dota_icon:",
        link_names:  1,
        attachments: [
          fields: matches.flat_map(&:to_slack_report) + players_matches + summary_line,
          mrkdwn_in: [ 'fields' ]
        ]
      })
    end

  private
    def perform_request(payload={})
      uri     = URI.parse "https://hooks.slack.com/services/#{token}"
      request = Net::HTTP::Get.new(uri.path)
      request.set_form_data({ payload: payload.to_json })

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      path = uri.path
      data = request.body

      print "  [SLACK]  #{uri}\n"

      http.post(uri, data)
    end
  end
end
