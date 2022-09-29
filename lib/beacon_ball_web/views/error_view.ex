defmodule BeaconBallWeb.ErrorView do
  use BeaconBallWeb, :view

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("401.html", _assigns) do
    "Unauthorized"
  end
end
