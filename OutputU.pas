unit OutputU;
{
This unit is for the output form.

}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TOutputFrm = class(TForm)
    Button1: TButton;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OutputFrm: TOutputFrm;

implementation

uses TURTLEU;

{$R *.DFM}

procedure TOutputFrm.FormActivate(Sender: TObject);
begin
     Form1.Run(OutputFrm.Canvas); // run the turtle program
end;

procedure TOutputFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     TurtleRunning:=false; // stop the turtle program
end;

procedure TOutputFrm.Button1Click(Sender: TObject);
begin // Stop Program
     TurtleRunning:=false; // stop the turtle program
end;

end.
