class MP3Converter
  attr_reader :blob

  def initialize(blob)
    @blob = blob
  end

  def convert_to_mp3
    download_blob_to_tempfile { |file| ffmpeg_convert(file) }
  end

  private

  def ffmpeg_convert(file)
    output_file = Pathname("#{file.path}.mp3")
    instrument(File.basename(ffmpeg_path)) do
      IO.popen([ffmpeg_path, "-i", file.path, output_file.to_s]) { |_| }
    end
    output_file
  rescue Errno::ENOENT
    logger.info "Skipping conversion because ffmpeg isn't installed"
    nil
  end

  def ffmpeg_path
    ActiveStorage.paths[:ffmpeg] || "ffmpeg"
  end

  def download_blob_to_tempfile(&block)
    blob.open(tmpdir:, &block)
  end

  def tmpdir
    Dir.tmpdir
  end

  def instrument(converter, &block)
    ActiveSupport::Notifications.instrument("mp3_converter", converter:, &block)
  end

  def logger
    ActiveStorage.logger
  end
end
