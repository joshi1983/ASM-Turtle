unit TURTLEU;
{ ASM Turtle was created by Josh Greig
 Purpose: - to allow a way of programming graphical output like Logo's Turtle
 but with code more like assembly

}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,shellapi;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Memo2: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    procedure Run(can: tcanvas);
    Procedure Compile;
    Procedure CompileVars;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  res1 = array of string;
  command = record
    Name: string;
    NumOfParams: integer; // the number of parameters used by the command
  end;
  compvar = record
    name: string;  // an identifier for the variable
    spot: integer; // the element in the "values" array containing the value of the variable
    global: boolean; // true when the variable was declared in the memo
  end;
  addrData = record
           shifted: boolean;
           addr1: integer;
  end;
  instruction = record // a type storing the information required to execute one step in a program
    num: integer; // type of instruction
    param1,param2: addrData;
    // storing the information for getting the location in the values array storing the value of the 2 parameters
  end;
  realpoint = record // a type for storing the precise location of the turtle while the program is executing
   x,y: real;
  end;

var
  Form1: TForm1;
   AddressStack: array[0..1000] of integer; // a stack for addresses
   index1: integer; // an index for the address stack
   comps: array[0..27] of command; // a listing of commands that can be used in a program
   // this array is used in a process to turn the script in memo1 into program1 so it can be executed
   program1: array of instruction; // all of the instructions in the turtle program stored in an efficient manner for quick execution
   values: array[0..1000] of real; // the values of all the variables used in the program
   // the array is pointed at by each instruction and identifiers.
   ValIndex: integer; // an index in the values array
   identifiers: array of compvar; // used in the compilation process to link identifiers to the appropiate inxed in the values array
   direction: real; // direction in radians
   comparison: integer; // for CMP and conditional jumps
   maxtime: integer; // value is the maximum number of miliseconds in a loop before breaking it
   p: realpoint; // the present position of the turtle
   instrDelay: integer; // the number of miliseconds of delay between the execution of each instruction in the program
   inproc: boolean; // used during compiling
   localvars: integer; // the number of variables declared within a procedure
   TurtleRunning: boolean; // true only when the turtle program is being executed

implementation

uses Options, DebugU, OutputU;

{$R *.DFM}

function valfloat(str1: string): boolean;
var
  c: byte; // represents character number in the for loop
  d,e: boolean; // represents the statement "a decimal has been found in the string."
// used to find the string invalid if there are more than one decimal
begin
     result:=true;
     d:=False;
     e:=False;
     str1:=lowercase(str1);
     if (str1<>'-')and(str1<>'')and(str1<>'.') then
     begin
          for c:=1 to length(str1) do
          begin // loop through the characters in the string
               if ((str1[c]>'9')or(str1[c]<'0'))and(str1[c]<>'.')and(str1[c]<>'-')and(str1[c]<>'e') then
               begin
                  result:=False; // an error will occur if trying to convert the string to real
                  break; // the string was found invalid so there is no reason
                  // to continue in the for loop
               end;
               if str1[c]='.' then
               begin
                    if d then // if there was another decimal already found
                    begin
                         result:=False;
                         break; // breaks the for loop so this can be more efficient
                    end;
                    d:=true; // a decimal has been found
               end
               else if (str1[c]='-')and(c<>1) then
               begin
                    result:=False;
                    break;
               end
               else if str1[c]='e' then
               begin
                    if e then
                    begin
                       result:=False;
                       break;
                    end;
                    e:=true;
               end;
          end;
     end
     else // string is invalid
         result:=False;
     if not result then
        beep; // help notify the user of the problem of an invalid number
end;

procedure RemoveChar(var str1: string;cnum: integer);
begin
     str1:=copy(str1,1,cnum-1)+copy(str1,cnum+1,999);
end;

function GetParamNames(str1: string): res1;
var
  pos1: integer;
