require 'sinatra/base'
require 'slack-ruby-client'
require './calculator'

# This class contains all of the webserver logic for processing incoming requests from Slack.
class API < Sinatra::Base
  # This is the endpoint Slack will post Event data to.
  post '/events' do
    # Extract the Event payload from the request and parse the JSON
    request_data = JSON.parse(request.body.read)
    # Check the verification token provided with the request to make sure it matches the verification token in
    # your app's setting to confirm that the request came from Slack.
    unless SLACK_CONFIG[:slack_verification_token] == request_data['token']
      halt 403, "Invalid Slack verification token received: #{request_data['token']}"
    end

    case request_data['type']
      # When you enter your Events webhook URL into your app's Event Subscription settings, Slack verifies the
      # URL's authenticity by sending a challenge token to your endpoint, expecting your app to echo it back.
      # More info: https://api.slack.com/events/url_verification
      when 'url_verification'
        request_data['challenge']

      when 'event_callback'
        # Get the Team ID and Event data from the request object
        team_id = request_data['team_id']
        event_data = request_data['event']

        # Events have a "type" attribute included in their payload, allowing you to handle different
        # Event payloads as needed.
        case event_data['type']
          when 'message'
            # Event handler for messages, including Share Message actions
            Events.message(team_id, event_data)
		  when 'app_mention'
			# Event handler for messages that mention bot
			Events.message(team_id, event_data)
          else
            # In the event we receive an event we didn't expect, we'll log it and move on.
            puts "Unexpected event:\n"
            puts JSON.pretty_generate(request_data)
        end
        # Return HTTP status code 200 so Slack knows we've received the Event
        status 200
    end
  end
end

# This class contains all of the Event handling logic.
class Events
  def self.message(team_id, event_data)
    user_id = event_data['user']
	channel = event_data['channel']
    # Don't process messages sent from our bot user
    unless user_id == $teams[team_id][:bot_user_id]
	  begin
	  	c = Calculator.new
	    text = event_data['text'].sub /<@#{$teams[team_id][:bot_user_id]}>/, ''
		value = c.calculate(text)
		self.send_response(team_id, channel, value)
	  rescue StandardError => error
		self.send_response(team_id, channel, "Oops, something went wrong: #{error}")
	  end
    end
  end
  
  def self.send_response(team_id, channel, text)
	$teams[team_id]['client'].chat_postMessage(
      as_user: 'true',
      channel: channel,
      text: text
    )
  end
end
