defmodule Order do
  defstruct [:性別, :年代, :油, :硬さ, :濃さ, :トッピング, :ライス]

  def new(row_data) do
    %Order{
      トッピング: row_data["トッピング"],
      ライス: row_data["ライス"],
      年代: row_data["年代"],
      性別: row_data["性別"],
      油: row_data["油"],
      濃さ: row_data["濃さ"],
      硬さ: row_data["硬さ"]
    }
  end
end
