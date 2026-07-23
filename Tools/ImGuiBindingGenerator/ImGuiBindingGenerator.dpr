program ImGuiBindingGenerator;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  BindingGenerator in 'BindingGenerator.pas',
  Dom in 'Dom.pas',
  SourceWriter in 'SourceWriter.pas',
  IncludeFileGenerator in 'IncludeFileGenerator.pas',
  SourceFileGenerator in 'SourceFileGenerator.pas',
  Utils in 'Utils.pas',
  DelphiOverloads in 'DelphiOverloads.pas';

begin
  try
    ReportMemoryLeaksOnShutdown := True;
    var BindingGenerator := TBindingGenerator.Create;
    try
      BindingGenerator.Run;
    finally
      BindingGenerator.Free;
    end;

    {$WARN SYMBOL_PLATFORM OFF}
    if (TBindingGenerator.HasWarnings) and (DebugHook <> 0) then
    begin
      WriteLn('Press [Enter] to close...');
      ReadLn;
    end;
    {$WARN SYMBOL_PLATFORM ON}
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
