defmodule WebdbElixirCsvSample.Order do
  defstruct [:gender, :age, :oily, :hardness, :salinity, :topping, :rice, :review]

  def new(%{
        "トッピング" => topping,
        "ライス" => rice,
        "年代" => age,
        "性別" => gender,
        "油" => oily,
        "濃さ" => salinity,
        "硬さ" => hardness,
        "評価" => review
      }) do
    %__MODULE__{
      topping: topping,
      rice: rice,
      age: age,
      gender: gender,
      oily: oily,
      salinity: salinity,
      hardness: hardness,
      review: review |> String.to_integer()
    }
  end

  def new(_), do: {:error, :required_columns_dose_not_exsit}

  def calc_review_avg(orders, gender, age) do
    orders
    |> Enum.filter(fn order ->
      order.age == age &&
        order.gender == gender
    end)
    |> Enum.map(& &1.review)
    |> then(fn reviews ->
      Enum.sum(reviews) / Enum.count(reviews)
    end)
  end

  def calc_order_rates(orders, filter_func) do
    orders
    |> Enum.filter(&filter_func.(&1))
    |> then(fn targets ->
      %{
        rice: targets |> calc_avg_by_order_key(:rice),
        topping: targets |> calc_avg_by_order_key(:topping),
        oily: targets |> calc_avg_by_order_key(:oily),
        hardness: targets |> calc_avg_by_order_key(:hardness),
        salinity: targets |> calc_avg_by_order_key(:salinity)
      }
    end)
  end

  defp calc_avg_by_order_key(targets, order_key) do
    targets
    |> Enum.map(&Map.get(&1, order_key))
    |> Enum.group_by(& &1)
    |> Enum.map(fn {key, each_values} ->
      {key, Enum.count(each_values) / Enum.count(targets)}
    end)
  end
end
