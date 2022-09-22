defmodule BeaconBall.Notifications.Twilio do
  defp config() do
    Application.fetch_env!(:beacon_ball, :twilio_config)
  end

  defp twilio_phone_number do
    config() |> Keyword.get(:phone_number)
  end

  defp twilio_account_sid do
    config() |> Keyword.get(:account_sid)
  end

  defp twilio_auth_token do
    config() |> Keyword.get(:auth_token)
  end

  defp twilio_url do
    "https://api.twilio.com/2010-04-01/Accounts/#{twilio_account_sid()}/Messages.json"
  end

  # TODO: consider rate limiting of 1 SMS per second and queue notifications to be sent on an interval.
  def send_sms(phone_number, message) when is_binary(message) do
    body =
      URI.encode_query(%{
        "Body" => message,
        "From" => twilio_phone_number(),
        "To" => "+1#{phone_number}"
      })

    case HTTPoison.post(twilio_url(), body,
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
    "#{twilio_account_sid()}:#{twilio_auth_token()}"
    |> Base.encode64()
  end
end