begin
     //showmessage('GetParamNames Called, str1="'+str1+'"');
     result:=nil;
     pos1:=pos(' ',str1);
     if pos1<1 then // if there are no spaces in the string
        exit
     else
         str1:=copy(str1,pos1,999); // cut off the first part of the string
     pos1:=pos(' ',str1);
     while pos1>0 do // eliminate all spaces
     begin
          removechar(str1,pos1);
          pos1:=pos(' ',str1);
     end;
   if str1<>'' then
   begin
     if str1[length(str1)]=';' then // last character is ';'
        str1:=copy(str1,1,length(str1)-1); // eliminate that character
     //showmessage('parameters="'+str1+'"');
     pos1:=pos(',',str1)-1;
     if str1='' then
        exit;
     if pos1<0 then
     begin
        setlength(result,1);
        result[0]:=str1;
     end
     else
       while pos1>0 do // a comma is in str1
       begin
          setlength(result,high(result)+2);
          result[high(result)]:=copy(str1,1,pos1);
          str1:=copy(str1,pos1+2,999);
          pos1:=pos(',',str1)-1;
          if (pos1<0)and(str1<>'') then
          begin
               setlength(result,high(result)+2);
               result[high(result)]:=str1;
          end;
       end;
   end;
end;

function CompNum(s: string): integer;
var // returns the command number
   Ls: string;
  e: integer;
begin
     result:=-1;
     for e:=0 to high(comps) do
     begin
          Ls:=lowercase(comps[e].name);
          if pos(Ls,s)=1 then
          begin
               result:=e;
               break;
          end;
     end;
end;

procedure ClearFirstSpaces(var str1: string);
begin // clear all spaces from the string
     while pos(' ',str1)=1 do
           str1:=copy(str1,2,999);
end;

procedure ClearLastSpaces(var str1: string);
var // remove all of the last space characters in the string
  c: integer;
begin
     for c:=length(str1) downto 1 do
         if str1[c]=' ' then
            str1:=copy(str1,1,c-1)
         else
             exit;
end;

procedure ClearDoubleSpaces(var str1: string);
var // make sure no 2 spaces are side-by-side
  pos1: integer;
begin
     pos1:=pos('  ',str1);
     while pos1>0 do
     begin
          RemoveChar(str1,pos1);
          pos1:=pos('  ',str1);
     end;
end;

function CleanString(const str1: string): string;
var
  pos1: integer;
begin
     result:=str1;
     pos1:=pos('//',result);
     if pos1>0 then
        result:=copy(result,1,pos1-1);
        // eliminate internal documentation
     ClearLastSpaces(result);
     ClearFirstSpaces(result);
     ClearDoubleSpaces(result);
end;

procedure addvar(name: string;value: real);
begin
     setlength(identifiers,high(identifiers)+2);
     inc(valindex);
     identifiers[high(identifiers)].name:=name;
     with identifiers[high(identifiers)] do
     begin
          spot:=valindex;
          global:=true;
     end;
     values[valindex]:=value;
     if inproc then
       inc(localvars) // the number of variables declared within a procedure
end;

function GetVarNum(s: string): AddrData;
var
  e: integer;
begin
     result.shifted:=false;
     result.addr1:=-999999;
     for e:=0 to high(identifiers) do
     begin
          if lowercase(identifiers[e].name)=lowercase(s) then
          begin
               result.addr1:=identifiers[e].spot;
               result.shifted:=not identifiers[e].global;
          end;
     end;
     if result.addr1<-99999 then
     begin
        if valfloat(s) then
        begin
             addvar(s,strtofloat(s));
             result.addr1:=valindex;
        end
        else
            showmessage('unknown variable: '+s);
     end;
end;

procedure CompileCode(cs: array of string);
var
   s: string;
  lin,hcs: integer;
  i1,i2: integer;
  paramshift: integer; // number of values before the proc entry
  pushingshift: integer; // for variables
  params: res1; // array of string
