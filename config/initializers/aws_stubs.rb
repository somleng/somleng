if Rails.env.development? || Rails.env.test?
  ENV["AWS_DEFAULT_REGION"] ||= "ap-southeast-1"
  ENV["AWS_ACCESS_KEY_ID"] ||= "access-key-id"
  ENV["AWS_SECRET_ACCESS_KEY"] ||= "secret-key"

  Aws.config[:sqs] ||= {
    stub_responses: {
      send_message: Aws::SQS::Client.new.stub_data(:send_message)
    }
  }

  Aws.config[:polly] ||= {
    stub_responses: {
      describe_voices: {
        voices: [
          {
            gender: "Female", id: "Vitoria", language_code: "pt-BR",
            supported_engines: %w[neural standard]
          },
          {
            gender: "Female", id: "Mia", language_code: "es-MX",
            supported_engines: %w[generative neural standard]
          },
          {
            gender: "Female", id: "Celine", language_code: "fr-FR",
            supported_engines: %w[generative standard]
          },
          {
            gender: "Female", id: "Zhiyu", language_code: "cmn-CN",
            supported_engines: %w[neural standard]
          },
          {
            gender: "Female", id: "Hala", language_code: "ar-AE",
            supported_engines: %w[neural]
          },
          {
            gender: "Female", id: "Zayd", language_code: "ar-AE",
            supported_engines: %w[neural]
          },
          {
            gender: "Female", id: "Zeina", language_code: "arb",
            supported_engines: %w[standard]
          },
          {
            gender: "Female", id: "Hiujin", language_code: "yue-CN",
            supported_engines: %w[neural]
          },
        ]
      }
    }
  }
end
