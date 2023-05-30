unit DebugU;
{
This unit is for a form that displays execution information such as a
variable chart, presently executioning command...

}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TDebugFrm = class(TForm)
  procedure UpdateDisplay;
    procedure Button1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DebugFrm: TDebugFrm;
   running: boolean;
   MaxStackSize: integer;
   EIP1: integer; // global copy of the program counter

implementation
uses turtleu, OutputU;
{$R *.DFM}
function GetCurLocation(id: compvar): integer;
begin
     with id do
     begin
          if global then
             result:=spot
          else
              result:=valindex-spot;
     end;
end;

function GetIdentifier(e: integer): string;
// get the identifier names that point to value[e]
var
 x: integer;
begin
{
    name: string;  // an identifier for the variable
    spot: integer; // the element in the "values" array containing the value of the variable
    global: boolean; // true when the variable was declared in the memo
}
     for x:=high(identifiers) downto 0 do
     begin

     end;
end;

procedure TDebugFrm.UpdateDisplay;
var
  bit1: tbitmap;
  s: string;
  x,y,h,z: integer;
const left1 = 20;
begin
     bit1:=tbitmap.create;
     bit1.height:=clientheight;
     bit1.width:=clientwidth;

     h:=bit1.Canvas.textheight('Hello')+2;
     bit1.canvas.textout(left1,0,'Variable Stack');
     for x:=MaxStackSize downto 0 do
         bit1.canvas.textout(left1,(x+1)*h,inttostr(x)+': '+GetIdentifier(x)+floattostr(values[x]));

     y:=(maxstacksize+4)*h;
     bit1.canvas.textout(left1,y-h,'Program Decompilation');

     for x:=0 to high(program1) do
     begin
          s:=comps[program1[x].num].name;
          if comps[program1[x].num].NumOfParams>0 then
          begin
               with program1[x].param1 do
               begin
                    if shifted then
                       z:=valindex+addr1
                    else
                        z:=addr1;
               end;
               s:=s+' ['+inttostr(z)+']';
               if comps[program1[x].num].NumOfParams>1 then
               begin
                    with program1[x].param2 do
                    begin
                         if shifted then
                            z:=valindex+addr1
                         else
                             z:=addr1;
                    end;
                    s:=s+',['+inttostr(z)+']';
               end;
          end;
          bit1.canvas.textout(left1,y+x*h,s);
     end;
     bit1.canvas.moveto(0,y+eip1*h+5);
     bit1.canvas.lineto(left1-3,y+eip1*h+5);
     canvas.draw(0,0,bit1);
     bit1.free;
end;

procedure TDebugFrm.Button1Click(Sender: TObject);
begin
     UpdateDisplay;
end;

procedure TDebugFrm.FormPaint(Sender: TObject);
begin
     updatedisplay;
     if running then
        OutputFrm.ShowModal;
end;

procedure TDebugFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     running:=false;
end;

end.
