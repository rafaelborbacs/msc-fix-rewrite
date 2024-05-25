defmodule UploaderTWeb.Router do
  use UploaderTWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {UploaderTWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UploaderTWeb do
    # It is necessary to have a wider comprehension of the meaning of the next line.
    # If such line was found in the scope below, it would break the requests of the spoken scope.
    pipe_through :browser

    live "/", ModalityLive.Index, :index
    # get "/uploader_t", UIController, :uploader_t
    # get "/uploader_r", UIController, :uploader_r
    # get "/modalidades", UIController, :modalidades

    live "/modalities", ModalityLive.Index, :index
    live "/modalities/new", ModalityLive.Index, :new
    live "/modalities/:id/edit", ModalityLive.Index, :edit

    live "/modalities/:id", ModalityLive.Show, :show
    live "/modalities/:id/show/edit", ModalityLive.Show, :edit

    live "/transmission", TransmissionLive.Index, :index
    live "/transmission/new", TransmissionLive.Index, :new
    live "/transmission/:id/edit", TransmissionLive.Index, :edit

    live "/transmission/:id", TransmissionLive.Show, :show
    live "/transmission/:id/show/edit", TransmissionLive.Show, :edit

    live "/source_config", SourceLive.Index, :index
    live "/destination_config", DestinationLive.Index, :index
  end

  scope "/api/v1/", UploaderTWeb do
    resources "/modalidades", ModalidadeController
    get "/config/:file", ConfigController, :get
    post "/config/:file", ConfigController, :set
  end

  # Other scopes may use custom stacks.
  # scope "/api", UploaderTWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: UploaderTWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
