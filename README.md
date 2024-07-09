# Integrate AWS Lambda function with API GATEWAY, and Twilio to send SMS
In this project, we will be using Ruby, specifically version 3.3

<h2>Workflow:</h2>
<p>In this particular scenario, we will be using the following workflow:</p>
<strong>Client -> API Gateway -> Lambda Function -> SMS to the user</strong>

<section>
  <h2>Create a Lambda Function</h2>
  <p>Probably you're already familiarized with Lambda functions, they are serverless, so there's no need to deploy a server to make requests to them, only include the logic that you want to execute</p><br/>
  <ol>
    <li>Log into AWS Console</li>
    <li>
      <p>Look for Lambda on services</p>
      <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/f42c578c-1dab-408c-b950-19b452c2fa48" /> 
    </li>
    <li>Click on "Create function", In this particular example, we will be using Author from scratch.</li>
    <li>Select Ruby 3.3 after you set a name</li>
    <li>
      <p>Click on "Create function"</p>
      <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/a4cc7399-8855-4ba0-8a5f-b2558fcf6b2b" />
    </li>
  </ol>
  <p>Once the function is created, you can click on it and it should look like this:</p>
  <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/2f1e8eb0-5922-4d6a-8d1b-6d9bfb6044b7" />
  <p>Function is already created, but the logic that it contains only shows a Hello World from it, we want to change it once we have integrated it with our API Gateway</p>
</section>

<section>
  <h2>Create API Gateway</h2>
  <p>API Gateway is like a proxy, it will receive the requests from the client, and will route the requests to the functions assigned to the resource</p><br/>
  <ol>
    <li>
      <p>Look for API GAteway on services</p>
    </li>
    <li>Click on "APIs", we will create a REST API</li>
    <li>
      <p>Select New API, as we will build it from scratch</p>
      <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/8b41e6e3-6f23-4f3e-9fb9-a520216ee91b" />
    </li>
    <li>Click on "Create API" and we should be good to integrate it with our Lambda Function</li>
  </ol>
</section>

<section>
  <h2>Integrate API Gateway with Lambda</h2>
  <p>The first thing we need to create is a resource. You can define a resource named "Users", it can contain methods to:</p>
  <ul>
    <li>Create a user (POST)</li>
    <li>Get all users (GET)</li>
    <li>Update a user (PUT)</li>
    <li>Delete a user (DELETE)</li>
  </ul>
  <p>In this example, we will simulate to create a user and send a SMS to let him know that his account has been created</p>
  <ol>
    <li>Click on "Create Resource"</li>
    <li>
      <p>Set a resource name, I will name it "users"</p>
      <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/9fe8c8ad-5434-4526-890c-beb77b29a2d2" />
    </li>
    <li>
      <p>Once the resource is created, then we can add methods to it, in this particular example, we will use POST, as we will be sending data in the body and select the created Lambda function</p>
      <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/57d0d4ff-e964-4007-9eff-5e27f4e40240" />
    </li>
    <li><strong>Make sure to enable "Lambda proxy integration"</strong></li>
    <li>Click on "Create Method"</li>
  </ol>
  <p>We're not finished yet, as we haven't deployed the API yet, the last step to be able to communicate with the API GW, is to click on Deploy API. Create a "New stage" and give it a name, I chose "dev"</p>
  <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/e0195446-129a-491d-92f3-20f20fc9b970" />
  <p>Now the API is deployed, you will see the following info:</p>
  <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/215408df-bfa4-449d-aa7d-8a7c14827539" />
  <p>We will use "Invoke URL" to send requests to the API GW. Give it a try in Postman, you should receive the Hello world from the lambda function</p>
  <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/21c81479-14bb-488b-8819-07454d432133" />
</section>

<section>
  <h2>Update function with new code</h2>
  <p>Now the API is deployed and ready to use, but we want to integrate it with an SMS provider like Twilio in this example. So we would like to do the following to the function</p>
  <ol>
    <li>Include gems</li>
    <li>Update its code</li>
  </ol>

  <h3>Create project and add gems</h3>
  <p>1. Create a folder for our project</p>
    <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/f2124afe-ef5c-44bc-8625-11d6f45d3262" />
  <p>2. Let's move to that folder and let's run "bundle init" to generate a Gemfile (Due to permissions errors in my terminal, I'll use root account instead)</p>
  <p>3. If you're using Ubuntu or linux, you can modify the Gemfile with nano and let's add twilio-ruby gem</p>
  <a href="https://github.com/twilio/twilio-ruby">Please refer to twilio's documentation</a>
    
```
source "https://rubygems.org"
gem 'twilio-ruby', '~> 7.2.3'
```

  <p>4. Let's install the gems by running the following commands on terminal</p>

```
bundle config set --local path 'vendor/bundle' && bundle install
```

  <p>5. Then, we can run "bundle config set --local system 'true'"</p>
  <p>6. Once the gems are installed, we can create a new .rb file, for example "lambda_function.rb", it will contain the logic and what we would like to do</p>
  
```
require 'json'
require 'twilio-ruby'

#This $client variable is how we initialize our client
$client ||= Twilio::REST::Client.new ENV["ACCOUNT_SID"], ENV["AUTH_TOKEN"]

#This method will send messages to the user using the data sent by the API Gateway in the body
def send_message(user_data)
        $client.messages.create(
                from: ENV["TWILIO_PHONE_NUMBER"],
                to: user_data["phone_number"],
                body: "Hi, #{user_data["name"]}! You have been registered to our app"
        )
end

#This is the lambda handler, the code is executed from here. the event: is what we receive from the API Gateway, in this case we're parsing the body that contains the information we're looking for
def lambda_handler(event:, context:)
        data = JSON.parse(event["body"])
        #Here we invoke our method to send the mssage and then return the response to the API Gateway
        send_message(data)
        {
                statusCode: 200,
                body: JSON.generate("User created")
        }
end

```

  <p>7.Almost done, but we need to zip the dependencies and the actual function in a single .zip file and then upload it to our lambda function in AWS. Please refer to this guide: <a href="https://docs.aws.amazon.com/lambda/latest/dg/ruby-package.html">Working with .zip file archives for Ruby Lambda functions</a></p>

```
zip -r lambda_function.zip lambda_function.rb vendor
```

  <p>8. Probably, you will see that the file is larger than 10MB, so you need to create first an S3 bucket and upload the file there. I already created a bucket, so I'll upload the file there</p>
  <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/2f9c2f5e-91ec-4fc4-8777-62e80cf2991d" />

  <p>9. Once uploaded, you can copy object URL of the file</p>
  <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/a2f7f1f1-fb90-4ccd-a697-a378e2cbb2e6" />

  <p>10. Upload the file from S3 location in the Lambda function</p>
  <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/4644731f-c3ba-4bb7-bbf9-11a42cd75135" />

  <p>Now, our last step in the lambda function, is to include our environment variables, but we need to generate them from our Twilio Account</p>
  <p>Under Configuration -> Environment Variables add them</p>
  <img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/081c1057-1513-4bc1-8bbf-102537a03177" /> 

</section>

<p>Finally, we can test using Postman, in the body, let's include the name and phone_number in a json format. And we should receive a 200Ok with the message included in the lambda function. Most important, we should receive also the Message in our phone</p>
<img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/efd91be2-9d0a-4c2b-806a-2d47b922cf05" />
<img src="https://github.com/alvamend/AWS_Lambda_Ruby_Twilio/assets/51424964/ba1d50ab-9540-4424-98a6-ee30baa20bf4" /> 
<br/>
<a href="https://www.twilio.com/login">Link to Twilio's Console</a>
