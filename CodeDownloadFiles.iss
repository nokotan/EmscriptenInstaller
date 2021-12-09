; -- CodeDownloadFiles.iss --
;
; This script shows how the CreateDownloadPage support function can be used to
; download temporary files while showing the download progress to the user.

# include "ExecNonBlocking.iss"
# include "Unzip.iss"
# include "ExtractWizardPage.iss"

[Setup]
AppName=Emscripten
AppVersion=2.0.22
WizardStyle=modern
DefaultDirName={autopf}\Emscripten
DefaultGroupName=Emscripten
OutputDir=userdocs:Inno Setup Examples Output
OutputBaseFilename=Emscripten
PrivilegesRequired=lowest

[Languages]
Name: en; MessagesFile: "compiler:Default.isl"
Name: ja; MessagesFile: "compiler:Languages/Japanese.isl"
Name: zh_cn; MessagesFile: "Languages/Unofficial/ChineseSimplified.isl"
Name: zh_tw; MessagesFile: "Languages/Unofficial/ChineseTraditional.isl"
Name: kr; MessagesFile: "Languages/Unofficial/Korean.isl"

[Files]
; These files will be downloaded
Source: ".emscripten"; DestDir: "{app}";
Source: "{tmp}\emscripten\install\*"; DestDir: "{app}\upstream"; Flags: external recursesubdirs; ExternalSize: 1087308881
Source: "{tmp}\node\*"; DestDir: "{app}\node"; Flags: external recursesubdirs; ExternalSize: 78402883
Source: "{tmp}\python\*"; DestDir: "{app}\python"; Flags: external recursesubdirs; ExternalSize: 36618068
Source: "{tmp}\java\*"; DestDir: "{app}\java"; Flags: external recursesubdirs; ExternalSize: 183857947

[Registry]
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName: "EM_CONFIG"; \
    ValueData: "{app}\.emscripten"; Flags: preservestringtype;
Root: HKCU; Subkey: "Environment"; ValueType:expandsz; ValueName: "PATH"; \
    ValueData: "{olddata};{app}\upstream\emscripten;{app}\python;{app}\node\node-v14.15.5-win-x64\bin;"; Flags: preservestringtype
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName: "EMSDK_NODE"; \
    ValueData: "{app}\node\node-v14.15.5-win-x64\bin\node.exe"; Flags: preservestringtype;
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName: "EMSDK_PYTHON"; \
    ValueData: "{app}\python\python.exe"; Flags: preservestringtype;
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName: "PYTHON_UTF8"; \
    ValueData: "1"; Flags: preservestringtype;

[Code]
var 
  DownloadPage: TDownloadWizardPage;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

function OnExtractProgress(FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
  ExtractZipWizardPage_Initialize;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
begin
  if CurPageID = wpReady then begin
    DownloadPage.Clear;
    DownloadPage.Add('https://storage.googleapis.com/webassembly/emscripten-releases-builds/win/6465a9acb820207acf7da44661a7de52d0a1ae3c/wasm-binaries.zip', 'emscripten-2.0.22.zip', '');
    DownloadPage.Add('https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-v14.15.5-win-x64.zip', 'emscripten-node.zip', '');
    DownloadPage.Add('https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/python-3.9.2-1-embed-amd64+pywin32.zip', 'emscripten-python.zip', '');
    DownloadPage.Add('https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/portable_jre_8_update_152_64bit.zip', 'emscripten-java.zip', '');
    
    {
    DownloadPage.Add('http://localhost:8080/emscripten-2.0.22.zip', 'emscripten-2.0.22.zip', '');
    DownloadPage.Add('http://localhost:8080/emscripten-node.zip', 'emscripten-node.zip', '');
    DownloadPage.Add('http://localhost:8080/emscripten-python.zip', 'emscripten-python.zip', '');
    DownloadPage.Add('http://localhost:8080/emscripten-java.zip', 'emscripten-java.zip', '');
    }

    DownloadPage.Show;
    try
      try
        DownloadPage.Download; // This downloads the files to {tmp}            
      except
        if DownloadPage.AbortedByUser then
          Log('Aborted by user.')
        else
          SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
        Result := False;
        Exit;
      end;
    finally
      DownloadPage.Hide;
    end;

    // ExtractTemporaryFile(ExpandConstant('miniunz.exe'));
    ExtractZipPage_Clear;
    ExtractZipPage_Add(ExpandConstant('{tmp}\emscripten-2.0.22.zip'), ExpandConstant('{tmp}\emscripten'));
    ExtractZipPage_Add(ExpandConstant('{tmp}\emscripten-node.zip'), ExpandConstant('{tmp}\node'));
    ExtractZipPage_Add(ExpandConstant('{tmp}\emscripten-python.zip'), ExpandConstant('{tmp}\python'));
    ExtractZipPage_Add(ExpandConstant('{tmp}\emscripten-java.zip'), ExpandConstant('{tmp}\java')); 
    ExtractZipPage_Show;
      
    ExtractAborted := False;
    try
      Result := ExtractZipPage_Extract(@OnExtractProgress);
    except
      Result := False;
    finally
      ExtractZipPage_Hide;
    end;
  end else
    Result := True;
end;