defmodule WebdbElixirCsvSample.Order do
  @moduledoc """
  注文データに関するstructの生成と分析を行う module です。
  """
  defstruct [:gender, :age, :oily, :hardness, :salinity, :topping, :rice, :review]

  @key_name_map %{
    topping: "トッピング",
    rice: "ライス",
    gender: "性別",
    age: "年代",
    oily: "脂",
    salinity: "濃さ",
    hardness: "硬さ",
    review: "評価"
  }

  @doc """
  csvから読み込んだ注文データ（map）を元にOrder structを生成します。

  ## Examples
      iex> %{
      ...>   "トッピング" => "チャーシュー",
      ...>   "ライス" => "普通",
      ...>   "年代" => "20代",
      ...>   "性別" => "男性",
      ...>   "脂脂" => "多め",
      ...>   "濃さ" => "濃いめ",
      ...>   "硬さ" => "硬め",
      ...>   "評価" => "5"
      ...> }
      ...> |> WebdbElixirCsvSample.Order.new()
      %WebdbElixirCsvSample.Order{
        topping: "チャーシュー",
        rice: "普通",
        age: "20代",
        gender:  "男性",
        oily: "多め",
        salinity: "濃いめ",
        hardness: "硬め",
        review: 5
      }
  """
  def new(order_map)

  def new(%{
        "トッピング" => topping,
        "ライス" => rice,
        "年代" => age,
        "性別" => gender,
        "脂脂" => oily,
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

  @doc """
  Ordere structのkey名を日本語名称に変換します。
  ## Examples
      iex> WebdbElixirCsvSample.Order.en_key_to_ja(:topping)
      "トッピング"
  """
  def en_key_to_ja(key), do: @key_name_map[key]

  @doc """
  Ordere structのリスト, 任意の性別と年代を元にReviewの平均値を算出します。

  ## Examples
      iex> [
      ...>   %WebdbElixirCsvSample.Order{age: "20代", gender: "男性", review: 2},
      ...>   %WebdbElixirCsvSample.Order{age: "20代", gender: "男性", review: 5},
      ...>   %WebdbElixirCsvSample.Order{age: "30代", gender: "男性", review: 5}
      ...> ]
      ...> |> WebdbElixirCsvSample.Order.calc_review_avg("男性", "20代")
      3.5

  ※ sampleのOrder structは可読性のために一部 field を削っています。
  """
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

  @doc """
  Order structのリスト, 任意の条件式を元に各注文方法の割合を算出します。

  ## Examples
      iex> [
      ...>   %WebdbElixirCsvSample.Order{gender: "男性", topping: "チャーシュー", rice: "なし", oily: "多め", salinity: "濃いめ", hardness: "やわ"},
      ...>   %WebdbElixirCsvSample.Order{gender: "男性", topping: "ほうれん草", rice: "普通", oily: "多め", salinity: "濃いめ", hardness: "普通"},
      ...>   %WebdbElixirCsvSample.Order{gender: "女性", topping: "ほうれん草", rice: "大盛り", oily: "少なめ", salinity: "薄め", hardness: "硬め"},
      ...>   %WebdbElixirCsvSample.Order{gender: "女性", topping: "ほうれん草", rice: "なし", oily: "普通", salinity: "濃いめ", hardness: "普通"},
      ...>   %WebdbElixirCsvSample.Order{gender: "男性", topping: "味玉", rice: "大盛り", oily: "普通", salinity: "薄め", hardness: "硬め"},
      ...>   %WebdbElixirCsvSample.Order{gender: "男性", topping: "海苔", rice: "大盛り", oily: "多め", salinity: "普通", hardness: "硬め"},
      ...>   %WebdbElixirCsvSample.Order{gender: "男性", topping: "味玉", rice: "普通", oily: "普通", salinity: "普通", hardness: "硬め"},
      ...> ]
      ...> |> WebdbElixirCsvSample.Order.calc_order_rates(&(&1.gender == "男性"))
      %{
        hardness: %{"やわ" => 20.0, "普通" => 20.0, "硬め" => 60.0},
        oily: %{"多め" => 60.0, "普通" => 40.0},
        rice: %{"なし" => 20.0, "大盛り" => 40.0, "普通" => 40.0},
        salinity: %{"普通" => 40.0, "濃いめ" => 40.0, "薄め" => 20.0},
        topping: %{"ほうれん草" => 20.0, "チャーシュー" => 20.0, "味玉" => 40.0, "海苔" => 20.0}
      }

  ※ sampleのOrder structは可読性のために一部 field を削っています。
  """
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
      {key, Enum.count(each_values) / Enum.count(targets) * 100}
    end)
    |> Map.new()
  end
end
