module Lunar
  # @private Used internally by Lunar::search to get all the word matches
  # given `nest`, `att` and it's `val`.
  class KeywordMatches
    attr :nest
    attr :att
    attr :value

    def initialize(nest, att, value)
      @nest, @att, @value = nest, att.to_sym, value
    end

    def distkey
      return if keys.flatten.empty?

      nest[{ att => value }.hash].tap do |dk|
        dk.zunionstore keys.flatten
        # Trying something out here, I only want results that meet all the criteria
        # dk.zinterstore keys.flatten
      end
    end

  protected
    def keys
      if att == :q
        metaphones.map { |m|
          nest[Index::FIELDS][Index::TEXT].smembers.map { |att| nest[att][m] }
        }
      else
        metaphones.map { |m| nest[att][m] }
      end
    end

    def metaphones
      Words.new(value, [:stopwords]).map { |word| Lunar.metaphone(word) }
    end
  end
end
