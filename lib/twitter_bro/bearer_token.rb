require "virtus"

module TwitterBro
  class BearerToken
    include Virtus.value_object

    values do
      attribute :value, String
    end

    def to_s
      value
    end
  end
end
