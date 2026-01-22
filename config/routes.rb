Rails.application.routes.draw do
  root "weather#index"
  post "/weather", to: "weather#show", as: :weather
end
