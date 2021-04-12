require "rspec_api_documentation/dsl"

RspecApiDocumentation.configure do |config|
  config.api_name = "Somleng Twilreapi API Documentation"
  config.api_explanation = <<~HEREDOC
    # Introduction

    Somleng Twilreapi is an Open Source implementation of [Twilio's REST API](https://www.twilio.com/docs/voice/api).
    Currently it only supports a tiny subset of Twilio's REST API. More features may be added later as the need arises.

    ## Make an HTTP Request to Somleng Twilreapi

    There are a lot of ways you can make an HTTP request to Somleng Twilreapi.
    You can make a raw HTTP request in your code (for example, using a module like [got in NodeJS](https://www.npmjs.com/package/got)) or by using a tool like [Postman](https://www.postman.com/).
    You might find it easier to use the [Twilio Helper Library or SDK](https://www.twilio.com/docs/libraries) for your preferred programming language.

    These libraries can be usually be used with Somleng Twilreapi by overriding the URL parameter from `api.twilio.com` to `twilreapi.somleng.org` or your own host.

    ## Credentials

    All requests to Somleng Twilreapi need to be authenticated. Twilreapi using HTTP basic auth, which use the following username/password schemes:

    ### Account SID and Auth Token

    The account SID and auth token are the master keys to your account.

    | Username   | Password  |
    | ---------- | --------- |
    | AccountSid | AuthToken |
  HEREDOC

  config.format = [:slate,  "OpenApi"]
  config.configurations_dir = Rails.root.join("doc", "config")
  config.curl_host = "https://twilreapi.somleng.org"
  config.curl_headers_to_filter = ["Host", "Cookie"]

  config.request_headers_to_include = []
  config.response_headers_to_include = []
  config.keep_source_order = false
  config.disable_dsl_status!

  # https://github.com/zipmark/rspec_api_documentation/pull/458
  config.response_body_formatter = proc do |content_type, response_body|
    if content_type =~ %r{application/.*json}
      JSON.pretty_generate(JSON.parse(response_body))
    else
      response_body
    end
  end
end
