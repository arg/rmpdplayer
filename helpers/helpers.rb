module RMPDPlayer
  module Helpers # TODO: refactor it!
    def configuration
      CONFIGURATION
    end

    def partial(page, options = {})
      haml("partials/#{page}".to_sym, options.merge!(layout: false))
    end

    def songs_list
      MPDClient.songs_list
    end
  end
end
