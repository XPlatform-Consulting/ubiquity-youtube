YouTube Library and Command Line Utilities
==========================================

Installation
------------

    git clone https://github.com/XPlatform-Consulting/ubiquity-youtube.git
    cd ubiquity-youtube
    bundle update

Setup
-----

  In order to use the YouTube library you must first register your application in the [Google Developers Console](https://console.developers.google.com).
  
##### New application
  - Browse to the Google Developers Console
  - Select "Create Project" from the navigation view
  - Enter a project name and project id and press the "Create" button
  - Once your new project is ready, click on the project and select "Enable an API" from the Project Dashboard
  - Enable the API named "YouTube Data API v3"
  - Select "Credentials" in the "APIs & auth" menu in the left hand navigation bar   
  - Click on "Create new Client ID" in the OAuth section
  - Select "Installed application" under "APPLICATION TYPE" and "Other" as the "INSTALLED APPLICATION TYPE"
  - Record the "CLIENT ID" and "CLIENT SECRET" for the 
  
##### Applications that have a Client ID and Client Secret
  - Navigate to the ubiquity-youtube/bin directory
  - Execute the following command: ./youtube_auth --client-id [Your Application Client ID] --client-secret [Your Application Client Secret]

YouTube Authentication Executable [bin/youtube_auth](./bin/youtube_auth)
-------------------------------------------------------------------------
An executable that to facilitate the create of the client secrets file used for authentication.

Usage: youtube_auth [options]

    --client-secrets-file-path PATH
                                 The path to the file containing the client secrets data.
                                  default: ~/.ubiquity_youtube_client_secrets_data.json
    --client-id ID               The client id to use when making calls to the API.
    --client-secret SECRET       The client secret to use when making calls to the API.
    --help                       Displays this message.
        
#### Examples of Usage:

###### Accessing help.
  ./youtube_auth --help
  
###### Initial Setup
  ./youtube_auth --client-id [CLIENT ID] --client-secret [CLIENT SECRET]


YouTube Upload Executable [bin/youtube_upload](./bin/youtube_upload)
--------------------------------------------------------------------
An executable that to facilitate the upload of assets to YouTube

Usage: youtube_upload [options]

    --client-secrets-file-path PATH
                                 The path to the file containing the client secrets data.
                                  default: ~/.ubiquity_youtube_client_secrets_data.json
    --file-path PATH             The path of the file to upload.
    --category-id ID             The Id of the category to add the video to.
                                  default: 22
    --privacy-status PRIVACY     The privacy setting for the video.
                                  default: private
    --video-description DESC     The description for the video.
    --video-title TITLE          The title of the video.
    --help                       Display this screen.
        
#### Examples of Usage:

###### Accessing help.
  ./youtube_upload --help
  
###### Simple Usage
  ./youtube_upload --file-path /media/movie.mov
