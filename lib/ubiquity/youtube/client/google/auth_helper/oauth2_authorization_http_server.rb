require 'thin'

module Ubiquity

  module YouTube

    class Client

      class Google

        class AuthHelper

          class OAuth2AuthorizationHTTPServer

            RESPONSE_HTML = <<-stop
              <html>
                <head>
                  <title>OAuth 2 Flow Complete</title>
                </head>
                <body>
                  You have successfully completed the OAuth 2 flow. Please close this browser window and return to your program.
                </body>
              </html>
            stop

            def initialize(args = { })

              server_port = args[:server_port]
              auth = args[:authorization]
              @server = server = Thin::Server.new('0.0.0.0', server_port) do
                run lambda { |env|
                  # Exchange the auth code & quit
                  req = Rack::Request.new(env)
                  authorization_code = req['code']
                  if authorization_code
                    auth.code = authorization_code
                    auth.fetch_access_token!
                    response = [ 200, {'Content-Type' => 'text/html'}, RESPONSE_HTML]
                  else
                    response = [ 400, {'Content-Type' => 'text/html'}, 'No Authorization Code Found.']
                  end
                  server.stop()
                  response
                }
              end
            end

            def start
              @server.start
            end

            # OAuth2AuthorizationHTTPServer
          end

          # AuthHelper
        end

        #Google
      end
      #Client
    end
    #YouTube
  end
  # Ubiquity
end