begin
     hcs:=high(cs);
     i2:=-1;
     localvars:=0;
     paramshift:=0;
     pushingshift:=0;
     inproc:=false;
     for lin:=0 to hcs do // for labels
     begin
          cs[lin]:=lowercase(CleanString(cs[lin]));
          s:=cs[lin];
          if s<>'' then
          begin
               i1:=pos('@@',s);
               if i1>0 then // the substring "@@" was found in s
               begin
                    AddVar(copy(s,1+i1,length(s)-1-i1),i2);
                    cs[lin]:='';
               end
               else
               begin // potentially increment the instruction counter
                    i1:=CompNum(s);
                    if i1>-1 then // instruction name found
                       inc(i2);
               end;
          end;
     end;
     for lin:=0 to hcs do // loop through strings to turn them into information in the program array
     begin
          s:=cs[lin];
          if s<>'' then
          begin
               i1:=CompNum(s);
               if i1>-1 then
               begin
                    params:=getparamnames(s);
                    if comps[i1].numofparams=high(params)+1 then
                    begin
                         setlength(program1,high(program1)+2);
                         with program1[high(program1)] do
                         begin
                              num:=i1;
                              if high(params)>-1 then
                              begin
                                   param1:=getvarnum(params[0]);
                              end;
                              if high(params)>0 then
                              begin
                                   param2:=getvarnum(params[1]);
                              end;
                         end;
                    end
                    else
                        showmessage('There are not the right number of parameters in this line: '+s);
               end
               else if pos('proc',s)>0 then // beginning or ending a procedure
               begin
                    paramshift:=0; // number of values before the proc entry
                    pushingshift:=0; // for variables
                    if pos('endproc',s)>0 then
                    begin // remove the local identifiers from memory
                         setlength(identifiers,high(identifiers)+1-localvars);
                         inproc:=false;
                    end
                    else
                        inproc:=true;
                    localvars:=0;
               end
               else if (pos('_p',s)>0)or(pos('_v',s)>0) then
               begin // parameter or variable declarations
                     inc(localvars);
                     if pos('_p',s)>0 then
                     begin
                          inc(paramshift);
                          inc(localvars);
                          setlength(identifiers,high(identifiers)+2);
                          identifiers[high(identifiers)].name:=copy(s,4,999);
                          with identifiers[high(identifiers)] do
                          begin
                               spot:=-localvars;
                               global:=false;
                          end;
                     end
                     else  // variable declaration
                     begin
                          inc(pushingshift);
                          setlength(identifiers,high(identifiers)+2);
                          identifiers[high(identifiers)].name:=copy(s,4,999);
                          with identifiers[high(identifiers)] do
                          begin
                               spot:=0; // this must be changed
                               // also the other pushed vars must be shifted
                               global:=false;
                          end;
//--->
                          // loop through all of the local pushed variables
                          // increment each's "spot" property
                     end;
               end
               else
                   showmessage('Unknown instruction: '+s);
          end;
     end;
end;

Procedure TForm1.Compile;
var // compile the strings in memo1 into instructions in program1
   lin: integer;
  cs: array of string;
begin
     SetLength(cs,memo1.lines.count+1);
     for lin:=0 to memo1.lines.count do
         cs[lin]:=memo1.lines[lin];
     CompileCode(cs);
end;

Procedure TForm1.CompileVars;
var // get the variable identifiers out of memo2 and into the array
   s: string;
  lin: integer;
begin
     identifiers:=nil; // clear the identifiers array
     for lin:=0 to memo2.lines.count do
     begin
          s:=memo2.lines[lin];
          if s<>'' then
             AddVar(s,0);
     end;
     MaxStackSize:=high(identifiers)+5;
end;

procedure Apush(var PCounter: integer);
begin
     AddressStack[index1]:=PCounter;
     inc(index1);
     if index1>1000 then
     begin
          PCounter:=99999999;
     end;
end;

function Apop: integer;
begin
     if index1<1 then
        result:=-99
     else
     begin
          dec(index1);
          result:=AddressStack[index1];
     end;
end;

function PushVar(value1: real): boolean;
// result is true when an error has occured
begin
     result:=false;
     if valindex>999 then
     begin
          result:=true;
          ShowMessage('Error: variable stack overflow');
     end
     else
     begin
          inc(valindex);
          values[valindex]:=value1;
     end;
end;

function PopVar: real;
begin
     if valindex<1 then
        ShowMessage('Error: variable stack underflow')
     else
     begin
          dec(valindex);
          result:=values[valindex];
     end;
end;

