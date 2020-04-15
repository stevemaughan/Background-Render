unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

const
  WM_FINISHED_RENDERING = WM_USER + 2020;

type

  TRenderThread = class(TThread)
  private
    fColor: TColor;
    fBitmap: TBitmap;
    fID: string;
  public
    constructor Create(xID: string; xColor: TColor);
    destructor Destroy; override;

    procedure Execute; override;

    property ID: string read fID;
    property Bitmap: TBitmap read fBitmap write fBitmap;
  end;

  TMainForm = class(TForm)
    PaintBox1: TPaintBox;
    ColorListBox1: TColorListBox;
    procedure ColorListBox1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnFinishedRendering(var Msg: TMessage); message WM_FINISHED_RENDERING;
  private
    { Private declarations }
    Bitmap: TBitmap;
    LastID: string;
  public
    { Public declarations }

  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TForm2 }

procedure TMainForm.ColorListBox1Click(Sender: TObject);
var
  xGUID: TGUID;
begin

  //-- Create a unique ID for the thread
  CreateGUID(xGUID);

  //-- Store the ID for later reference
  LastID := GUIDToString(xGUID);

  //-- Create and start the rendering thread
  TRenderThread.Create(LastID, ColorListBox1.Selected);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Bitmap := TBitmap.Create;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Bitmap);
end;

procedure TMainForm.OnFinishedRendering(var Msg: TMessage);
var
  xRender: TRenderThread;
begin

  //-- Cast the parameters as a Rendering thread
  xRender := TRenderThread(Msg.WParam);

  //-- Update the screen only if the ID is the same as the latest ID
  if xRender.ID = LastID then
  begin
    FreeAndNil(Bitmap);
    Bitmap := xRender.Bitmap;
    xRender.Bitmap := nil;
    PaintBox1.Invalidate;
  end;

  //-- Free the rendering thread
  xRender.Free;
end;

procedure TMainForm.PaintBox1Paint(Sender: TObject);
var
  x, y: integer;
begin

  x := (PaintBox1.Width - Bitmap.Width) div 2;
  y := (PaintBox1.Height - Bitmap.Height) div 2;

  PaintBox1.Canvas.Brush.Color := clWhite;
  PaintBox1.Canvas.FillRect(PaintBox1.Canvas.ClipRect);

  if assigned(Bitmap) then
    PaintBox1.Canvas.CopyRect(Rect(x, y, x + Bitmap.Width, y + Bitmap.Height), Bitmap.Canvas, Bitmap.Canvas.ClipRect);
end;


{ TRenderThread }

constructor TRenderThread.Create(xID: string; xColor: TColor);
begin
  inherited Create(False);
  fColor := xColor;
  fID := xID;
  fBitmap := TBitmap.Create;
end;

destructor TRenderThread.Destroy;
begin
  fBitmap.Free;
  inherited;
end;

procedure TRenderThread.Execute;
begin
  //-- Twiddle your thumbs (simulates a time-intensive render)
  Sleep(3000);

  //-- Set the size
  fBitmap.SetSize(200, 300);

  fBitmap.Canvas.Lock;
  fBitmap.Canvas.Brush.Style := bsSolid;
  fBitmap.Canvas.Brush.Color := fColor;
  fBitmap.Canvas.FillRect(fBitmap.Canvas.ClipRect);
  fBitmap.Canvas.Unlock;

  //-- Let the GUI know
  PostMessage(MainForm.Handle, WM_FINISHED_RENDERING, NativeUInt(self), 0);
end;

end.
