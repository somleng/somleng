ActionController::Renderers.add(:wav) do |object, options = {}|
  # Adapted from https://github.com/refile/refile/blob/master/lib/refile/app.rb
  # def stream_file(file)
  # end

  filename, file = object.to_wav

  if file && filename
    if file.respond_to?(:path)
      path = file.path
    else
      path = Dir::Tmpname.create(params[:id]) {}
      IO.copy_stream(file, path)
    end

    send_file(
      path,
      {
        :filename => filename,
        :disposition => "inline",
        :type => Mime[:wav]
      }.merge(options)
    )
  else
    head(:not_found)
  end
end
