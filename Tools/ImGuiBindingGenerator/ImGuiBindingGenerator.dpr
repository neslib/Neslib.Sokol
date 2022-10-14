program ImGuiBindingGenerator;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SourceWriter in 'SourceWriter.pas',
  Common in 'Common.pas',
  BindingGenerator in 'BindingGenerator.pas',
  Definitions in 'Definitions.pas',
  Enums in 'Enums.pas',
  Structs in 'Structs.pas',
  DelphiCustomizations in 'DelphiCustomizations.pas',
  TemplateHandler in 'TemplateHandler.pas',
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
