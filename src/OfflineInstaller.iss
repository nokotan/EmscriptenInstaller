[Setup]
AppName=EmscriptenOffline
AppVersion=3.1.20
WizardStyle=modern
DefaultDirName={autopf}\EmscriptenOffline
DefaultGroupName=EmscriptenOffline
OutputDir=userdocs:Inno Setup Examples Output
OutputBaseFilename=EmscriptenOffline
PrivilegesRequired=lowest
DisableDirPage=yes
DisableReadyPage=yes

[Languages]
Name: en; MessagesFile: "compiler:Default.isl"
Name: ja; MessagesFile: "compiler:Languages/Japanese.isl"
Name: zh_cn; MessagesFile: "Languages/Unofficial/ChineseSimplified.isl"
Name: zh_tw; MessagesFile: "Languages/Unofficial/ChineseTraditional.isl"
Name: kr; MessagesFile: "Languages/Unofficial/Korean.isl"

[Files]
Source: ".emscripten"; DestDir: "{app}";
Source: "tmp\emscripten\install\*"; DestDir: "{app}\upstream"; Flags: recursesubdirs;
Source: "tmp\node\*"; DestDir: "{app}\node"; Flags: recursesubdirs;
Source: "tmp\python\*"; DestDir: "{app}\python"; Flags: recursesubdirs;
Source: "tmp\java\*"; DestDir: "{app}\java"; Flags: recursesubdirs;

[Registry]
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName: "EM_CONFIG"; \
    ValueData: "{app}\.emscripten"; Flags: preservestringtype;
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName: "EMSDK"; \
    ValueData: "{app}"; Flags: preservestringtype;
Root: HKCU; Subkey: "Environment"; ValueType:expandsz; ValueName: "PATH"; \
    ValueData: "{olddata};{app}\upstream\emscripten;{app}\python;{app}\node\node-v14.18.2-win-x64\bin;"; Flags: preservestringtype
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName: "EMSDK_NODE"; \
    ValueData: "{app}\node\node-v14.18.2-win-x64\bin\node.exe"; Flags: preservestringtype;
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName: "EMSDK_PYTHON"; \
    ValueData: "{app}\python\python.exe"; Flags: preservestringtype;
Root: HKCU; Subkey: "Environment"; ValueType:string; ValueName: "PYTHONUTF8"; \
    ValueData: "1"; Flags: preservestringtype;
