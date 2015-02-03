defmodule Hank.Util.Color do
  defmacro __using__(_) do
    quote do
      import Hank.Util.Color

      @bold    <<2>>
      @reset   <<15>>
      @color   <<3>>
      @white   @color <> "00"
      @black   @color <> "01"
      @blue    @color <> "02"
      @green   @color <> "03"
      @red     @color <> "04"
      @brown   @color <> "05"
      @purple  @color <> "06"
      @orange  @color <> "07"
      @yellow  @color <> "08"
      @lime    @color <> "09"
      @teal    @color <> "10"
      @cyan    @color <> "11"
      @royal   @color <> "12"
      @pink    @color <> "13"
      @grey    @color <> "14"
      @silver  @color <> "15"
    end
  end
end
