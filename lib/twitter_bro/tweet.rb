require "virtus"

module TwitterBro
  class Tweet
    include Virtus.value_object

    values do
      attribute :text, String
    end

    def as_json
      { text: text }
    end
  end
end
