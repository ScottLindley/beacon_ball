# This file is not directly used anywhere, but exists as an example for
# "./dev.secret.exs" which is needed for development.
# Copy the contents below into "./dev.secret.exs" and fill in the values.
import Config

config :beacon_ball, :twilio_config,
  phone_number: "",
  account_sid: "",
  auth_token: ""
