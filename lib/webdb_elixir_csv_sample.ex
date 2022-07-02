defmodule WebdbElixirCsvSample do
  def import!(path) do
    path
    |> Path.expand()
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.map(&Order.new(&1))
  end
end
