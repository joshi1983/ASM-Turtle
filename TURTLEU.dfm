�
 TFORM1 0O
  TPF0TForm1Form1Left� Top<Width�Height�CaptionTurtleColor	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrderOnCreate
FormCreatePixelsPerInch`
TextHeight TLabelLabel1LeftqTopWidthOHeightCaptionInstructionsFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.StylefsBold 
ParentFont  TLabelLabel2LeftTopWidthDHeightCaption	VariablesFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.StylefsBold 
ParentFont  TMemoMemo1LeftrTop Width�Height�AnchorsakLeftakTopakRightakBottom Font.CharsetANSI_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameArial
Font.Style Lines.Strings@@startAll:load 0saveto x @@Start:FD yRT 1inc x	CMP x,360	JL @start// draw circle load yadd 0.1saveto y	mul 30000setcolorJmp @startAll// draw different sizes 
ParentFont
ScrollBarsssBothTabOrder WordWrap  TButtonButton1Left-TopWidthxHeightHint:Compile the instructions into a turtle program and executeAnchorsakTopakRight Caption&RunParentShowHintShowHint	TabOrderOnClickButton1Click  TMemoMemo2LeftTop WidthbHeight�AnchorsakLeftakTopakBottom Lines.Stringsxycount TabOrder  TButtonButton2Left-Top?WidthxHeightHint:Look at the variable identifiers and values in the programAnchorsakTopakRight Caption&Show Execution DataParentShowHintShowHint	TabOrderOnClickButton2Click  TButtonButton3Left-Top� WidthxHeightHint)Crash the program for Debugging in DelphiAnchorsakTopakRight Caption&CrashTabOrderVisibleOnClickButton3Click  TButtonButton4Left-Top� WidthxHeightHint%Save the code and variables to a fileAnchorsakTopakRight Caption&SaveParentShowHintShowHint	TabOrderOnClickButton4Click  TButtonButton5Left-Top� WidthxHeightHint#Load variables and code from a fileAnchorsakTopakRight Caption&OpenParentShowHintShowHint	TabOrderOnClickButton5Click  TButtonButton6Left-TopaWidthxHeightAnchorsakTopakRight CaptionO&ptionsTabOrderOnClickButton6Click  TButtonButton7Left-Top� WidthxHeightAnchorsakTopakRight Caption&HelpTabOrderOnClickButton7Click  TSaveDialogSaveDialog1Filter,ASM Turtle (*.TRT)|*.TRT|All Files (*.*)|*.*Left(Top�   TOpenDialogOpenDialog1Filter1Asm Turtle File (*.trt)|*.trt|All Files (*.*)|*.*Left(Top�    