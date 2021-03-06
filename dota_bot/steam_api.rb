module DotaBot
  class SteamAPI
    BASE_URI = 'http://api.steampowered.com/IDOTA2Match_570'

    include Singleton

    attr_accessor :key


    def initialize
      config = YAML.load_file('config/steam.yml')
      self.key = config.fetch('key')
    rescue Errno::ENOENT => exception
      raise "Could not locate config/steam.yml config file."
    rescue KeyError => exception
      raise "#{exception.message} in steam.yml"
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
      Kernel.sleep(1)
      JSON.parse(open(request_url).read)['result']


    rescue OpenURI::HTTPError => ex
      error_code = ex.io.status[0]

      if error_code == '429'
        # Sleep and retry
        Kernel.sleep(5)
        perform_request(url, args)
      else
        raise
      end
    end
  end
end
