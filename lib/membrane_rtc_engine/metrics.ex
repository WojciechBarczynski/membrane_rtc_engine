defmodule Membrane.RTC.Engine.Metrics do
  @moduledoc """
  Defines list of metrics, that Reporter instance can aggregate by listening on events emitted in RTC Engine.
  Suggested Reporter implementation is `Membrane.TelemetryMetrics.Reporter` from `membrane_telemetry_metrics`.
  `Membrane.TelemetryMetrics.Reporter` started with metrics returned by `metrics/1` function will be able to generate reports, that matches type `Membrane.RTC.Engine.Metrics.rtc_engine_report()`
  You can see usage example in (`membrane_videoroom`)[github.com/membraneframework/membrane_videoroom].
  """

  alias Membrane.RTC.Engine.Endpoint.WebRTC.TrackReceiver
  alias Membrane.RTC.Engine.Track

  @type rtc_engine_report() :: %{
          optional({:room_id, binary()}) => %{
            optional({:peer_id, binary()}) => %{
              optional({:track_id, binary()}) => %{
                :"inbound-rtp.encoding" => :OPUS | :VP8 | :H264,
                :"inbound-rtp.ssrc" => integer(),
                :"inbound-rtp.bytes_received" => integer(),
                :"inbound-rtp.keyframe_request_sent" => integer(),
                :"inbound-rtp.packets" => integer(),
                :"inbound-rtp.frames" => integer(),
                :"inbound-rtp.keyframes" => integer(),
                :"track.metadata" => any()
              },
              optional({:track_id, binary()}) => %{
                :"outbound-rtp.variant" => Track.variant(),
                :"outbound-rtp.variant-reason" => TrackReceiver.variant_switch_reason()
              },
              :"ice.binding_requests_received" => integer(),
              :"ice.binding_responses_sent" => integer(),
              :"ice.bytes_received" => integer(),
              :"ice.bytes_sent" => integer(),
              :"ice.packets_received" => integer(),
              :"ice.packets_sent" => integer(),
              :"peer.metadata" => any()
            }
          }
        }

  @spec metrics() :: [Telemetry.Metrics.t()]
  def metrics() do
    Enum.concat([
      rtc_engine_metrics(),
      Membrane.RTP.Metrics.metrics(),
      Membrane.ICE.Metrics.metrics()
    ])
  end

  defp rtc_engine_metrics() do
    [
      Telemetry.Metrics.sum(
        "inbound-rtp.frames",
        event_name: [Membrane.RTC.Engine, :RTP, :packet, :arrival],
        measurement: :frame_indicator
      ),
      Telemetry.Metrics.sum(
        "inbound-rtp.keyframes",
        event_name: [Membrane.RTC.Engine, :RTP, :packet, :arrival],
        measurement: :keyframe_indicator
      ),
      Telemetry.Metrics.last_value(
        "outbound-rtp.variant",
        event_name: [Membrane.RTC.Engine, :RTP, :variant, :switched],
        measurement: :variant
      ),
      Telemetry.Metrics.last_value(
        "outbound-rtp.variant-reason",
        event_name: [Membrane.RTC.Engine, :RTP, :variant, :switched],
        measurement: :reason
      ),
      Telemetry.Metrics.last_value(
        "peer.bandwidth",
        event_name: [Membrane.RTC.Engine, :peer, :bandwidth],
        measurement: :bandwidth
      ),
      Telemetry.Metrics.last_value(
        "peer.metadata",
        event_name: [Membrane.RTC.Engine, :peer, :metadata, :event],
        measurement: :metadata
      ),
      Telemetry.Metrics.last_value(
        "track.metadata",
        event_name: [Membrane.RTC.Engine, :track, :metadata, :event],
        measurement: :metadata
      )
    ]
  end
end
