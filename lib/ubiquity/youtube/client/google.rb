require 'logger'

require 'ubiquity/youtube/client/google/auth_helper'

module Ubiquity

  module YouTube

    class Client

      class Google

        APPLICATION_NAME = 'YouTube Library'
        YOUTUBE_API_SERVICE_NAME = 'youtube'
        YOUTUBE_API_VERSION = 'v3'

        LIST_PART_SNIPPET = 'snippet'

        def self.auth_helper; AuthHelper end

        attr_accessor :logger, :client, :youtube, :auth_helper

        attr_accessor :access_token, :client_id, :client_secret

        def initialize(args = { })
          @application_name = args[:application_name] || APPLICATION_NAME
          @application_version = args[:application_version] || '1.0.0'

          @auth_helper = self.class.auth_helper.new(args)
          auth_helper.authorize

          @client = ::Google::APIClient.new(:application_name => @application_name, :application_version => @application_version)
          client.authorization = auth_helper.authorization

          @youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)
        end

        def initialize_logger(args = { })
          @logger = args[:logger] || Logger.new(args[:log_to] || STDOUT)
        end

        # @see https://developers.google.com/youtube/v3/docs/videos/delete
        def video_delete(args = { })
          video_id = args[:video_id]
          client.execute!( :api_method => youtube.videos.delete, :parameters => { :id => video_id } )
        end

        # @see https://developers.google.com/youtube/v3/docs/videos/insert
        def video_insert(args = { })
          title = args[:title]
          description = args[:description]
          tags = args[:tags]
          tags = tags.join(', ') if tags.is_a?(Array)
          privacy_status = args[:privacy_status] # || 'public'
          category_id = args[:category_id] || 22
          file_path = args[:file_path]

          #begin
          media = ::Google::APIClient::UploadIO.new(file_path, 'video/*')

          snippet = {
              :title => title,
              :description => description,
              :tags => tags,
              :categoryId => category_id
          }
          status = { :privacyStatus => privacy_status }
          body = { :snippet => snippet, :status => status }

          args_out = {
              :api_method => youtube.videos.insert,
              :body_object => body,
              :media => media,
              :parameters => {
                  :uploadType => 'resumable',
                  :part => body.keys.join(',')
              }
          }

          videos_insert_response = client.execute!( args_out )
          videos_insert_response.resumable_upload.send_all(client)

          # rescue Google::APIClient::TransmissionError => e
          # puts e.results.body
          # end

          videos_insert_response.data.id
        end

        # @see https://developers.google.com/youtube/v3/docs/videos/list
        def video_list(args = { })
          parts = args[:parts] || LIST_PART_SNIPPET
          parameters = { :parts => parts }

          client.execute!( :api_method => youtube.videos.list, :parameters => parameters )
        end

        # @see https://developers.google.com/youtube/v3/docs/videos/update
        def video_update(args = { })
          video_id = args[:video_id]
          description = args[:description]
          tags = args[:tags]
          tags = tags.join(', ') if tags.is_a?(Array)
          privacy_status = args[:privacy_status]
          category_id = args[:category_id]
          file_path = args[:file_path]

          body = { }

          snippet = { }
          status = { }

          args_out = {
              :api_method => youtube.subscriptions.update,
              :parameters => { :part => body.keys.join(',') },
              :body_object => body
          }

          response = client.execute!(args_out)
        end

      end

    end

  end

end
