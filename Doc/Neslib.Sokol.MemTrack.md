# Neslib.Sokol.MemTrack

Memory allocation wrapper to track memory usage of Sokol libraries.

## Step-by-Step
* Define the symbol `SOKOL_MEM_TRACK` in the Project Options (under Building | Delphi Compiler | Compiling | Conditional defines). You can do this for all build configurations and all platforms, or just the configurations and platforms you are interested in. It makes sense to add this for "Debug configuration - All platforms".
  
* Use the Neslib.Sokol.MemTrack unit somewhere in your project, preferable inside a `{$IFDEF SOKOL_MEM_TRACK}` block to avoid a compilation warning:
  
  ```pascal
  unit MyUnit;
  
  uses
    {$IFDEF SOKOL_MEM_TRACK}Neslib.Sokol.MemTrack,{$ENDIF}
    Neslib.Sokol.Gfx,
    ...
  ```
* Call `TMemTrack.GetAllocations` to get information about the current number of allocations and number of allocated bytes:

  ```pascal
  var Info := TMemTrack.GetAllocations;
  WriteLn('Number of allocations: ', Info.NumAllocations);
  WriteLn('Number of allocated bytes: ', Info.NumBytes);
  ```

Note that Neslib.Sokol.MemTrack only tracks allocations issued by the Sokol libraries. It does not track allocations that happen under the hood in system libraries, in the Delphi RTL or under the hood by the Delphi language (such as memory allocations for strings and dynamic arrays).
