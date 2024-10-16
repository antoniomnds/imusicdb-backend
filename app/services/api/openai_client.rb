# frozen_string_literal: true

module Api
  class OpenaiClient < Client
    class << self
      def send_prompt(prompt)
        new.create_completion(prompt)
      end
    end

    attr_reader :api_key

    def initialize
      @api_key = ENV["OPENAI_API_KEY"]
    end

    def create_completion(prompt)
      base_url = URI("https://api.openai.com/v1/chat/completions")
      headers = {
        "Authorization": "Bearer #{ api_key }",
        "Content-type": "application/json"
      }
      data = %Q(
      {
        "model": "gpt-4o-mini",
        "temperature": 0,
        "messages": [
          {
            "role": "system",
            "content": "You are a helpful assistant."
          },
          {
            "role": "user",
            "content": "#{ prompt }"
          }
        ],
        "response_format": {
          "type": "json_schema",
          "json_schema": {
            "name": "similar_albums",
            "schema": {
              "type": "object",
              "properties": {
                "albums": {
                  "type": "array",
                  "items": {
                    "type": "object",
                    "properties": {
                      "name": { "type": "string" },
                      "album_type": {
                        "type": "string",
                        "description": "The type of the album.",
                        "enum": ["album", "compilation", "single"]
                      },
                      "artists": {
                        "type": "array",
                        "items": {
                          "type": "object",
                          "properties": {
                            "name": {
                              "type": "string"
                            }
                          },
                          "required": ["name"],
                          "additionalProperties": false
                        }
                      },
                      "release_date": { "type": "string" },
                      "label": { "type": "string" },
                      "total_tracks": { "type": "number" },
                      "genres": {
                        "type": "array",
                        "items": {
                          "type": "object",
                          "properties": {
                            "name": {
                              "type": "string"
                            }
                          },
                          "required": ["name"],
                          "additionalProperties": false
                        }
                      }
                    },
                    "required": ["name", "album_type", "artists", "release_date", "label", "total_tracks", "genres"],
                    "additionalProperties": false
                  }
                }
              },
              "required": ["albums"],
              "additionalProperties": false
            },
            "strict": true
          }
        }
      })
      response = Net::HTTP.post(base_url, data, headers)
      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        content = data.dig("choices", 0, "message", "content") # content is another JSON
        JSON.parse(content)
      else
        log_response("Failed to get completion", response, :error)
      end
    end
  end
end
