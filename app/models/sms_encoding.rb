class SMSEncoding
  attr_reader :encoding_detector

  Result = Struct.new(:segments, :encoding, keyword_init: true)

  def initialize(encoding_detector: default_encoding_detector)
    @encoding_detector = encoding_detector
  end

  def detect(body)
    detector = encoding_detector.new(body)
    Result.new(
      segments: detector.concatenated_parts,
      encoding: detector.ascii? ? "GSM" : "UCS2"
    )
  end

  private

  def default_encoding_detector
    SmsTools.use_ascii_encoding = true
    SmsTools.use_gsm_encoding = false
    SmsTools::EncodingDetection
  end
end
