module RMPDPlayer
  VERSION = '0.1.0'

  class Application < Sinatra::Base
    register Sinatra::AssetPipeline

    helpers Helpers

    configure :development do
      require('sinatra/reloader') and register(Sinatra::Reloader)
    end

    get('/') do
      if Faye::WebSocket.websocket?(request.env)
        websocket = Faye::WebSocket.new(env)
        websocket.on(:message) do |message|
          websocket.send(MPDClient.command(message.data.to_sym).to_json)
        end
        websocket.rack_response
      else
        haml(:index)
      end
    end
  end
end
