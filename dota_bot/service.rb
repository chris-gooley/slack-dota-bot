module DotaBot
  class Service < Entity

    attribute :token, :channel

    def post(args={})
      perform_request(args.merge({ channel: channel }))
    end

    def self.load_into_data_store
      config = YAML.load_file('config/services.yml').each do |data|
        puts 'Loading services'
        direct_data_store << case data.fetch('service')
        when 'discord'
          Discord.new({token: data.fetch('token')})
        when 'slack'
          Slack.new({token: data.fetch('token'), channel: data.fetch('channel') })
        else
          raise "Unsupported Service in config/service.yml"
        end
      end
    rescue Errno::ENOENT => exception
      raise "Could not locate config/services.yml config file."
    rescue KeyError => exception
      raise "#{exception.message} in services.yml"
    end
  end
end
