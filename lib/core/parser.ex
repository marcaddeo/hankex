defmodule Hank.Core.Parser do
  use Hank.Util.Color
  alias Hank.Core.Message

  def parse(":" <> data) do
    String.split(data, " ", parts: 3)
    |> parse_data
  end

  def parse(data) do
    [command | params] = String.split(data, " :", parts: 2)

    command = command
      |> String.downcase
      |> String.to_atom

    params = params
      |> to_string
      |> String.strip

    %Message{command: command, params: params}
  end

  defp parse_data(data, message \\ %Message{})
  defp parse_data([], %Message{} = message), do: message
  defp parse_data([head | tail], %Message{} = message) do
    cond do
      message.prefix == nil ->
        parse_data(tail, %Message{message | prefix: head})
      message.command == nil ->
        command = head
          |> String.downcase
          |> String.to_atom

        parse_data(tail, %Message{message | command: command})
      true ->
        if String.contains?(head, ":") do
          if String.contains?(message.prefix, "!") do
            [nick | hostmask] = String.split(message.prefix, "!", parts: 2)

            message = %Message{message | sender: nick, hostmask: hostmask}
          end

          [target | params] = String.split(head, ":", parts: 2)

          params = params
            |> to_string
            |> String.strip

          # Strip control characters from message
          params = Regex.replace(~r/#{@bold}/, params, "")
          params = Regex.replace(~r/#{@reset}/, params, "")
          params = Regex.replace(~r/#{@color}\d{1,2},\d{1,2}/, params, "")
          params = Regex.replace(~r/#{@color}\d{1,2}/, params, "")
          params = params
            |> String.to_char_list()
            |> Enum.filter(fn (char) ->
              case char do
                char when char < 32 -> false
                _ -> true
              end
            end)
            |> List.to_string()

          target = target
            |> to_string
            |> String.strip

          parse_data(tail, %Message{message | target: target, params: params})
        else
          head = head
            |> to_string
            |> String.strip
          parse_data(tail, %Message{message | params: head})
        end
    end
  end
end
