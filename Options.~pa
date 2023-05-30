unit Options;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls;

type
  TOptionsfrm = class(TForm)
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    Label2: TLabel;
    SpinEdit2: TSpinEdit;
    Button1: TButton;
    Shape1: TShape;
    ColorDialog1: TColorDialog;
    CheckBox1: TCheckBox;
    ProgramTimeStopChB: TCheckBox;
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Optionsfrm: TOptionsfrm;

implementation
 uses turtleu, OutputU;
{$R *.DFM}

procedure TOptionsfrm.SpinEdit1Change(Sender: TObject);
begin
     ProgramTimeStopChB.Checked:=true;
     if spinedit1.text<>'' then
        MaxTime:=SpinEdit1.Value;
end;

procedure TOptionsfrm.SpinEdit2Change(Sender: TObject);
begin
     if spinedit2.text<>'' then
        instrDelay:=spinedit2.value;
end;

procedure TOptionsfrm.Button1Click(Sender: TObject);
begin
     if ColorDialog1.Execute then
     begin
          Shape1.Brush.Color:=ColorDialog1.Color;
          OutputFrm.Color:=ColorDialog1.Color;
     end;
end;

end.
