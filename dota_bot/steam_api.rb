module DotaBot
  class SteamAPI
    BASE_URI = 'http://api.steampowered.com/IDOTA2Match_570'

    include Singleton

    attr_accessor :key


    def initialize
      config = YAML.load_file('config/steam.yml')
      self.key = config['key']
    end

    def match_history(account_id, args={})
      perform_request("#{BASE_URI}/GetMatchHistory/v001/", args.merge(account_id: account_id))
    end

    def match_details(match_id, args={})
      perform_request("#{BASE_URI}/GetMatchDetails/v001/", args.merge(match_id: match_id))
    end


  private
    def perform_request(url, args={})
      args.merge!(key: key)

      request_url = "#{url}?#{URI.encode_www_form(args)}"

      print "  [STEAM]  #{request_url}\n"
      JSON.parse(open(request_url).read)['result']
    end
  end
end
