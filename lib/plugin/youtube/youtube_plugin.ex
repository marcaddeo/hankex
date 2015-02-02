defmodule Hank.Plugin.Youtube.YoutubePlugin do
  use Hank.Core.Plugin
  use Hank.Util.Color
  alias Hank.Plugin.Youtube
  alias Hank.Core.Client.Server, as: Client

  @regex ~r/^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?(?<video_id>[^#\&\?\s]*).*/

  def handle_cast({%Message{} = message, _}, state) do
    %Message{target: target, params: message} = message

    if message =~ @regex do
      %{"video_id" => video_id} = Regex.named_captures(@regex, message)
      video = Youtube.get_video(video_id)

      title      = @bold <> video.title <> @reset
      duration   = video.duration
      definition = @bold <> @red <> String.upcase(video.definition) <> @reset
      views      = video.views
      likes      = @green <> video.likes <> @reset
      dislikes   = @red <> video.dislikes <> @reset
      permalink  = @bold <> video.permalink <> @reset
      msg = "#{title} [#{duration}] #{definition} #{views} views (+#{likes}|-#{dislikes}) #{permalink}"
      Client.privmsg(target, msg)
    end

    {:noreply, state}
  end
end