function GetAddrofaddrdata(ad: addrdata): integer;
begin
     with ad do
     begin
          if shifted then
             result:=valindex+addr1
          else
              result:=addr1;
     end;
end;

procedure Delay1;
var
  t: integer;
begin
     t:=gettickcount;
     while gettickcount-t<instrdelay do
     begin
          Application.Processmessages;
     end;
end;

procedure TForm1.Run(can: tcanvas);
var
  programcounter: integer; // simulated EIP register
  i1,time1: integer; // used for time calculations
  lasttime: integer;
  real1: real; // value used like a register
  r1,r2: real;
  pc: integer;
label ExitTurtleProgram;
begin
     TurtleRunning:=true;
     running:=false;
     programcounter:=0;
     real1:=0;
     index1:=0;
     can.moveto(round(p.x),round(p.y)); // move pen to initial location
     time1:=gettickcount;
     pc:=0;
     lasttime:=gettickcount;
     while TurtleRunning and (programcounter<=high(program1))and(programcounter>=0) do
     // loop through the instructions while there is still instructions to execute
     begin
          inc(pc);
          if optionsfrm.ProgramTimeStopChB.Checked and (gettickcount-time1>maxtime) then
          // if the program has been running for over 5 seconds or whatever time maxtime was changed to
          begin
               showmessage('This is taking too long.');
               Goto ExitTurtleProgram;
          end;
          if optionsfrm.checkbox1.checked then
          begin
               if gettickcount-lasttime>50 then
               begin
                    lasttime:=gettickcount;
                    debugfrm.UpdateDisplay;
               end;
          end;
          if InstrDelay>0 then
             Delay1 // wait for a number of ms defined by InstrDelay
          else if pc mod 1000=0 then
             Application.ProcessMessages;
          with program1[programcounter] do
          case num of
            0: begin
                    r1:=values[GetAddrofaddrdata(param1)];
                    p.x:=p.x+r1*cos(direction);
                    p.y:=p.y+r1*sin(direction);
                    can.lineto(round(p.x),round(p.y));
               end; // FD
            1: begin
                    direction:=direction+values[GetAddrofaddrdata(param1)]*pi/180;
               end; // RT
            2: begin
                    direction:=direction-values[GetAddrofaddrdata(param1)]*pi/180;
               end; // LT
            3: begin     // CMP
                    r1:=values[GetAddrofaddrdata(param1)];
                    r2:=values[GetAddrofaddrdata(param2)];
                    if r1>r2 then
                       comparison:=1
                    else if r2>r1 then
                         comparison:=-1
                    else
                        comparison:=0;
               end;
            4: begin
                    if comparison<0 then
                       programcounter:=round(values[GetAddrofaddrdata(param1)]); // JL
               end;
            5: if comparison>=0 then
                  programcounter:=round(values[GetAddrofaddrdata(param1)]); // JNL
            6: if comparison=0 then
                  programcounter:=round(values[GetAddrofaddrdata(param1)]); // JE
            7: begin
                    i1:=GetAddrofaddrdata(param1);
                    values[i1]:=values[i1]+1;
               end; // inc
            8: begin
                    i1:=GetAddrofaddrdata(param1);
                    values[i1]:=values[i1]-1; // dec
               end;
            9:  real1:=real1+values[GetAddrofaddrdata(param1)]; // add
            10: real1:=real1-values[GetAddrofaddrdata(param1)]; // sub
            11: real1:=values[GetAddrofaddrdata(param1)];  // load
            12: values[GetAddrofaddrdata(param1)]:=real1; // saveto
            13: real1:=sqr(real1);  // sqr
            14: if real1>=0 then
                   real1:=sqrt(real1);  // sqrt
            15: can.Pen.style:=psclear; // PenUp
            16: can.pen.style:=pssolid; // pendown
            17: programcounter:=round(values[GetAddrofaddrdata(param1)]); // jmp
            18: real1:=real1*values[GetAddrofaddrdata(param1)]; // mul
            19: begin
                     r1:=values[GetAddrofaddrdata(param1)];
                     if abs(r1)>0.000000001 then
                        real1:=real1/r1; // div
               end;
            20: real1:=sin(real1); // sin
            21: real1:=cos(real1); // cos
            22: can.Pen.color:=round(real1); // setcolor
            23: begin
                     Apush(programcounter);
                     if programcounter>9999999 then
                        ShowMessage('Error: Stack overflow')
                     else
                         programcounter:=round(values[GetAddrofaddrdata(param1)]); // call
            end;
            24: begin
                     programcounter:=APop; // ret
                     if programcounter<0 then
                        ShowMessage('Error: Stack underflow');
            end;
            25: begin
                     if PushVar(values[GetAddrofaddrdata(param1)]) then
                        programcounter:=-99; // exit the program
                     // push
            end;
            26: begin
                     dec(valindex);
                     if valindex<0 then
                        programcounter:=-99;
                     // pop
            end;
            27: real1:=abs(real1); // abs
          end;
          inc(programcounter);
          EIP1:=programcounter;
     end;
     ExitTurtleProgram:
     Form1.Button1.Caption:='&Run';
     TurtleRunning:=false;
     EIP1:=high(program1)+1;
     if Debugfrm.visible then
        Debugfrm.UpdateDisplay;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin  // Run / Stop button
     if Button1.Caption='&Run' then
        Button1.Caption:='S&top'
     else
     begin
          Button1.Caption:='&Run';
          TurtleRunning:=false;
          Exit;
     end;

     p.x:=OutputFrm.clientwidth shr 1;
     p.y:=OutputFrm.clientheight shr 1;
     // initial position is set

     direction:=0;
     program1:=nil; // clear the turtle program
     valindex:=-1; // there aren't any variables before the program is compiled
     CompileVars; // update variables used in program1
     Compile; // update program1
     if optionsfrm.checkbox1.checked then
     begin
          running:=true;
          DebugFrm.ShowModal;
     end
     else
          OutputFrm.Showmodal; // execute instructions in program1
