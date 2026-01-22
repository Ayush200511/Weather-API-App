class WeatherService
  include HTTParty
  base_uri "https://api.openweathermap.org/data/2.5"

  def self.fetch(city)
    api_key = ENV["OPENWEATHER_API_KEY"]

    # 🔍 DEBUG (TEMPORARY)
    Rails.logger.info "DEBUG API KEY => #{api_key.inspect}"

    if api_key.nil? || api_key.strip.empty?
      return { error: "API key not configured" }
    end

    current_response = get(
      "/weather",
      query: {
        q: city,
        units: "metric",
        appid: api_key
      }
    )

    return { error: "City not found" } unless current_response.code == 200

    forecast_response = get(
      "/forecast",
      query: {
        q: city,
        units: "metric",
        appid: api_key
      }
    )

    {
      current: parse_current(current_response.parsed_response),
      forecast: parse_forecast(forecast_response.parsed_response)
    }
  end

  def self.parse_current(data)
    {
      city: data["name"],
      country: data["sys"]["country"],
      temp: data["main"]["temp"],
      condition: data["weather"][0]["description"].capitalize,
      icon: data["weather"][0]["icon"],
      humidity: data["main"]["humidity"],
      wind: data["wind"]["speed"]
    }
  end

  def self.parse_forecast(data)
    return [] unless data["list"]

    data["list"]
      .select { |item| item["dt_txt"].include?("12:00:00") }
      .first(5)
      .map do |item|
        {
          date: Date.parse(item["dt_txt"]).strftime("%A"),
          temp: item["main"]["temp"],
          icon: item["weather"][0]["icon"]
        }
      end
  end
end
