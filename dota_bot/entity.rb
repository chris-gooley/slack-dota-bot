module DotaBot
  class Entity
    include DotaBot::Attributes


    def self.load_into_data_store
    end

    def self.direct_data_store
      DotaBot::DataStore.instance.send(self.name)
    end

    def self.data_store
      load_into_data_store if direct_data_store.empty?
      direct_data_store
    end

    def self.all
      data_store
    end

    def self.method_missing(meth, *args, &block)
      if meth.to_s =~ /^find_by_(.+)$/
        unless @_attributes.include?($1)
          raise StandardError.new("#{self.name} does not include the attribute: `#{$1}`")
        end

        data_store.detect { |h| h.send($1).to_s == args[0].to_s }
      else
        super
      end
    end
  end
end
