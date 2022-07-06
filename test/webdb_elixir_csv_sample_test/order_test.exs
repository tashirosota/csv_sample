defmodule WebdbElixirCsvSample.OrderTest do
  use ExUnit.Case
  alias WebdbElixirCsvSample.Order
  doctest Order

  describe "new/1" do
    test "カラムが足らない場合" do
      assert {:error, :required_key_dose_not_exsit} = Order.new(%{dummy: :dummy})
    end
  end
end
