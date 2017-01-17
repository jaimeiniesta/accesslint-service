defmodule AccesslintService.Auditor do
  alias AccesslintService.Auditor

  def audit(url) do
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
end
