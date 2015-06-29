module DotaBot
  class DataStore
    include Singleton

    attr_accessor :data


    def initialize
      self.data = Hash.new { |h,k| h[k] = [] }
    end

    def method_missing(meth, *args, &block)
      self.data[meth]
    end
  end
end
