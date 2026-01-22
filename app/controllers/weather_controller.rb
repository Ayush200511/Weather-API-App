class WeatherController < ApplicationController
  def index
  end

  def show
    city = params[:city]

    if city.blank?
      flash[:alert] = "Please enter a city"
      redirect_to root_path
      return
    end

    result = WeatherService.fetch(city)

    if result[:error]
      flash[:alert] = result[:error]
      redirect_to root_path
    else
      @current = result[:current]
      @forecast = result[:forecast]

      # 👇 THIS IS THE KEY LINE
      render :index
    end
  end
end
