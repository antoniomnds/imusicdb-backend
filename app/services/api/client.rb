# frozen_string_literal: true

module Api
  class Client
    protected

    def log_response(message, response, type = :info)
      return unless response.is_a? Net::HTTPResponse

      log_message = %Q(
          ERROR: #{message}
          Response message: #{ response.message }
          Response body: #{ response.body }
        )
      if type == :info
        Rails.logger.info(log_message)
      else
        Rails.logger.error(log_message)
      end
    end
  end
end
