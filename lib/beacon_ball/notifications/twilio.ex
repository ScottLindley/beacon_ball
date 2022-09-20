defmodule BeaconBall.Notifications.Twilio do
  @phone_number :"#{System.get_env("TWILIO_PHONE_NUMBER")}"
  @account_sid :"#{System.get_env("TWILIO_ACCOUNT_SID")}"
  @auth_token :"#{System.get_env("TWILIO_AUTH_TOKEN")}"
  @url :"https://api.twilio.com/2010-04-01/Accounts/#{@account_sid}/Messages.json"

  # TODO: consider rate limiting of 1 SMS per second and queue notifications to be sent on an interval.
  def send_sms(phone_number, message) when is_binary(message) do
    body =
      URI.encode_query(%{
        "Body" => message,
        "From" => @phone_number,
        "To" => "+1#{phone_number}"
      })

    case HTTPoison.post(@url, body,
           Authorization: "Basic #{gen_auth_token()}",
           "Content-Type": "application/x-www-form-urlencoded"
         ) do
      {:ok, %HTTPoison.Response{status_code: 201}} ->
        {:ok}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "#{status_code}: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      _ ->
        {:error, "unexpected error"}
    end
  end

  defp gen_auth_token() do
    "#{@account_sid}:#{@auth_token}"
    |> Base.encode64()
  end
end
