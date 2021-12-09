[Files]
Source: "miniunz.dll"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall;
Source: "libgcc_s_dw2-1.dll"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall;
Source: "libwinpthread-1.dll"; DestDir: "{tmp}"; Flags: dontcopy deleteafterinstall;

[Code]
const
  MAX_PATH = $1024;

type
  zlib_filefunc64_def = record
    zopen64_file: THandle;
    zread_file: THandle;
    zwrite_file: THandle;
    ztell64_file: THandle;
    zseek64_file: THandle;
    zclose_file: THandle;
    zerror_file: THandle;
    opaque: THandle;
  end;
  unz_global_info64 = record
    number_entry: Int64;
    size_comment: UINT;
    padding0: UINT;
  end;
  tm_unz = record
    tm_sec: UINT;    
    tm_min: UINT;    
    tm_hour: UINT;   
    tm_mday: UINT; 
    tm_mon: UINT;    
    tm_year: UINT; 
  end;  
  unz_file_info64_s = record
    version: LongInt;             
    version_needed: LongInt;      
    flag: LongInt;                
    compression_method: LongInt;  
    dosDate: LongInt;             
    crc: LongInt;                 
    compressed_size: Int64;  
    uncompressed_size: Int64;
    size_filename: LongInt;       
    size_file_extra: LongInt;     
    size_file_comment: LongInt;   

    disk_num_start: LongInt;      
    internal_fa: LongInt;         
    external_fa: LongInt;         

    tmu_date: tm_unz;
  end;
  TOnExtractProgress = function(BaseName: string; const Progress, ProgressMax: Int64): Boolean;

function SetCurrentDirectoryW(dir: WideString): BOOL;
  external 'SetCurrentDirectoryW@kernel32.dll stdcall';
function CreateDirectoryW(dir: WideString; opt: LongInt): BOOL;
  external 'CreateDirectoryW@kernel32.dll stdcall';

procedure fill_win32_filefunc64W(var funcs: zlib_filefunc64_def);
  external 'fill_win32_filefunc64W@files:miniunz.dll,libgcc_s_dw2-1.dll,libwinpthread-1.dll cdecl loadwithalteredsearchpath';
function unzOpen2_64(filePath: WideString; var funcs: zlib_filefunc64_def): THandle;
  external 'unzOpen2_64@files:miniunz.dll,libgcc_s_dw2-1.dll,libwinpthread-1.dll cdecl loadwithalteredsearchpath';
function unzClose(file: THandle): Integer;
  external 'unzClose@files:miniunz.dll,libgcc_s_dw2-1.dll,libwinpthread-1.dll cdecl loadwithalteredsearchpath';
function unzGetGlobalInfo64(file: THandle; var pglobal_info: unz_global_info64): Integer;
  external 'unzGetGlobalInfo64@files:miniunz.dll,libgcc_s_dw2-1.dll,libwinpthread-1.dll cdecl loadwithalteredsearchpath';
function unzGoToNextFile(file: THandle): Integer;
  external 'unzGoToNextFile@files:miniunz.dll,libgcc_s_dw2-1.dll,libwinpthread-1.dll cdecl loadwithalteredsearchpath';
function do_extract_currentfile(file: THandle; var popt_extract_without_path: Integer; var popt_overwrite: Integer; password: AnsiString): Integer;
  external 'do_extract_currentfile@files:miniunz.dll,libgcc_s_dw2-1.dll,libwinpthread-1.dll cdecl loadwithalteredsearchpath';
function unzGetCurrentFileInfo64(file: THandle; var pfile_info: unz_file_info64_s; fileName: AnsiString; fileNameBufferSize: LongInt; extraField: LongInt; extraFieldSize: LongInt; comment: LongInt; commentBufferSize: LongInt): Integer;
  external 'unzGetCurrentFileInfo64@files:miniunz.dll,libgcc_s_dw2-1.dll,libwinpthread-1.dll cdecl loadwithalteredsearchpath';

function Unzip(zipFile: String; workingDir: String; callback: TOnExtractProgress): Boolean;
var
  file: THandle;
  funcs: zlib_filefunc64_def;
  info: unz_global_info64;
  popt_extract_without_path: Integer;
  popt_overwrite: Integer;
  loopIndex: Integer;
  file_info: unz_file_info64_s;
  fileName: AnsiString;
begin
  CreateDirectoryW(workingDir, 0);
  SetCurrentDirectoryW(workingDir);

  fill_win32_filefunc64W(funcs);
  file := unzOpen2_64(zipFile, funcs);

  if file = 0 then
  begin
    Result := False;
    Exit;
  end;

  unzGetGlobalInfo64(file, info);
  
  popt_extract_without_path := 0;
  popt_overwrite := 0;
  fileName := '';
  SetLength(fileName, MAX_PATH);

  Result := True;

  for loopIndex := 0 to info.number_entry - 1 do
  begin
    unzGetCurrentFileInfo64(file, file_info, fileName, MAX_PATH, 0, 0, 0, 0);

    if (do_extract_currentfile(file, popt_extract_without_path, popt_overwrite, '') <> 0) then
    begin
      Result := False;
      Break;
    end;

    if (unzGoToNextFile(file) <> 0) then
    begin
      Break;
    end; 

    if not callback(fileName, loopIndex, info.number_entry - 1) then
    begin
      Result := False;
      Break;
    end;
  end;

  unzClose(file);
end;