end;

Procedure InitComps;
begin
     // list all the command identifiers and the number of parameters for each
     comps[0].name:='FD';
     comps[0].NumOfParams:=1;
     comps[1].name:='RT';
     comps[1].NumOfParams:=1;
     comps[2].name:='LT';
     comps[2].NumOfParams:=1;
     comps[3].name:='CMP';
     comps[3].NumOfParams:=2;
     comps[4].name:='JL';
     comps[4].NumOfParams:=1;
     comps[5].name:='JNL';
     comps[5].NumOfParams:=1;
     comps[6].name:='JE';
     comps[6].NumOfParams:=1;
     comps[7].name:='inc';
     comps[7].NumOfParams:=1;
     comps[8].name:='dec';
     comps[8].NumOfParams:=1;
     comps[9].name:='Add';
     comps[9].NumOfParams:=1;
     comps[10].name:='Sub';
     comps[10].NumOfParams:=1;
     comps[11].name:='Load';
     comps[11].NumOfParams:=1;
     comps[12].name:='SaveTo';
     comps[12].NumOfParams:=1;
     comps[13].name:='sqr';
     comps[13].NumOfParams:=0;
     comps[14].name:='sqrt';
     comps[14].NumOfParams:=0;
     comps[15].name:='PenUp';
     comps[15].NumOfParams:=0;
     comps[16].name:='PenDown';
     comps[16].NumOfParams:=0;
     comps[17].name:='jmp';
     comps[17].NumOfParams:=1;
     comps[18].name:='mul';
     comps[18].NumOfParams:=1;
     comps[19].name:='div';
     comps[19].NumOfParams:=1;
     comps[20].name:='sin';
     comps[20].NumOfParams:=0;
     comps[21].name:='cos';
     comps[21].NumOfParams:=0;
     comps[22].name:='SetColor';
     comps[22].NumOfParams:=0;
     comps[23].name:='Call';
     comps[23].NumOfParams:=1;
     comps[24].name:='Ret';
     comps[24].NumOfParams:=0;
     comps[25].name:='Push';
     comps[25].NumOfParams:=1;
     comps[26].name:='Pop';
     comps[26].NumOfParams:=0;
     comps[27].name:='Abs';
     comps[27].NumOfParams:=0;
