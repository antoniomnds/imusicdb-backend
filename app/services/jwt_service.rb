# frozen_string_literal: true

class JwtService
  HMAC_SECRET = Rails.application.secret_key_base.freeze

  class << self
    def encode(payload)
      JWT.encode(payload, HMAC_SECRET, "HS256")
    end

    # Its up to the caller to handle the errors JWT::ExpiredSignature (if exp claim is set) and JWT::DecodeError
    # Not defining the exp claim for now, so tokens should not expire.
    def decode(token)
      JWT.decode(token, HMAC_SECRET, true, { algorithm: "HS256" }).first
    end
  end
end
