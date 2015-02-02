defmodule Hank.Plugin.Youtube do
  use HTTPoison.Base
  alias Hank.Plugin.Youtube.Video

  @iso_8601_duration ~r/^(P((?<Years>\d+)Y)?((?<Months>\d+)M)?((?<Days>\d+)D)?)(T((?<Hours>\d+)H)?((?<Minutes>\d+)M)?((?<Seconds>\d+((.)?(\d)?(\d)?))S)?)$/

  def get_video(id) do
    part = "part=id,snippet,contentDetails,statistics"
    id   = "id=#{id}"
    get!(Enum.join([part, id], "&")).body
  end

  defp process_url(url) do
    api_key = Application.get_env(:hank, :youtube)[:api_key]
    "https://www.googleapis.com/youtube/v3/videos?key=#{api_key}&" <> url
  end

  defp process_response_body(body) do
    body       = Poison.decode!(body)
    [items]    = body["items"]
    id         = items["id"]
    snippet    = items["snippet"]
    details    = items["contentDetails"]
    statistics = items["statistics"]

    %{
      "Years"   => years,
      "Months"  => months,
      "Days"    => days,
      "Hours"   => hours,
      "Minutes" => minutes,
      "Seconds" => seconds,
    } = Regex.named_captures(@iso_8601_duration, details["duration"])
    # TODO: This code is really gross

    if String.length(seconds) == 1, do: seconds = "#{seconds}0"

    duration_string = ""
    duration_string = duration_string <> if String.length(years)   > 0, do: years   <> ":", else: ""
    duration_string = duration_string <> if String.length(months)  > 0, do: months  <> ":", else: ""
    duration_string = duration_string <> if String.length(days)    > 0, do: days    <> ":", else: ""
    duration_string = duration_string <> if String.length(hours)   > 0, do: hours   <> ":", else: ""
    duration_string = duration_string <> if String.length(minutes) > 0, do: minutes <> ":", else: ""
    duration_string = duration_string <> if String.length(seconds) > 0, do: seconds,        else: "00"

    %Video{
      id:         id,
      permalink:  "https://youtu.be/#{id}",
      title:      snippet["title"],
      duration:   duration_string,
      definition: details["definition"],
      channel:    snippet["channelTitle"],
      views:      statistics["viewCount"],
      likes:      statistics["likeCount"],
      dislikes:   statistics["dislikeCount"],
    }
  end
end
