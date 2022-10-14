unit Neslib.Sokol.Time;
{ Simple cross-platform time measurement.

  For a user guide, check out the Neslib.Sokol.Time.md file in the Doc
  subdirectory or read it on-line at:

  https://github.com/neslib/Neslib.Sokol/Doc/Neslib.Sokol.Time.md }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

type
  { Time measurement entry point }
  TTime = record // static
  public
    { Call once before any other functions to initialize Neslib.Sokol.Time (this
      calls for instance QueryPerformanceFrequency on Windows) }
    class procedure Setup; static;

    { Get current point in time in unspecified 'ticks'. The value that is
      returned has no relation to the 'wall-clock' time and is not in a specific
      time unit, it is only useful to compute time differences. }
    class function Now: Int64; inline; static;

    { Computes the time difference between ANew and AOld. This will always
      return a positive, non-zero value. }
    class function Diff(const ANew, AOld: Int64): Int64; inline; static;

    { Takes the current time, and returns the elapsed time since AStart (this is
      a shortcut for TTime.Diff(TTime.Now, AStart)). }
    class function Since(const AStart: Int64): Int64; inline; static;

    { This is useful for measuring frame time and other recurring events. It
      takes the current time, returns the time difference to the value in
      ALastTime, and stores the current time in ALastTime for the next call. If
      the value in last_time is 0, the return value will be zero (this usually
      happens on the very first call). }
    class function LapTime(var ALastTime: Int64): Int64; inline; static;

    { This oddly named function takes a measured frame time and returns the
      closest "nearby" common display refresh rate frame duration in ticks. If
      the input duration isn't close to any common display refresh rate, the
      input duration will be returned unchanged as a fallback. The main purpose
      of this function is to remove jitter/inaccuracies from measured frame
      times, and instead use the display refresh rate as frame duration.
      Note: for more robust frame timing, consider using the
      TApplication.FrameDuration property. }
    class function RoundToCommonRefreshRate(const ADuration: Int64): Int64; inline; static;

    { Converts ATicks into seconds. }
    class function ToSeconds(const ATicks: Int64): Double; inline; static;

    { Converts ATicks into milliseconds (1/1,000th of a second). }
    class function ToMilliSeconds(const ATicks: Int64): Double; inline; static;

    { Converts ATicks into microseconds (1/1,000,000th of a second).
      Not all platforms have microsecond precision. }
    class function ToMicroSeconds(const ATicks: Int64): Double; inline; static;

    { Converts ATicks into microseconds (1/1,000,000th of a second).
      Not all platforms have microsecond precision. }
    class function ToNanoSeconds(const ATicks: Int64): Double; inline; static;
  end;

implementation

uses
  Neslib.Sokol.Api;

{ TTime }

class function TTime.Diff(const ANew, AOld: Int64): Int64;
begin
  Result := _stm_diff(ANew, AOld);
end;

class function TTime.LapTime(var ALastTime: Int64): Int64;
begin
  Result := _stm_laptime(@ALastTime);
end;

class function TTime.Now: Int64;
begin
  Result := _stm_now;
end;

class function TTime.RoundToCommonRefreshRate(const ADuration: Int64): Int64;
begin
  Result := _stm_round_to_common_refresh_rate(ADuration);
end;

class procedure TTime.Setup;
begin
  _stm_setup;
end;

class function TTime.Since(const AStart: Int64): Int64;
begin
  Result := _stm_since(AStart);
end;

class function TTime.ToMicroSeconds(const ATicks: Int64): Double;
begin
  Result := _stm_us(ATicks);
end;

class function TTime.ToMilliSeconds(const ATicks: Int64): Double;
begin
  Result := _stm_ms(ATicks);
end;

class function TTime.ToNanoSeconds(const ATicks: Int64): Double;
begin
  Result := _stm_ns(ATicks);
end;

class function TTime.ToSeconds(const ATicks: Int64): Double;
begin
  Result := _stm_sec(ATicks);
end;

end.
