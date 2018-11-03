# frozen_string_literal: true

require 'htmlentities'

module WP::API
  class Comment < Resource
    def title
      _remove_entities(super)
    end

    def content
      _remove_entities(super)
    end

    def prev
      item = link_header_items.find { |rel, _url| rel == 'prev' }
      item&.last
    end

    def next
      item = link_header_items.find { |rel, _url| rel == 'next' }
      item&.last
    end

    def items
      items = link_header_items.select { |rel, _url| rel == 'item' }
      items.empty? ? [] : items.collect(&:last)
    end

    private

    def link_header_items
      @link_header_items ||= headers['link'].split(', ').collect do |header|
        [
          header.match(/rel="([^"]+)"/)[1],
          header.match(/<([^>]+)>/)[1]
        ]
      end
    rescue StandardError
      []
    end
  end
end
