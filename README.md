YouTube Library and Command Line Utilities
==========================================

System Requirements
------------
    <a href="https://www.ruby-lang.org/en/installation/">Ruby 1.8.7</a>
    <a href="http://git-scm.com/book/en/Getting-Started-Installing-Git">Git</a> 
    RubyGems
    Bundler
    
Prerequisites
-------------

CentOS 6.4 or higher

    yum install git
    yum install ruby-devel
    yum install rubygems
    gem install bundler

Mac OS X
    
    gem install bundler

    
Installation
------------

    git clone https://github.com/XPlatform-Consulting/ubiquity-youtube.git
    cd ubiquity-youtube
    bundle update


Setup
-----

  In order to use the YouTube library you must first register your application in the <a href="https://console.developers.google.com" target="_blank">Google Developers Console</a>.
  
##### New application
  - Browse to the Google Developers Console
  - Select "Create Project" from the navigation view
  - Enter a project name and project id and press the "Create" button
  - Once your new project is ready, click on the project and select "Enable an API" from the Project Dashboard
  - Enable the API named "YouTube Data API v3"
  - Select "Consent" in the "APIs & auth" menu in the left hand navigation bar     
  - Verify that "PRODUCT NAME" and "EMAIL ADDRESS" are set
  - Select "Credentials" in the "APIs & auth" menu in the left hand navigation bar   
  - Click on "Create new Client ID" in the OAuth section
  - Select "Installed application" under "APPLICATION TYPE" and "Other" as the "INSTALLED APPLICATION TYPE"
  - Record the "CLIENT ID" and "CLIENT SECRET" for the following steps 
  
##### Applications that have a Client ID and Client Secret
  - Navigate to the ubiquity-youtube/bin directory
  - Execute the following command: ./youtube_auth --client-id [Your Application Client ID] --client-secret [Your Application Client Secret]
  - If the web server is able to launch then a browser window will open with a consent screen otherwise you will be given the link to the consent screen.
    Accept the request and follow the instructions given to you after the consent screen.
    

##### Troubleshooting
  - If you get an error stating 'no application name' check the "PRODUCT NAME" and "EMAIL ADDRESS" are set in the 'Consent screen' section in the Project Dashboard.
    
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
    --tags TAG1,TAG2,TAG3        A list of tags to apply to the video.
    --help                       Display this screen.
        
#### Examples of Usage:

###### Accessing help.
  ./youtube_upload --help
  
###### Simple Usage
  ./youtube_upload --file-path /media/movie.mov --video-title "Title" --video-description "Description" --category-id 22 --privacy-status private --tags "tag 1,tag 2,tag 3" 
