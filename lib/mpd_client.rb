module RMPDPlayer
  class MPDClient
    extend SingleForwardable

    COMMANDS = [:play, :pause, :stop, :next, :previous, :status]

    def_delegators :mpd_client, :play, :stop, :next, :previous

    class << self
      def command(data)
        send(data) if COMMANDS.include?(data)
      end

      def songs_list
        mpd_client.queue
      end

      def pause
        mpd_client.pause = mpd_client.playing?
      end

      def status
        status = mpd_client.status
        result = status.slice(:state)
        if status[:state] != :stop
          current_song = mpd_client.current_song
          result.merge!(
            {
              song_title: current_song.title,
              song_artist: current_song.artist,
              song_file: current_song.file
            })
        end
        result
      end

      private

      def mpd_client
        @mpd_client ||= initialize_mpd_client
      end

      def initialize_mpd_client
        MPD.new(CONFIGURATION[:mpd_host], CONFIGURATION[:mpd_port]).tap(&:connect)
      end
    end
  end
end
