program MyTurtle;

uses
  Forms,
  TURTLEU in 'TURTLEU.pas' {Form1},
  Options in 'Options.pas' {Optionsfrm},
  DebugU in 'DebugU.pas' {DebugFrm},
  OutputU in 'OutputU.pas' {OutputFrm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TOptionsfrm, Optionsfrm);
  Application.CreateForm(TDebugFrm, DebugFrm);
  Application.CreateForm(TOutputFrm, OutputFrm);
  Application.Run;
end.
