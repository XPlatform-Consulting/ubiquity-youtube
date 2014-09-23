require 'optparse'

require 'ubiquity/youtube/client/google/auth_helper'

module Ubiquity

  module YouTube

    class Client

      class Google

        class AuthHelper

          class CLI

            def self.default_client_secrets_file_path
              AuthHelper.default_client_secrets_file_path
            end

            def self.command_line_arguments_parser(options = { })
              op = OptionParser.new
              op.on('--client-secrets-file-path PATH', 'The path to the file containing the client secrets data.', "\tdefault: #{options[:client_secrets_file_path]}") { |v| options[:client_secrets_file_path] = v }
              op.on('--client-id ID', 'The client id to use when making calls to the API.') { |v| options[:client_id] = v }
              op.on('--client-secret SECRET', 'The client secret to use when making calls to the API.') { |v| options[:client_secret] = v }
              op.on('--help', 'Displays this message.') { puts op; exit }
              op
            end

            def self.parse_command_line_arguments(args = ARGV, options = default_options)
              options.dup
              options[:client_secrets_file_path] ||= default_client_secrets_file_path

              op = command_line_arguments_parser(options)
              op.parse!(args)
              options
            end

            def self.default_options
              {
                :client_secrets_file_path => default_client_secrets_file_path,
                :flow_type => 'installed',
                :is_oob_application => false,
                :authorization_server_port => 30080,
              }
            end

            def self.init_auth_helper(args)
              AuthHelper.new(args)
            end

            def self.auth_helper; @auth_helper end

            def self.execute(args = ARGV, options = default_options)
              options = args.is_a?(Hash) ? options.merge(args) : parse_command_line_arguments(args.dup, options)

              @auth_helper = init_auth_helper(options)

              # Authorize
              @auth_helper.authorize

              @auth_helper
            end

          end

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