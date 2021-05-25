class ApplicationResponder < ActionController::Responder
  include Responders::HttpCacheResponder
end
