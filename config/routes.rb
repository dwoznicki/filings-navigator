Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "/api/v1/filers", to: "api_v1#get_filers", defaults: {format: :json}
  get "/api/v1/filings", to: "api_v1#get_filings", defaults: {format: :json}
  get "/api/v1/awards", to: "api_v1#get_awards", defaults: {format: :json}
  get "/api/v1/recipients", to: "api_v1#get_recipients", defaults: {format: :json}
end
