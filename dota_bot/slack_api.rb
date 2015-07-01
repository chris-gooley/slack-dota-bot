module DotaBot
  class SlackAPI
    BASE_URI = 'http://api.steampowered.com/IDOTA2Match_570'

    include Singleton

    attr_accessor :account, :token, :channel


    def initialize
      config = YAML.load_file('config/slack.yml')
      self.token   = config['token']
      self.channel = config['channel']
    end

    def post(args={})
      perform_request(args.merge({ channel: channel }))
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
