# frozen_string_literal: true

module WP::API
  class Tag < Resource
    def to_param
      slug
    end
  end
end
