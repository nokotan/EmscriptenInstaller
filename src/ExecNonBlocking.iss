[Code]
const
  WAIT_OBJECT_0 = $0;
  WAIT_TIMEOUT = $00000102;
  SEE_MASK_NOCLOSEPROCESS = $00000040;
  INFINITE = $FFFFFFFF; 
  PM_REMOVE = 1;

type
  TShellExecuteInfo = record
    cbSize: DWORD;
    fMask: Cardinal;
    Wnd: HWND;
    lpVerb: String;
    lpFile: String;
    lpParameters: String;
    lpDirectory: String;
    nShow: Integer;
    hInstApp: THandle;    
    lpIDList: DWORD;
    lpClass: String;
    hkeyClass: THandle;
    dwHotKey: DWORD;
    hMonitor: THandle;
    hProcess: THandle;
  end;
  TMsg = record
    hwnd: HWND;
    message: UINT;
    wParam: LongInt;
    lParam: LongInt;
    time: DWORD;
    pt: TPoint;
  end;
  TOnProgress = function(): Boolean;

function ShellExecuteEx(var lpExecInfo: TShellExecuteInfo): BOOL; 
  external 'ShellExecuteExA@shell32.dll stdcall';
function WaitForSingleObject(hHandle: THandle; dwMilliseconds: DWORD): DWORD; 
  external 'WaitForSingleObject@kernel32.dll stdcall';
function CloseHandle(hObject: THandle): BOOL;
  external 'CloseHandle@kernel32.dll stdcall';
function TerminateProcess(hHandle: THandle; exitCode: DWORD): BOOL;
  external 'TerminateProcess@kernel32.dll stdcall';

function PeekMessage(var lpMsg: TMsg; hWnd: HWND; wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL;
  external 'PeekMessageA@user32.dll stdcall';
function TranslateMessage(const lpMsg: TMsg): BOOL;
  external 'TranslateMessage@user32.dll stdcall';
function DispatchMessage(const lpMsg: TMsg): Longint;
  external 'DispatchMessageA@user32.dll stdcall';

procedure ProcessMessages;
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end;

function Execute(command: String; arguments: String; workingDir: String; nCmdShow: Integer; callback: TOnProgress): Boolean;
var
  ExecInfo: TShellExecuteInfo;
begin
  ExecInfo.cbSize := SizeOf(ExecInfo);
  ExecInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  ExecInfo.Wnd := 0;
  ExecInfo.lpFile := '"' + command + '"';
  ExecInfo.lpParameters := arguments;
  ExecInfo.lpDirectory := workingDir;
  ExecInfo.nShow := nCmdShow;

  Result := True;

  if ShellExecuteEx(ExecInfo) then
  begin
    while WaitForSingleObject(ExecInfo.hProcess, $1000) <> WAIT_OBJECT_0
    do begin   
      ProcessMessages;
      
      if not callback() then
      begin
        Result := False;
        TerminateProcess(ExecInfo.hProcess, 1);
        Break;
      end;
    end;

    CloseHandle(ExecInfo.hProcess);
  end; 
end;

