require "aws-sdk-s3"
require "open3"
require "securerandom"

module LambdaFunction
  class Handler
    def self.process(event:,context:)
      bucket = event.dig("Records", 0, "s3", "bucket", "name")
      key = CGI.unescape(event.dig("Records", 0, "s3", "object", "key"))
      mp3_object_key = Pathname(key).sub_ext(".mp3")
      s3_client = Aws::S3::Client.new

      Tempfile.create([SecureRandom.uuid, ".wav"]) do |raw_file|
        s3_client.get_object(bucket: bucket, key: key, response_target: raw_file.path)

        Tempfile.create([SecureRandom.uuid, ".mp3"]) do |mp3_file|
          convert_to_mp3(raw_file, mp3_file)

          s3_client.put_object(bucket: bucket, key: mp3_object_key.to_s, body: File.open(mp3_file))
        end
      end
    end

    def self.convert_to_mp3(raw_file, mp3_file)
      _stdout_str, error_str, status = Open3.capture3("ffmpeg", "-y", "-i", raw_file.path, mp3_file.path)
      raise StandardError, error_str unless status.success?
    end
  end
end
