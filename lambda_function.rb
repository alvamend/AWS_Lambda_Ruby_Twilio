require 'json'
require 'twilio-ruby'

$client ||= Twilio::REST::Client.new ENV["ACCOUNT_SID"], ENV["AUTH_TOKEN"]

def send_message(user_data)
        $client.messages.create(
                from: ENV["TWILIO_PHONE_NUMBER"],
                to: user_data["phone_number"],
                body: "Hi, #{user_data["name"]}! You have been registered to our app"
        )
end

def lambda_handler(event:, context:)
        data = JSON.parse(event["body"])
        send_message(data)
        {
                statusCode: 200,
                body: JSON.generate("User created")
        }
end
