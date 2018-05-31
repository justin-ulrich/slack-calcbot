# Calcbot 

## Your friendly neighborhood basic math calculator for Slack.
If you have a basic math question while in Slack, direct message calcbot for an answer.  Go ahead, give it a try!
- This app is heavily based on the source code and setup steps of [Slack Ruby Onboarding Tutorial](https://github.com/slackapi/Slack-Ruby-Onboarding-Tutorial)

## Technical Requirements
* This app is written in Ruby, specifically v2.4.4. Be sure to have the correct version of Ruby installed or else update the Gemfile with your preferred version of Ruby.
* The package manager for this app is Bundler. Be sure to install it by running `gem install bundler`.
* If running this app locally, use [ngrok](https://ngrok.com/) to tunnel to localhost.

## Installing Dependencies
In the app folder, run **`bundle install`**.

## If Running Locally
Create a tunnel by running command `ngrok http 9292`.  This app uses sinatra which uses port 9292 by default.
Note the https URL listed by ngrok.  This will be important in later steps.

## Bot Setup in Slack
In your desired Slack workgroup, go to Account Settings.  In Settings, go to Configure Apps.  Follow the prompts to build a new Slack app.  You can give the app any name but it probably makes sense to just call it **calcbot**.
Be sure to do the following:
* Configure bot user, appropriately named like `calcbot`.
* Under OAuth & Permissions add a Redirect URL for <calcbot_server_url>/finish_auth where calcbot_server_url is the server hosting this application.  If using ngrok for localhost tunneling, use the https URL as noted in the previous section.
* For this next step, the application will need to be running (see next section).  Under Event Subscriptions add a Request URL for <calcbot_server_url>/events.  Subscribe to the following Bot Events:
  * app_mention
  * message.im
  
## Running the App
Before running the app, be sure to configure the following environment variables:
* SLACK_CLIENT_ID = Client ID, found in Basic Information - App Credentials
* SLACK_API_SECRET = Client Secret, found in Basic Information - App Credentials
* SLACK_REDIRECT_URI = <calcbot_server_url>/finish_auth
* SLACK_VERIFICATION_TOKEN = Verification Token, found in Basic Information - App Credentials

In the app folder, run **`rackup`**.

## Authentication
In a browser, go to <calcbot_server_url> and click the button to begin the OAuth flow.

## Bot Interaction in Slack
Calcbot responds to direct messages as well as mentions.
* In a direct message, ask Calcbot a basic math question, like **"What's 6 * 7?"**, and Calcbot will respond with an answer.
* In other channels where Calcbot is a member, reference Calcbot before asking questions, like **"@Calcbot 3 - 2"**.
* Calcbot supports the orders of operation in the following priority:
  1. Parentheses
  2. Multiplication and Division
  3. Addition and Subtraction
* Calcbot supports decimal point math
* Calcbot does not support powers or square roots (yet! Future enhancement??)

## Unit Testing
The Calculator class has unit tests that can be executed by running **ruby calculator.rb**.