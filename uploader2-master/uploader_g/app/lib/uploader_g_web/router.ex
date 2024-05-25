defmodule UploaderGWeb.Router do
  use UploaderGWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {UploaderGWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UploaderGWeb do
    pipe_through :browser

    live "/", UnitLive.Index, :index

    # get "/logs", UploaderGController, :logs

    live "/units", UnitLive.Index, :index
    live "/units/new", UnitLive.Index, :new
    live "/units/:id/edit", UnitLive.Index, :edit

    live "/units/:id", UnitLive.Show, :show
    live "/units/:id/show/edit", UnitLive.Show, :edit

    live "/units/case/online", UnitLive.Index, :list_online
    live "/units/case/offline", UnitLive.Index, :list_offline
    live "/units/case/pending", UnitLive.Index, :list_pending

    live "/transmissions", TransmissionLive.Index, :index
    live "/transmissions/new", TransmissionLive.Index, :new
    live "/transmissions/:id/edit", TransmissionLive.Index, :edit

    live "/transmissions/:id", TransmissionLive.Show, :show
    live "/transmissions/:id/show/edit", TransmissionLive.Show, :edit

    live "/logs", LogLive.Index, :index
    live "/logs/case/error", LogLive.Index, :list_error
    live "/logs/case/info", LogLive.Index, :list_info

    live "/logs/new", LogLive.Index, :new
    live "/logs/:id/edit", LogLive.Index, :edit

    live "/logs/:id", LogLive.Show, :show
    live "/logs/:id/show/edit", LogLive.Show, :edit

    live "/dashboard", DashboardLive.Index, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", UploaderGWeb do
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

      live_dashboard "/dashboard0", metrics: UploaderGWeb.Telemetry
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
