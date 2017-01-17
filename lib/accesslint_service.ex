defmodule AccesslintService.Router do
  use Trot.Router

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

  get "/check" do
    url        = parse_params(conn)[:url]
    violations = parse_violations(url)
    results    = Poison.encode!(%{ "url" => url, "violations" => violations }, [])

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, results)
  end

  import_routes Trot.NotFound

  def parse_params(conn) do
    Trot.parse_query_string(conn.query_string)
  end

  def parse_violations(url) do
    { violations_str, _ } = System.cmd("accesslint", [url])

    violations_str
    |> String.split("\n", trim: true)
    |> Enum.map(&(parse_violation(&1)) )
  end

  def parse_violation(str) do
    [ url, impact, help, nodes ] = str
                                   |> String.replace("'", "")
                                   |> String.split(" | ")

     %{ url: url, impact: impact, help: help, nodes: Poison.decode!(nodes) }
  end
end
