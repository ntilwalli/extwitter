defmodule ExTwitter.API.Auth do
  @moduledoc """
  Provides Authorization and Authentication API interfaces.
  """
  import ExTwitter.API.Base

  def request_token() do
  	oauth = ExTwitter.Config.get_tuples |> verify_params
  	consumer = {oauth[:consumer_key], oauth[:consumer_secret], :hmac_sha1}
  	{:ok, {{_, 200, _}, _headers, body}} = ExTwitter.OAuth.request(:post, request_url("oauth/request_token"), [], consumer, [], [])

    Elixir.URI.decode_query(to_string body)
      |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
      |> Enum.into(%{})
      |> ExTwitter.Parser.parse_request_token
  end

  def authorize_url(oauth_token, redirect_url \\ nil, options \\ %{}) do
    args = Map.merge(%{oauth_token: oauth_token}, options)

    if redirect_url do
    	args = Map.merge(%{oauth_callback: redirect_url}, args)
    end

    {:ok, request_url("oauth/authorize?" <> Elixir.URI.encode_query(args)) |> to_string}
  end
end