defmodule WebdbElixirCsvSample.CLI do
  def main(args \\ []) do
    {path, type} =
      args
      |> parse_args()

    apply(
      WebdbElixirCsvSample,
      String.to_atom("puts_#{type}"),
      [WebdbElixirCsvSample.import!(path)]
    )
  end

  defp parse_args(args) do
    {[path: path, type: type], _, _} =
      args
      |> OptionParser.parse(strict: [path: :string, type: :string])

    {path, type}
  end
end
