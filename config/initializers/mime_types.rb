# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.register("audio/x-wav", :wav)
Mime::Type.register("audio/mpeg", :mp3)
Mime::Type.register(
  "application/vnd.api+json",
  :json,
  %w[application/vnd.api+json text/x-json application/json]
)
