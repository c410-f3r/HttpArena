defmodule HttparenaPhoenix.Router do
  use Phoenix.Router

  scope "/", HttparenaPhoenix do
    get "/pipeline", BenchController, :pipeline
    get "/baseline11", BenchController, :baseline11
    post "/baseline11", BenchController, :baseline11
    get "/baseline2", BenchController, :baseline2
    get "/json", BenchController, :json
    get "/compression", BenchController, :compression
    get "/db", BenchController, :db
    post "/upload", BenchController, :upload
    get "/static/:filename", BenchController, :static_file
  end
end
