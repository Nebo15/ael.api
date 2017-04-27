defmodule Ael.Web do
  @moduledoc """
  A module defining __using__ hooks for controllers,
  views and so on.

  This can be used in your application as:

      use Ael.Web, :controller
      use Ael.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: Ael.Web
      import Plug.Conn
      import Ael.Web.Router.Helpers
    end
  end

  def view do
    quote do
      # Import convenience functions from controllers
      import Phoenix.View
      import Phoenix.Controller, only: [view_module: 1]
      import Ael.Web.Router.Helpers

      @view_resource String.to_atom(Phoenix.Naming.resource_name(__MODULE__, "View"))

      @doc "The resource name, as an atom, for this view"
      def __resource__, do: @view_resource
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
