defmodule WebdbElixirCsvSample do
  @moduledoc """
  家系ラーメンの注文データCSVを読み込んで、それらを用いて任意の分析を行う module です。
  """
  alias WebdbElixirCsvSample.Order

  @doc """
  指定のpathから家系ラーメンの注文データを読み込み、Order structの配列を生成します。
  """
  def import!(path) do
    path
    |> Path.expand()
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.map(&Order.new(&1))
  end

  @doc """
  各性別、年代毎の Reviewの平均値を標準出力します。
  """
  def puts_review_avgs(orders) do
    ["男性", "女性"]
    |> Enum.each(fn gender ->
      ["10代", "20代", "30代", "40代", "50代", "60代"]
      |> Enum.each(fn age ->
        IO.puts(
          "#{age}#{gender}：平均 #{Order.calc_review_avg(orders, gender, age) |> Float.round(2)} 点"
        )
      end)
    end)
  end

  @doc """
  各性別、年代毎の脂脂、硬さ、濃さ、トッピング、ライスそれぞれの注文率　を標準出力します
  """
  def puts_order_rates(orders) do
    ["男性", "女性"]
    |> Enum.each(fn gender ->
      ["10代", "20代", "30代", "40代", "50代", "60代"]
      |> Enum.each(fn age ->
        rate_map = orders |> Order.calc_order_rates(&(&1.gender == gender && &1.age == age))

        """
        #{age}#{gender}：
          #{rate_map |> format_rate_map(:rice) |> inspect()}
          #{rate_map |> format_rate_map(:topping) |> inspect()}
          #{rate_map |> format_rate_map(:oily) |> inspect()}
          #{rate_map |> format_rate_map(:hardness) |> inspect()}
          #{rate_map |> format_rate_map(:salinity) |> inspect()}
        """
        |> IO.puts()
      end)
    end)
  end

  defp format_rate_map(rate_map, key) do
    rate_map[key]
    |> Enum.map(fn {key, value} ->
      {:"#{key}", "#{Float.round(value, 2)}%"}
    end)
    |> then(fn rates ->
      %{"#{Order.en_key_to_ja(key)}": rates}
    end)
  end
end
