#!/usr/bin/env ruby
require 'optparse'

require 'google/api_client'
require 'google/api_client/client_secrets'
require 'json'
require 'launchy'

module Ubiquity

  module YouTube

    class Client

      module Google

        # Small helper for the sample apps for performing OAuth 2.0 flows from the command
        # line. Starts an embedded server to handle redirects.
        class CommandLineAuthHelper
          def self.execute(args = ARGV)
            options = {
                :client_secrets_file_path => default_client_secrets_file_path,
            }
            op = OptionParser.new
            op.on('--client-secrets-file-path PATH', 'The path to the file containing the client secrets data.', "\tdefault: #{options[:client_secrets_file_path]}") { |v| options[:client_secrets_file_path] = v }
            op.on('--client-id ID', 'The client id to use when making calls to the API.') { |v| options[:client_id] = v }
            op.on('--client-secret SECRET', 'The client secret to use when making calls to the API.') { |v| options[:client_secret] = v }
            op.parse!(args)
            # instance = new(options)
            # instance.authorize
            # instance
          end

        end

        class CommandLineAuthHelper_
          FILE_POSTFIX = '-oauth2.json'

          def self.default_client_secrets_file_path
            File.expand_path('~/.ubiquity_youtube_client_secrets_data.json')
          end

          def self.execute(args = ARGV)
            options = {
              :client_secrets_file_path => default_client_secrets_file_path,
            }
            op = OptionParser.new
            op.on('--client-secrets-file-path PATH', 'The path to the file containing the client secrets data.', "\tdefault: #{options[:client_secrets_file_path]}") { |v| options[:client_secrets_file_path] = v }
            op.parse!(args)
            instance = new(options)
            instance.authorize
            instance
          end

          def self.client_secrets_from_hash(client_secrets_data)
            puts "Getting Client Secrets from Hash: #{client_secrets_data.inspect}"
            ::Google::APIClient::ClientSecrets.new(client_secrets_data)
          end

          def self.client_secrets_from_file(file_path)
            puts "Getting Client Secrets from File Path: #{file_path}"
            ::Google::APIClient::ClientSecrets.load(_file_path)
          end

          attr_accessor :credentials, :credentials_file_path

          attr_reader :authorization_server_port

          def initialize(args = { })
            scope = args[:scope]
            @credentials_file_path = args[:credentials_file_path] || args[:client_secrets_file_path]
            client_secrets_data = args[:client_secrets_data]
            @credentials = args[:credentials] || begin
              puts "Determining Credentials"
              if (client_secrets_data.is_a?(Hash) and !client_secrets_data.empty?)
                self.class.client_secrets_from_hash(client_secrets_data)
              elsif File.exists?(credentials_file_path)
                self.class.client_secrets_from_file(credentials_file_path)
              end
            end
            @authorization_server_port = args[:authorization_server_port] || 8080
            @authorization = Signet::OAuth2::Client.new(
              :authorization_uri => credentials.authorization_uri,
              :token_credential_uri => credentials.token_credential_uri,
              :client_id => credentials.client_id,
              :client_secret => credentials.client_secret,
              :redirect_uri => credentials.redirect_uris.first,
              :scope => scope
            ) if credentials
          end

          # Request authorization. Checks to see if a local file with credentials is present, and uses that.
          # Otherwise, opens a browser and waits for response, then saves the credentials locally.
          def authorize

            if File.exist? credentials_file_path
              File.open(credentials_file_path, 'r') do |file|
                credentials = JSON.load(file)
                @authorization.access_token = credentials['access_token']
                @authorization.client_id = credentials['client_id']
                @authorization.client_secret = credentials['client_secret']
                @authorization.refresh_token = credentials['refresh_token']
                @authorization.expires_in = (Time.parse(credentials['token_expiry']) - Time.now).ceil
                if @authorization.expired?
                  @authorization.fetch_access_token!
                  save(credentials_file_path)
                end
              end
            else
              #auth = @authorization
              url = @authorization.authorization_uri().to_s
              # server = Thin::Server.new('0.0.0.0', authorization_server_port) do
              #   run lambda { |env|
              #     # Exchange the auth code & quit
              #     req = Rack::Request.new(env)
              #     auth.code = req['code']
              #     auth.fetch_access_token!
              #     server.stop()
              #     [ 200, {'Content-Type' => 'text/html'}, RESPONSE_HTML]
              #   }
              # end

              server = OAuth2AuthorizationHTTPServer.new(:server_port => authorization_server_port, :authorization => authorization)

              Launchy.open(url)
              server.start()

              save(credentials_file_path)
            end

            return @authorization
          end

          def save(credentialsFile)
            File.open(credentialsFile, 'w', 0600) do |file|
              json = JSON.dump({
                                   :access_token => @authorization.access_token,
                                   :client_id => @authorization.client_id,
                                   :client_secret => @authorization.client_secret,
                                   :refresh_token => @authorization.refresh_token,
                                   :token_expiry => @authorization.expires_at
                               })
              file.write(json)
            end
          end

          # CommandLineAuthHelper
        end

        #Google
      end
      #Client
    end
    #YouTube
  end
  # Ubiquity
end
