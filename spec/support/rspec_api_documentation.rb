require "rspec_api_documentation/dsl"

RspecApiDocumentation.configure do |config|
  config.api_name = "Somleng API Documentation"

  config.format = [:slate]
  config.curl_host = ""
  config.curl_headers_to_filter = %w[Host Cookie Version]

  config.request_headers_to_include = []
  config.response_headers_to_include = []

  config.request_body_formatter = proc do |params|
    if params.present?
      if params.key?("data")
        JSON.pretty_generate(params)
      else
        params
      end
    end
  end

  config.keep_source_order = false
  config.disable_dsl_status!

  config.define_group :twilio_api do |conf|
    conf.api_explanation = <<~HEREDOC
      # Introduction

      Dive into our full API Reference Documentation and seamlessly integrate Voice and SMS functionalities into your website or application.
      This API uses HTTP verbs and a RESTful endpoint structure. Your Account SID and Auth Token is used as the API Authorization framework.
      Request and response payloads are formatted as JSON using UTF-8 encoding and URL encoded values.

      ## Make an HTTP Request

      There are a lot of ways you can make an HTTP request to Somleng.
      You can use a [Helper Library or SDK](#helper-libraries) for your preferred programming language or you can make a raw HTTP request in your code by using a tool like [Postman](https://www.postman.com/).

      ## Credentials

      All requests to Somleng need to be authenticated. Somleng using HTTP basic auth, which use the following username/password schemes:

      ### Account SID and Auth Token

      The account SID and auth token are the master keys to your account.

      | Username   | Password  |
      | ---------- | --------- |
      | AccountSid | AuthToken |

      ### Store Your Somleng Credentials Securely

      It's important to keep credentials such as your Somleng Account SID and Auth token secure by storing them in a way that prevents unauthorized access.
      One common method is to store them in environment variables which are then accessed from your app.
      This keeps them out of code and other places where credentials don't belong.

      On the right is an example in Node.js ---->

      ```js
      const accountSid = process.env.SOMLENG_ACCOUNT_SID;
      const authToken = process.env.SOMLENG_AUTH_TOKEN;
      const client = require('somleng')(accountSid, authToken);

      // Make API calls here...
      ```

      ## Helper Libraries

      The following is a list of officially supported helper libraries for Somleng. Please refer to the documentation in each library for more details.

      * [somleng-node](https://github.com/somleng/somleng-node)

      ## Demo Applications

      The following is a list of demo applications which you can use to get started with Somleng.

      * [Somleng Demo Next.js](https://github.com/somleng/somleng-demo-nextjs)
    HEREDOC

    conf.filter = :twilio_api
    conf.docs_dir = Rails.root.join("doc/twilio_api")
  end

  config.define_group :carrier_api do |conf|
    conf.api_explanation = <<~HEREDOC
      # Carrier API

      This documentation is intended for carriers as defined in the [carrier documentation](https://www.somleng.org/carrier_documentation.html). The API documentation for Somleng's Open Source implementation of Twilio's REST API is available [here](../twilio_api).

      The Carrier API is intended for carriers who need to automate provisioning of carrier resources (e.g. Accounts) rather that using the dashboard.
      This API is written according to the [JSON API Specification](https://jsonapi.org/). We recommend using a [JSON API Client](https://jsonapi.org/implementations/) for consuming this API.

      ## Authentication

      This API uses Bearer authentication. You must include your API key in the Authorization header for all requests. Your API key is available on the [Carrier Dashboard](https://dashboard.somleng.org/carrier_settings).

      ## Webhooks

      Somleng uses webhooks to notify your application when an event happens in your account.
      Somleng signs the webhook events it sends to your endpoint by including a signature in each event's `Authorization` header.
      This allows you to verify that the events were sent by Somleng, not by a third party.

      All requests are signed using [JSON Web Token (JWT)](https://jwt.io/) Bearer authentication, according to the HS256 (HMAC-SHA256) algorithm.

      You should verify the events that Somleng sends to your Webhook endpoints. On the right is an example in Ruby ---->

      ```ruby
      JWT.decode(
        request.headers["Authorization"].sub("Bearer ", ""),
        "[your-webhook-signing-secret]",
        true,
        algorithm: "HS256",
        verify_iss: true,
        iss: "Somleng"
      )
      ```

    HEREDOC

    conf.filter = :carrier_api
    conf.docs_dir = Rails.root.join("doc/carrier_api")
  end

  # https://github.com/zipmark/rspec_api_documentation/pull/458
  config.response_body_formatter = proc do |content_type, response_body|
    if content_type =~ %r{application/.*json}
      JSON.pretty_generate(JSON.parse(response_body))
    else
      response_body
    end
  end
end
