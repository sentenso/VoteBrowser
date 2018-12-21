unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.WebBrowser, System.IOUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, Data.Bind.Components,
  Data.Bind.DBScope, Inifiles, FMX.Edit, FMX.Platform, FMX.VirtualKeyboard,
  FMX.Helpers.Android,
  Androidapi.Helpers,
  Androidapi.JNI.Provider,
  Androidapi.JNI.App,
  Androidapi.JNI.GraphicsContentViewText, FMX.ListBox,
  System.DateUtils;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Edit1: TEdit;
    Panel1: TPanel;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Edit3: TEdit;
    Edit4: TEdit;
    Button1: TButton;
    CheckBox1: TCheckBox;
    Button2: TButton;
    CheckBox2: TCheckBox;
    Label4: TLabel;
    ComboBox1: TComboBox;
    Label5: TLabel;
    ComboBox2: TComboBox;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WebBrowser1DidFinishLoad(ASender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure BrightnesSet;
  end;
  TSettings = class(TMemIniFile)
  private
    function GetDefaultURL: String;
    procedure SetDefaultURL(const Value: String);
    function GetPassword: String;
    procedure SetPassword(const Value: String);
    function GetCanBrowse: boolean;
    procedure SetCanBrowse(const Value: boolean);
    function GetWakeLock: boolean;
    procedure SetWakeLock(const Value: boolean);
    function GetSheldule: integer;
    procedure SetSheldule(const Value: integer);
    function GetLongDay: integer;
    procedure SetLongDay(const Value: integer);

  public
    procedure Save();
    property DefaultURL: String    read GetDefaultURL   write SetDefaultURL;
    property Password: String    read GetPassword   write SetPassword;
    property CanBrowse: boolean    read GetCanBrowse   write SetCanBrowse;
    property WakeLock: boolean    read GetWakeLock   write SetWakeLock;
    property Sheldule: integer    read GetSheldule   write SetSheldule;
    property LongDay: integer    read GetLongDay   write SetLongDay;

  end;

var
  Form1: TForm1;
  Settings: TSettings;
  brightness: integer;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

uses Android.JNI.PowerManager; //Подключаем библиотеку для управление питанием

//Установка яркости подсветки
procedure TForm1.BrightnesSet;
var
  Resolver: JContentResolver;
  AttainedBrightness: Single;
  LayoutParams: JWindowManager_LayoutParams;
  Window: JWindow;
begin
    Resolver := SharedActivityContext.getContentResolver;
    //Отключаем автоматический режим подсветки
    TJSettings_System.JavaClass.putInt(Resolver,TJSettings_System.JavaClass.SCREEN_BRIGHTNESS_MODE,TJSettings_System.JavaClass.SCREEN_BRIGHTNESS_MODE_MANUAL);
    //Устанавливаем нужную яркость
    TJSettings_System.JavaClass.putInt(Resolver,TJSettings_System.JavaClass.SCREEN_BRIGHTNESS,brightness);
    try
        AttainedBrightness := TJSettings_System.JavaClass.getInt(Resolver,TJSettings_System.JavaClass.SCREEN_BRIGHTNESS);
        CallInUIThread(
        procedure
        begin
            Window := SharedActivity.getWindow;
            LayoutParams := Window.getAttributes;
            LayoutParams.screenBrightness := AttainedBrightness / 255;
            Window.setAttributes(LayoutParams);
        end);
    except

    end;

end;

procedure TSettings.Save;
begin
  UpdateFile; //Обновление конфига
end;

function TSettings.GetDefaultURL: String;
begin
  result := ReadString('Settings', 'DefaultURL', 'http://google.ru'); //Получение адреса страницы по умолчанию из конфига. Если адрес не прописан - возвращает последний аргумент.
end;

procedure TSettings.SetDefaultURL(const Value: String);
begin
  WriteString('Settings', 'DefaultURL', Value); //Запись в конфиг адреса страницы по умолчанию
end;

function TSettings.GetPassword: String;
begin
  result := ReadString('Settings', 'Password', '1234'); //Получение из конфига пароля для входа в настройки
end;

procedure TSettings.SetPassword(const Value: String);
begin
  WriteString('Settings', 'Password', Value); //Запись пароля в конфиг
end;

function TSettings.GetCanBrowse: boolean;
begin
  result := ReadBool('Settings', 'CanBrowse', false); //Чтение из конфига значения параметра, отвечающего за отображение адресной строки
end;

procedure TSettings.SetCanBrowse(const Value: boolean);
begin
  WriteBool('Settings', 'CanBrowse', Value); //Запись в конфиг значения параметра, отвечающего за отображение адресной строки
end;

function TSettings.GetWakeLock: boolean;
begin
  result := ReadBool('Settings', 'WakeLockEn', true); //Чтение из конфига значения параметра, отвечающего за блокировку подсветки
end;

procedure TSettings.SetWakeLock(const Value: boolean);
begin
  WriteBool('Settings', 'WakeLockEn', Value); //Запись в конфиг значения параметра, отвечающего за блокировку подсветки
end;

function TSettings.GetSheldule: integer;
begin
  result := ReadInteger('Settings', 'Sheldule', 0); //Чтение из конфига ID варианта расписания работы
end;

procedure TSettings.SetSheldule(const Value: integer);
begin
  WriteInteger('Settings', 'Sheldule', Value); //Запись в конфиг ID варианта расписания работы
end;

function TSettings.GetLongDay: integer;
begin
  result := ReadInteger('Settings', 'LongDay', 0); //Чтение из конфига ID дня, для которого время работы будет увеличено на 1 час
end;

procedure TSettings.SetLongDay(const Value: integer);
begin
  WriteInteger('Settings', 'LongDay', Value); //Запись в конфиг ID дня, для которого время работы будет увеличено на 1 час
end;


procedure TForm1.Button1Click(Sender: TObject); //Сохранение настроек
begin
  Settings.SetDefaultURL(Edit2.Text);
  Settings.SetCanBrowse(CheckBox1.IsChecked);
  Settings.SetWakeLock(CheckBox2.IsChecked);
  Settings.SetSheldule(ComboBox1.ItemIndex);
  Settings.SetLongDay(ComboBox2.ItemIndex);
  if Edit3.Text = Settings.GetPassword then Settings.SetPassword(Edit4.Text) else ShowMessage('Пароль не был изменён!');
  Settings.Save;
  Panel1.Visible:=false;
  if Settings.GetWakeLock then
    AcquireWakeLock;
  if Settings.GetCanBrowse then ToolBar1.Visible:=true;
  WebBrowser1.Visible:=true;
  WebBrowser1.Navigate(Settings.GetDefaultURL);
end;

procedure TForm1.Button2Click(Sender: TObject); //Выход из настроек
begin
  Close;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  WebBrowser1.Navigate(Edit1.Text);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Settings.GetWakeLock then
    ReleaseWakeLock;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
begin
  Settings := TSettings.Create(TPath.Combine(TPath.GetHomePath, 'AppSettings.ini')); //Инициализация файла, в котором будут храниться настройки приложения. Возможно, не актуально.
  if Settings.GetWakeLock then
    AcquireWakeLock;
  ToolBar1.Visible:=Settings.GetCanBrowse;
  WebBrowser1.Position.Y:=0;
  WebBrowser1.Position.X:=0;
  WebBrowser1.Navigate(Settings.GetDefaultURL);
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
var
  FService : IFMXVirtualKeyboardService;
begin
  if Key = vkHardwareBack then //Если нажата кнопка "back"
  begin
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));
    if (FService <> nil) and (TVirtualKeyBoardState.Visible in FService.VirtualKeyBoardState) then
    begin
      // Нажата кнопка "back" при активной клавиатуре, ничего не делаем
    end else
    begin
      if Panel1.Visible then begin
        Panel1.Visible:=false;
        WebBrowser1.Visible:=true;
        ToolBar1.Visible:=Settings.GetCanBrowse;
        if Settings.GetWakeLock then
          AcquireWakeLock;
      end else
      if Settings.GetPassword = '' then begin //Если пароля нет - переход в настройки
        WebBrowser1.Visible:=false;
        ToolBar1.Visible:=false;
        Edit2.Text:=WebBrowser1.URL;
        CheckBox1.IsChecked:=Settings.GetCanBrowse;
        CheckBox2.IsChecked:=Settings.GetWakeLock;
        ComboBox1.ItemIndex:=Settings.GetSheldule;
        ComboBox2.ItemIndex:=Settings.GetLongDay;
        Edit3.Text:='';
        Edit4.Text:='';
        Panel1.Visible:=true;
        if Settings.GetWakeLock then
          ReleaseWakeLock;
      end else
      InputBox('Введите пароль','','',procedure(const AResult: TModalResult; const AValue: string) //Вызов диалога для ввода пароля
      begin
        // Сравление введенного пользователем пароля и в случае соответствия паролю для входа в настройки - переход в настройки
        if AValue = Settings.GetPassword then begin
          WebBrowser1.Visible:=false;
          ToolBar1.Visible:=false;
          Edit2.Text:=WebBrowser1.URL;
          CheckBox1.IsChecked:=Settings.GetCanBrowse;
          CheckBox2.IsChecked:=Settings.GetWakeLock;
          ComboBox1.ItemIndex:=Settings.GetSheldule;
          ComboBox2.ItemIndex:=Settings.GetLongDay;
          Edit3.Text:='';
          Edit4.Text:='';
          Panel1.Visible:=true;
          if Settings.GetWakeLock then
            ReleaseWakeLock;
        end;
      end);
      Key:=0;
    end;
  end else
  if (Key = sgiUpRightLong) then begin
    if Panel1.Visible then begin
      Panel1.Visible:=false;
      WebBrowser1.Visible:=true;
      ToolBar1.Visible:=Settings.GetCanBrowse;
      if Settings.GetWakeLock then
        AcquireWakeLock;
    end else
    if Settings.GetPassword = '' then begin //Если пароля нет - переход в настройки
      WebBrowser1.Visible:=false;
      ToolBar1.Visible:=false;
      Edit2.Text:=WebBrowser1.URL;
      CheckBox1.IsChecked:=Settings.GetCanBrowse;
      CheckBox2.IsChecked:=Settings.GetWakeLock;
      ComboBox1.ItemIndex:=Settings.GetSheldule;
      ComboBox2.ItemIndex:=Settings.GetLongDay;
      Edit3.Text:='';
      Edit4.Text:='';
      Panel1.Visible:=true;
      if Settings.GetWakeLock then
        ReleaseWakeLock;
    end else
    InputBox('Введите пароль','','',procedure(const AResult: TModalResult; const AValue: string) //Вызов диалога для ввода пароля
    begin
      // Сравление введенного пользователем пароля и в случае соответствия паролю для входа в настройки - переход в настройки
      if AValue = Settings.GetPassword then begin
        WebBrowser1.Visible:=false;
        Edit2.Text:=WebBrowser1.URL;
        CheckBox1.IsChecked:=Settings.GetCanBrowse;
        CheckBox2.IsChecked:=Settings.GetWakeLock;
        ComboBox1.ItemIndex:=Settings.GetSheldule;
        ComboBox2.ItemIndex:=Settings.GetLongDay;
        Edit3.Text:='';
        Edit4.Text:='';
        ToolBar1.Visible:=false;
        Panel1.Visible:=true;
        if Settings.GetWakeLock then
          ReleaseWakeLock;
      end;
    end);
    Key:=0;
  end;                         

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  IntervalMin, IntervalMax: TTime;
begin
  if ComboBox1.ItemIndex > 0 then begin

  case ComboBox1.ItemIndex of
    1: begin IntervalMin:= StrToTime('07:59:00'); IntervalMax:= StrToTime('17:00:00'); end;
    2: begin IntervalMin:= StrToTime('08:59:00'); IntervalMax:= StrToTime('18:00:00'); end;
    3: begin IntervalMin:= StrToTime('09:59:00'); IntervalMax:= StrToTime('19:00:00'); end;
  end;

  if DayOfTheWeek(Now) = Settings.LongDay then IntervalMax:=IncMinute(IntervalMax,60);


  if (CompareTime(Time,IntervalMin)>=0) AND (CompareTime(Time,IntervalMax)<=0) then begin
    brightness:=255;
    BrightnesSet;
  end else begin
    brightness:=0;
    BrightnesSet;
  end;
  end;

end;

procedure TForm1.WebBrowser1DidFinishLoad(ASender: TObject); //Обновление адреса в адресной строке при завершении загрузки страницы
begin
	Edit1.Text:=WebBrowser1.URL;
end;

end.
