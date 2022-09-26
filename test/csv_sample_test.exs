defmodule CsvSampleTest do
  use ExUnit.Case
  alias CsvSample.Order
  doctest CsvSample
  import ExUnit.CaptureIO

  describe "import!/1" do
    test "正常系" do
      assert [_ | _] = orders = CsvSample.import!("priv/ie_ramen.csv")
      assert orders |> Enum.all?(&match?(&1, %Order{}))
    end

    test "存在しないpathが指定された場合" do
      assert_raise File.Error, fn ->
        CsvSample.import!("dummy_path")
      end
    end
  end

  describe "puts_review_avgs/1" do
    setup :setup_orders

    test "正常系", %{orders: orders} do
      log =
        capture_io(fn ->
          assert :ok = CsvSample.puts_review_avgs(orders)
        end)

      assert log =~ "10代以下男性：平均"
      assert log =~ "30代男性：平均"
      assert log =~ "50代男性：平均"
      assert log =~ "10代以下女性：平均"
      assert log =~ "30代女性：平均"
      assert log =~ "50代女性：平均"
    end
  end

  describe "puts_order_rates/1" do
    setup :setup_orders

    test "正常系", %{orders: orders} do
      log =
        capture_io(fn ->
          assert :ok = CsvSample.puts_order_rates(orders)
        end)

      assert log =~ "10代以下男性"
      assert log =~ "30代男性"
      assert log =~ "50代男性"
      assert log =~ "10代以下女性"
      assert log =~ "30代女性"
      assert log =~ "50代女性"
      assert log =~ "ライス"
      assert log =~ "トッピング"
      assert log =~ "脂"
      assert log =~ "硬さ"
      assert log =~ "濃さ"
    end
  end

  defp setup_orders(_) do
    [orders: CsvSample.import!("priv/ie_ramen.csv")]
  end
end
