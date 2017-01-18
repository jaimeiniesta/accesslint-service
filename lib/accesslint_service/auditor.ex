defmodule AccesslintService.Auditor do
  alias AccesslintService.Auditor

  def audit(url) do
    wait_for_rate_limit

    try do
      auditor_pid = Task.async(Auditor, :violations, [url])

      case Task.await(auditor_pid, 25000) do
        { :ok, violations } -> { :ok, violations }
        { :error, []      } -> { :crash, []      }
      end
    catch
      :exit, _ -> { :crash, [] }
    end
  end

  @doc """
    Executes accesslint-cli for the given URL, and returns the violations found.
  """
  def violations(url) do
    case System.cmd("accesslint", [url]) do
      { violations_str, 0 } ->
        violations = violations_str
                     |> String.split("\n", trim: true)
                     |> Enum.map(&(parse_violation(&1)))

        { :ok, violations }

      _ ->
        { :error, [] }
    end
  end

  defp parse_violation(str) do
    [ url, impact, help, nodes ] = str
                                   |> String.replace("'", "")
                                   |> String.split(" | ")

     %{ url: url, impact: impact, help: help, nodes: Poison.decode!(nodes) }
  end

  @rate_limit_time  5_000
  @rate_limit_pages 5
  @doc """
    Too many concurrent requests may cause PhantomJS to crash, this ensures at most
    5 requests in a 5 seconds period are accepted. If there are more, they are made to
    wait a bit.
  """
  defp wait_for_rate_limit do
    case ExRated.check_rate("accesslint", @rate_limit_time, @rate_limit_pages) do
      {:ok, count} ->
        :ok
      {:error, count} ->
        :timer.sleep(100)
        wait_for_rate_limit
    end
  end
end
