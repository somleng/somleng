require "rspec_api_documentation/dsl"

RspecApiDocumentation.configure do |config|
  config.api_name = "Somleng API Documentation"

  config.format = [:slate]
  config.curl_host = ""
  config.curl_headers_to_filter = %w[Host Cookie]

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

      Somleng is an Open Source Cloud Communications Platform as a Service (CPaaS). It contains an open source implementation of [Twilio's REST API](https://www.twilio.com/docs/voice/api).
      Currently it only supports a tiny subset of Twilio's REST API. More features may be added in the future.

      This API documentation is intended for users of the REST API.

      ## Make an HTTP Request to Somleng

      There are a lot of ways you can make an HTTP request to Somleng.
      You can make a raw HTTP request in your code (for example, using a module like [got in NodeJS](https://www.npmjs.com/package/got)) or by using a tool like [Postman](https://www.postman.com/).
      You might find it easier to use the [Twilio Helper Library or SDK](https://www.twilio.com/docs/libraries) for your preferred programming language. These libraries can be usually be used with Somleng by overriding the URL parameter from `api.twilio.com` to `api.somleng.org` or that of your own host.

      ## Credentials

      All requests to Somleng need to be authenticated. Somleng using HTTP basic auth, which use the following username/password schemes:

      ### Account SID and Auth Token

      The account SID and auth token are the master keys to your account.

      | Username   | Password  |
      | ---------- | --------- |
      | AccountSid | AuthToken |
    HEREDOC

    conf.filter = :twilio_api
    conf.docs_dir = Rails.root.join("doc/twilio_api")
  end

  config.define_group :carrier_api do |conf|
    conf.api_explanation = <<~HEREDOC
      # Carrier Documentation

      This documentation is intended for carriers. The documentation for Somleng's Open Source implementation of Twilio's REST API is available [here](../twilio_api).

      ## Configuring Outbound SIP Trunks

      To setup outbound dialing you create an Outbound SIP trunk(s) via the [Carrier Dashboard](https://dashboard.somleng.org).
      When configuring an Outbound SIP trunk, you specify your host as either a fully qualified domain name (FQDN) or IP Address.
      This tells Somleng to send outbound calls to your this host using the configured dial string.
      Somleng will send SIP and RTP from NATed from the IP address below:

      | NAT IP          |
      | --------------- |
      | `13.250.230.15` |

      You should allow this IP address on your firewall.

      ## Configuring Inbound SIP Trunks

      To setup inbound dialing you create an Inbound SIP Trunk via the [Carrier Dashboard](https://dashboard.somleng.org).
      When configuring an Inbound SIP trunk, you specify your source IP address from which you will send SIP from.
      You can then send SIP to the following endpoints. We recommend that you use `sip.somleng.org` if possible for high-availability.

      | Endpoint          |
      | ---------------   |
      | `sip.somleng.org` |
      | `52.74.4.205`     |
      | `18.136.239.28`   |
      | `3.0.30.251`      |

      ## RTP

      RTP from Somleng is sent through a NAT Gateway. This means that the ports specified in the SDP in the SIP Invite from Somleng are unreachable.
      In order to work-around this problem, it is required that you setup [Symmetric Latching](https://github.com/somleng/somleng-switch/wiki/SIP-NAT) on your device/software.

      Symmetric RTP means that the IP address and port pair used by an outbound RTP flow is reused for the inbound flow.
      The IP address and port are learned when the initial RTP flow is received on your device. The flow's source address and port are latched onto and used
      as the destination for the RTP sourced by the other side of the call. The IP address and port in the c line and m line respectively in the SDP message are ignored.

      If your device does not support symmetric latching please contact us for assistance.

      # Carrier API

      The Carrier API is intended for carriers who need to automate provisioning of carrier resources (e.g. Accounts) rather that using the dashboard.
      This API is written according to the [JSON API Specification](https://jsonapi.org/). We recommend using a [JSON API Client](https://jsonapi.org/implementations/) for consuming this API.

      ## Authentication

      This API uses Bearer authentication. You must include your API key in the Authorization header for all requests. Your API key is available on the [Carrier Dashboard](https://dashboard.somleng.org/carrier_settings).

      ## Webhooks

      Somleng uses webhooks to notify your application when an event happens in your account.
      Somleng signs the webhook events it sends to your endpoint by including a signature in each event's `Authorization` header.
      This allows you to verify that the events were sent by Somleng, not by a third party.

      All requests are signed using [JSON Web Token (JWT)](https://jwt.io/) Bearer authentication, according to the HS256 (HMAC-SHA256) algorithm.

      You should verify the events that Somleng sends to your Webhook endpoints. Here's an example in Ruby:

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
