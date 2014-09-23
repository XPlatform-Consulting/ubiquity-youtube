require 'json'

require 'google/api_client'

module Ubiquity

  module YouTube

    class Client

      class Google

        class AuthHelper

          YOUTUBE_SCOPE = 'https://www.googleapis.com/auth/youtube'
          AUTHORIZATION_URI = 'https://accounts.google.com/o/oauth2/auth'
          AUTHORIZATION_TOKEN_CREDENTIAL_URI = 'https://accounts.google.com/o/oauth2/token'
          AUTHORIZATION_REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'
          AUTHORIZATION_PROVIDER_X509_CERT_PROVIDER = 'https://www.googleapis.com/oauth2/v1/certs'

          # @return [Google::APIClient::ClientSecrets]
          def self.client_secrets_from_hash(client_secrets_data = { 'web' => { }, 'installed' => { } })
            client_secrets_data ||= { 'web' => { }, 'installed' => { } }
            Google::APIClient::ClientSecrets.new(client_secrets_data)
          end

          # @return [Google::APIClient::ClientSecrets]
          def self.client_secrets_from_file(file_path)
            File.exist?(file_path) ? Google::APIClient::ClientSecrets.load(file_path) : create_client_secrets_data_hash
          end

          # Builds a client secrets flow hash from a generic hash
          #
          # @param [Hash] args
          # @option args [String] :access_token
          # @option args [String] :client_id
          # @option args [String] :client_secret
          # @option args [String] :flow ('installed')
          # @option args [String] :refresh_token
          # @option args [String] :token_expires_at
          # @return [Hash]
          def self.create_client_secrets_data_hash(args = { })
            args = Hash[ args.map{ |k,v| _k = k.to_sym rescue k; [ _k, v ] } ]
            access_token = args[:access_token]
            client_id = args[:client_id]
            client_secret = args[:client_secret]
            flow = args[:flow] || 'installed'
            refresh_token = args[:refresh_token]
            token_expires_at = args[:token_expires_at] || args[:token_expiry]
            expires_at = token_expires_at ? Time.parse(token_expires_at) : args[:expires_at]

            authorization_uri = args[:authorization_uri] || AUTHORIZATION_URI
            redirect_uris = args[:redirect_uris]
            auth_provider_x509_cert_url = args[:authorization_provider_x509_cert_url] || AUTHORIZATION_PROVIDER_X509_CERT_PROVIDER
            authorization_token_credential_uri = args[:authorization_token_credential_uri] || AUTHORIZATION_TOKEN_CREDENTIAL_URI
            unless redirect_uris
              is_oob_application = args.fetch(:is_oob_application, true)
              if is_oob_application
                redirect_uris = [ AUTHORIZATION_REDIRECT_URI, 'oob' ]
              else
                redirect_uri = args[:authorization_redirect_uri] || begin
                  authorization_redirect_scheme = args[:authorization_redirect_scheme] || 'http'
                  authorization_redirect_address = args[:authorization_redirect_address] || 'localhost'
                  authorization_redirect_port = args[:authorization_redirect_port] || args[:authorization_server_port] || 80
                  authorization_redirect_path = args[:authorization_redirect_path] || ''
                  "#{authorization_redirect_scheme}://#{authorization_redirect_address}:#{authorization_redirect_port}#{authorization_redirect_path}"
                end
                redirect_uris = [ redirect_uri ]
              end

            end
            {
              :flow => flow,
              flow => {
                :access_token => access_token,
                :auth_provider_x509_cert_url => auth_provider_x509_cert_url,
                :authorization_uri => authorization_uri,
                :client_id => client_id,
                :client_email => '',
                :client_secret => client_secret,
                :client_x509_cert_url => '',
                :redirect_uris => redirect_uris,
                :refresh_token => refresh_token,
                :token_uri => authorization_token_credential_uri,
                :expires_at => expires_at
              }
            }
          end

          def self.default_client_secrets_file_path
            File.expand_path('~/.ubiquity_youtube_client_secrets_data.json')
          end

          attr_reader :authorization, :scope
          attr_accessor :authorization_server_port,
                        :client_secrets,
                        :client_secrets_data,
                        :client_secrets_file_path,
                        :flow_type,
                        :interactive_authentication_enabled

          attr_writer   :read_from_client_secrets_file,
                        :save_to_client_secrets_file

          DEFAULT_AUTHORIZATION_SERVER_PORT = 30080

          def initialize(args = { })
            if args.is_a?(Array)
              args_as_array, args = args, { }
              args[:client_secrets_data], args[:scope] = args_as_array.shift(2)
            end

            @flow_type = args[:flow_type] || 'installed'
            @scope = args[:scope] || YOUTUBE_SCOPE

            @client_secrets_file_path = args[:client_secrets_file_path]
            @interactive_authentication_enabled = args.fetch(:interactive_authentication_enabled, true)
            @read_from_client_secrets_file = args.fetch(:read_from_client_secrets_file, !!client_secrets_file_path)
            @save_to_client_secrets_file = args.fetch(:save_to_client_secrets_file, !!client_secrets_file_path)
            @client_secrets_data = args[:client_secrets_data] ||= self.class.create_client_secrets_data_hash(args)
            @authorization_server_port = args[:authorization_server_port] || DEFAULT_AUTHORIZATION_SERVER_PORT
            self.client_secrets = client_secrets_data if client_secrets_data

            # @authorization = Signet::OAuth2::Client.new({
            #   :authorization_uri => authorization_uri,
            #   :token_credential_uri => token_credential_uri,
            #   :client_id => client_id,
            #   :client_secret => client_secret,
            #   :redirect_uri => redirect_uri,
            #   :scope => scope
            # })
          end

          def read_from_client_secrets_file?; @read_from_client_secrets_file end
          def read_client_secrets_from_file(options = { })
            return false unless read_from_client_secrets_file? or options[:force]

            _client_secrets_file_path = options[:client_secrets_file_path] || client_secrets_file_path
            return false unless File.exist?(_client_secrets_file_path)

            _client_secrets_data = nil
            File.open(_client_secrets_file_path, 'r') do |file|
              _client_secrets_data = JSON.load(file)
              # authorization.access_token = credentials['access_token']
              # authorization.client_id = credentials['client_id']
              # authorization.client_secret = credentials['client_secret']
              # authorization.refresh_token = credentials['refresh_token']
              # authorization.expires_in = (Time.parse(credentials['token_expiry']) - Time.now).ceil rescue 0
            end
            _client_secrets_data
          end

          def authorize
            begin
              _client_secrets_data = read_client_secrets_from_file
              if _client_secrets_data
                self.client_secrets = _client_secrets_data
                if authorization.expired?
                  authorization.instance_variable_set(:@expires_at, nil) # BUG FIX FOR EXPIRES AT NOT GETTING UPDATED DURING A REFRESH
                  authorization.fetch_access_token!

                  save_client_secrets_to_file
                end
                return authorization
              end
            rescue => e
              warn e.message
            end

            return false unless interactive_authentication_enabled

            process_authorization_code_manually unless process_authorization_code_using_server
            save_client_secrets_to_file if authorization.access_token and !authorization.expired?

            return authorization
          end

          def process_authorization_code_using_server
            require 'ubiquity/youtube/client/google/auth_helper/oauth2_authorization_http_server'
            server = OAuth2AuthorizationHTTPServer.new(:server_port => authorization_server_port, :authorization => authorization)

            require 'launchy'
            Launchy.open(authorization.authorization_uri)
            server.start()
            return !authorization.expired?

          rescue => e
            error e.message
            return false
          end

          def process_authorization_code_manually
            puts "Open a Browser and Navigate to: #{authorization.authorization_uri}"
            puts 'Enter Authorization Code:'
            authorization.code = STDIN.gets.chomp
            authorization.instance_variable_set(:@expires_at, nil) # BUG FIX FOR EXPIRES AT NOT GETTING UPDATED DURING A REFRESH
            authorization.fetch_access_token!
          end


          def client_secrets=(new_client_secrets)
            if new_client_secrets.is_a?(Hash)
              new_client_secrets = self.class.create_client_secrets_data_hash(new_client_secrets) unless new_client_secrets.key?(flow_type)
              new_client_secrets = ::Google::APIClient::ClientSecrets.new(new_client_secrets)
            end
            @client_secrets = new_client_secrets
            @authorization = @client_secrets.to_authorization
            authorization.scope = scope
            @client_secrets
          end

          def scope=(new_scope)
            @scope = new_scope
            authorization.scope = @scope if authorization
            @scope
          end

          def authorization_uri; client_secrets.authorization_uri end
          def token_credential_uri; client_secrets.token_credential_uri end
          def client_id; client_secrets.client_id end
          def client_secret; client_secrets.client_secret end
          def redirect_uri; client_secrets.redirect_uris.first end
          def token_expires_at; authorization.expires_at.to_s end

          def authorization_code_uri
            %(#{authorization_uri}?client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}&response_type=code&access_type=offline)
          end

          def refresh_token_uri
            %(#{token_credential_uri}?client_id=#{client_id}&redirect_uri=#{redirect_uri}&grant_type=authorization_code)
          end

          def save_client_secrets_to_file(file_path = client_secrets_file_path)
            return true unless save_to_client_secrets_file?
            File.open(file_path, 'w', 0600) do |file|
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
          def save_to_client_secrets_file?; @save_to_client_secrets_file end

          # AuthHelper
        end

        # Google
      end

      # Client
    end

    # YouTube
  end

  # Ubiquity
end
