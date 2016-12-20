module Github
  module Mirror
    # Helper functions for Github::Mirror
    module Utility
      def self.hash_symbolize(hash)
        hash.each_with_object({}) do |(k, v), memo|
          memo[k.to_sym] = v
          memo
        end
      end

      def self.hash_deep_symbolize(hash)
        hash = hash_symbolize(hash)

        hash.each_key do |key|
          hash[key] = hash_deep_symbolize(hash[key]) if hash[key].is_a?(Hash)
        end
      end
    end
  end
end
