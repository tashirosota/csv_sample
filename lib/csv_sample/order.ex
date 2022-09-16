defmodule CsvSample.Order do
  @moduledoc """
  注文データに関する構造体の作成と分析を行うモジュールです。
  """
  defstruct [:gender, :age, :oil_level, :hard_level, :salt_level, :topping, :rice, :review]

  @key_name_map %{
    gender: "性別",
    age: "年齢層",
    oil_level: "脂",
    salt_level: "濃さ",
    hard_level: "硬さ",
    topping: "トッピング",
    rice: "ライス",
    review: "評価"
  }

  @doc """
  csvから読み込んだ注文データ（map）を元にOrder構造体を生成します。

  ## Examples
      iex> %{
      ...>   "トッピング" => "チャーシュー",
      ...>   "ライス" => "普通",
      ...>   "年齢層" => "20代",
      ...>   "性別" => "男性",
      ...>   "脂" => "多め",
      ...>   "濃さ" => "濃いめ",
      ...>   "硬さ" => "硬め",
      ...>   "評価" => "5"
      ...> }
      ...> |> CsvSample.Order.new()
      %CsvSample.Order{
        topping: "チャーシュー",
        rice: "普通",
        age: "20代",
        gender:  "男性",
        oil_level: "多め",
        salt_level: "濃いめ",
        hard_level: "硬め",
        review: 5
      }
  """
  def new(order_map)

  def new(%{
        "性別" => gender,
        "年齢層" => age,
        "脂" => oil_level,
        "濃さ" => salt_level,
        "硬さ" => hard_level,
        "トッピング" => topping,
        "ライス" => rice,
        "評価" => review
      }) do
    %__MODULE__{
      topping: topping,
      rice: rice,
      age: age,
      gender: gender,
      oil_level: oil_level,
      salt_level: salt_level,
      hard_level: hard_level,
      review: review |> String.to_integer()
    }
  end

  def new(_), do: {:error, :required_key_dose_not_exsit}

  @doc """
  注文構造体のキー名を日本語名称に変換します。
  ## Examples
      iex> CsvSample.Order.en_key_to_ja(:topping)
      "トッピング"
  """
  def en_key_to_ja(key), do: @key_name_map[key]

  @doc """
  注文構造体のリスト, 任意の性別と年齢をもとにレビューの平均値を算出します。

  ## Examples
    iex> [
    ...>   %CsvSample.Order{
    ...>     age: "20代", gender: "男性", review: 2},
    ...>   %CsvSample.Order{
    ...>     age: "20代", gender: "男性", review: 5},
    ...>   %CsvSample.Order{
    ...>     age: "30代", gender: "男性", review: 5}
    ...> ]
    ...> |> CsvSample.Order.calc_review_avg("男性", "20代")
    3.5

  ※ サンプルの注文構造体は一部フィールドを割愛しています。
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
  注文構造体のリスト,, 任意の条件式を元に各注文方法の割合を算出します。

  ## Examples
      iex> [
      ...>   %CsvSample.Order{gender: "男性", topping: "チャーシュー", rice: "なし", oil_level: "多め", salt_level: "濃いめ", hard_level: "やわ"},
      ...>   %CsvSample.Order{gender: "男性", topping: "ほうれん草", rice: "普通", oil_level: "多め", salt_level: "濃いめ", hard_level: "普通"},
      ...>   %CsvSample.Order{gender: "女性", topping: "ほうれん草", rice: "大盛り", oil_level: "少なめ", salt_level: "薄め", hard_level: "硬め"},
      ...>   %CsvSample.Order{gender: "女性", topping: "ほうれん草", rice: "なし", oil_level: "普通", salt_level: "濃いめ", hard_level: "普通"},
      ...>   %CsvSample.Order{gender: "男性", topping: "味玉", rice: "大盛り", oil_level: "普通", salt_level: "薄め", hard_level: "硬め"},
      ...>   %CsvSample.Order{gender: "男性", topping: "海苔", rice: "大盛り", oil_level: "多め", salt_level: "普通", hard_level: "硬め"},
      ...>   %CsvSample.Order{gender: "男性", topping: "味玉", rice: "普通", oil_level: "普通", salt_level: "普通", hard_level: "硬め"},
      ...> ]
      ...> |> CsvSample.Order.calc_order_rates(&(&1.gender == "男性"))
      %{
        hard_level: %{"やわ" => 20.0, "普通" => 20.0, "硬め" => 60.0},
        oil_level: %{"多め" => 60.0, "普通" => 40.0},
        rice: %{"なし" => 20.0, "大盛り" => 40.0, "普通" => 40.0},
        salt_level: %{"普通" => 40.0, "濃いめ" => 40.0, "薄め" => 20.0},
        topping: %{"ほうれん草" => 20.0, "チャーシュー" => 20.0, "味玉" => 40.0, "海苔" => 20.0}
      }

  ※ sampleのOrder structは可読性のために一部 field を削っています。
  """
  def calc_order_rates(orders, filter_func) do
    orders
    |> Enum.filter(&filter_func.(&1))
    |> then(fn targets ->
      %{
        rice: calc_rate(targets, :rice),
        topping: calc_rate(targets, :topping),
        oil_level: calc_rate(targets, :oil_level),
        hard_level: calc_rate(targets, :hard_level),
        salt_level: calc_rate(targets, :salt_level)
      }
    end)
  end

  defp calc_rate(targets, order_key) do
    targets
    |> Enum.map(&Map.get(&1, order_key))
    |> Enum.group_by(& &1)
    |> Enum.map(fn {key, each_values} ->
      {
        key,
        Enum.count(each_values) / Enum.count(targets) * 100
      }
    end)
    |> Map.new()
  end
end
