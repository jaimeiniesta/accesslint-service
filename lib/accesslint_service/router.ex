defmodule AccesslintService.Router do
  use Trot.Router

  alias AccesslintService.{Auditor,Validations}
  import Validations

  @doc """
    Shows a welcome screen with instructions.
  """
  get "/" do
    """
    Hello from AccessLint Service!
    ##############################

    To check a page for accessibility issues, do it like this:

    http://accesslint-service-demo.herokuapp.com/check?url=http://validationhell.com

    This will check the passed url using accesslint-cli and return
    the issues found in JSON format.
    """
  end

  @doc """
    Checks the given url using accesslint-cli and returns the results as JSON.
  """
  get "/check" do
    case validate_uri(parse_params(conn)[:url]) do
      { :ok, url } ->
        case { outcome, violations } = Auditor.request_audit(url) do
          { :ok, violations } ->
            response(conn, 200, %{ "url" => url, "outcome" => outcome, "violations" => violations })

          { :busy, [] } ->
            response(conn, 503, %{ "url" => url, "outcome" => outcome })

          { :crash, [] } ->
            response(conn, 500, %{ "url" => url, "outcome" => outcome })
        end

      { :error, url } ->
        response(conn, 400, %{ "url" => url, "outcome" => :error, "errors" => ["Invalid url"] })
    end
  end

  @doc """
    Token to authorize loader.io to perform load testing. Change this to your token
    if you want to perform load testing on your instances.
  """
  get "/loaderio-454896b7b1bc08f2668cf4d0001d69fa/" do
    "loaderio-454896b7b1bc08f2668cf4d0001d69fa"
  end

  import_routes Trot.NotFound

  defp parse_params(conn) do
    Trot.parse_query_string(conn.query_string)
  end

  defp response(conn, status, results) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(results, []))
  end
end
