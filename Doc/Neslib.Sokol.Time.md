# Neslib.Sokol.Time

Simple cross-platform time measurement.

This is a light-weight OOP layer on top of [sokol_time.h](https://github.com/floooh/sokol).

## API

* `class procedure TTime.Setup; static;` - Call once before any other functions to initialize Neslib.Sokol.Time (this calls for instance `QueryPerformanceFrequency` on Windows)
* `class function TTime.Now: Int64; static;` - Get current point in time in unspecified 'ticks'. The value that is returned has no relation to the 'wall-clock' time and is not in a specific time unit, it is only useful to compute time differences.
* `class function TTime.Diff(const ANew, AOld: Int64): Int64; static;` - Computes the time difference between `ANew` and `AOld`. This will always return a positive, non-zero value.
* `class function TTime.Since(const AStart: Int64): Int64; static;` - Takes the current time, and returns the elapsed time since `AStart` (this is a shortcut for `TTime.Diff(TTime.Now, AStart)`).
* `class function TTime.LapTime(var ALastTime: Int64): Int64; static;` - This is useful for measuring frame time and other recurring events. It takes the current time, returns the time difference to the value in `ALastTime`, and stores the current time in `ALastTime` for the next call. If the value in last_time is 0, the return value will be zero (this usually happens on the very first call).
* `class function TTime.RoundToCommonRefreshRate(const ADuration: Int64): Int64; static;` - This oddly named function takes a measured frame time and returns the closest "nearby" common display refresh rate frame duration in ticks. If the input duration isn't close to any common display refresh rate, the input duration will be returned unchanged as a fallback. The main purpose of this function is to remove jitter/inaccuracies from measured frame times, and instead use the display refresh rate as frame duration. *Note*: for more robust frame timing, consider using the `TApplication.FrameDuration` property.
* `class function TTime.ToSeconds(const ATicks: Int64): Double; static;` - Converts `ATicks` into seconds.
* `class function TTime.ToMilliSeconds(const ATicks: Int64): Double; static;` - Converts `ATicks` into milliseconds (1/1,000th of a second).
* `class function TTime.ToMicroSeconds(const ATicks: Int64): Double; static;` - Converts `ATicks` into microseconds (1/1,000,000th of a second). Not all platforms have microsecond precision.
* `class function TTime.ToNanoSeconds(const ATicks: Int64): Double; static;` - Converts `ATicks` into nanoseconds (1/1,000,000,000th of a second). Not all platforms have nanasecond precision.