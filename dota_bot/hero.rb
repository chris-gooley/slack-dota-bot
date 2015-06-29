module DotaBot
  class Hero < Entity
    attribute :id, :slug, :name


    def emoji
      ":dota_#{slug}:"
    end


  private
    def self.load_into_data_store
      YAML.load_file('config/heroes.yml').each do |k,v|
        direct_data_store << new({ id: k, slug: v['short'], name: v['long'] })
      end
    end
  end
end
