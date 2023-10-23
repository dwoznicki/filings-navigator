# NOTE: I've divided up the application into two controllers: one for the API and one for the site.
# Realistically, we'd want more controllers for all but the smallest of applications.
Rails.application.routes.draw do
  # API routes
  get "/api/v1/get_filers", to: "api_v1#get_filers", defaults: {format: :json}
  get "/api/v1/get_filings", to: "api_v1#get_filings", defaults: {format: :json}
  get "/api/v1/get_awards", to: "api_v1#get_awards", defaults: {format: :json}
  get "/api/v1/count_awards", to: "api_v1#count_awards", defaults: {format: :json}
  get "/api/v1/get_recipients", to: "api_v1#get_recipients", defaults: {format: :json}
  # Website routes
  root "website#home"
  get "/", to: "website#home", defaults: {format: :html}
  get "/filer/:filer_id", to: "website#filer", defaults: {format: :html}
  get "/recipient/:recipient_id", to: "website#recipient", defaults: {format: :html}
end
