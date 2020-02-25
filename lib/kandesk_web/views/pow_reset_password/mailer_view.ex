defmodule KandeskWeb.PowResetPassword.MailerView do
  use KandeskWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset password link"
end
