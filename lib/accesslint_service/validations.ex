defmodule AccesslintService.Validations do
  @doc """
    Validates a string can be parsed as an URI, having scheme and host.
  """
  def validate_uri(nil) do
    { :error, nil }
  end

  def validate_uri(str) do
    case URI.parse(str) do
      %URI{ scheme: nil } -> { :error, str }
      %URI{ host:   nil } -> { :error, str }
      _                   -> { :ok, str }
    end
  end
end