end;
function ExecuteFile(FileName, Params, DefaultDir: string): HWND;
begin
     Result := ShellExecute(form1.handle,nil,PChar(FileName), PChar(Params),
     PChar(DefaultDir), SW_SHOWNORMAL);
end;

function GetDir: string;
var
  x: integer;
begin
     result:=application.exename;
     x:=length(result);
     while (x>1)and(result[x]<>'\') do
           dec(x);
     result:=copy(result,1,x-1);
end;

procedure OpenFolderFile(s: string);
var
  fn: string;
  x: integer;
begin
     fn:=GetDir; // get the directory containing this program without the last "\"
     x:=ExecuteFile(s,'',fn);
     if fileexists(fn+'\'+s) and (x<5) then
        showmessage('This should work because the file exists but for some reason it won''t open.');
     if x<5 then
        ShowMessage('There was a problem loading a file.'+#13+
        'Make sure you have the following files:'+#13+
        '- Help.html'+#13+
        '- HelpLPS.html'+#13+
        '- HelpV.html'+#13+
        '- HelpC.html'+#13+
        '- HelpGlossary.html'+#13+
        'These files should be in the same folder as this exe file.');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     direction:=0;
     InitComps;
     TurtleRunning:=false;
     MaxTime:=5000; // 5 seconds maximum for a program being executed
     instrdelay:=0; // initially no delay between executing steps in the turtle program
     opendialog1.InitialDir:=GetDir;
     Savedialog1.InitialDir:=GetDir; // same directory as the exe file of this program
     application.HintHidePause:=20000; // have the hints displayed for a while so everyone can read them
end;

procedure TForm1.Button2Click(Sender: TObject);
var // Show Variables
  s: string;
  x: integer;
begin
{     s:='';
     for x:=0 to high(identifiers) do
     begin
          s:=s+identifiers[x].name+' = '+floattostr(values[identifiers[x].spot])
          +#13; // the #13 character creates another line in the showmessage
     end;
     showmessage(s); }
     DebugFrm.ShowModal;
end;

procedure TForm1.Button3Click(Sender: TObject);
var // Crash
  x: integer;
  y: real;
begin
     x:=0;
     y:=2/x; // Wupps! Divided by 0.
     showmessage(floattostr(y)); // Distplay the value of infinity?
end;

procedure TForm1.Button4Click(Sender: TObject);
var // Save
  tf: textfile;
  s: string;
  lin: integer;
begin
     if savedialog1.execute then
     begin
          s:=savedialog1.filename;
          if pos('.',s)<1 then
             s:=s+'.trt';
          if fileexists(s) then
             if messagedlg('A file with this name already exists.  Would you like to right over it?',mtconfirmation,[mbyes,mbno],0)=mrno then
                exit;
          assignfile(tf,s);
          rewrite(tf);
          s:='var';
          writeln(tf,s);
          for lin:=0 to memo2.lines.count do // save the variable names
          begin
               s:=memo2.lines[lin];
               writeln(tf,s);
          end;
          s:='instr';
          writeln(tf,s);
          for lin:=0 to memo1.lines.count do // save the instructions
          begin
               s:=memo1.lines[lin];
               writeln(tf,s);
          end;
          closefile(tf);
     end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var // Open
  tf: textfile;
  s: string;
  lin: integer;
begin
     if opendialog1.execute then
     begin
          assignfile(tf,opendialog1.filename);
          reset(tf);
          readln(tf,s);
          if lowercase(s)<>'var' then
          begin
               closefile(tf);
               showmessage('This is not the right type of file.');
               exit;
          end;
          memo2.clear;
          while not eof(tf) do // load the variables
          begin
               readln(tf,s);
               if lowercase(s)<>'instr' then
                  memo2.lines.add(s)
               else
                   break;
          end;
          memo1.clear;
          while not eof(tf) do // load the code
          begin
               readln(tf,s);
               memo1.lines.add(s);
          end;
          closefile(tf);
     end;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
     OptionsFrm.ShowModal;
end;


procedure TForm1.Button7Click(Sender: TObject);
begin
     OpenFolderFile('Help.html');
end;

end.
