[Code]
var
  ExtractZipPage: TOutputProgressWizardPage;
  ExtractAbortButton: TNewButton;
  ExtractAborted: Boolean;
  ExtractZipFiles: TStrings;
  ExtractZipFilesOutputDirs: TStrings;
  ExtractingZipFileIndex: Integer;
  ExtractZipPageCallback: TOnExtractProgress;

procedure ExtractAbortButtonOnClick(Sender: TObject);
begin
  ExtractAborted := MsgBox(SetupMessage(msgStopDownload), mbConfirmation, MB_YESNO) = IDYES;
end;

procedure ExtractZipWizardPage_Initialize();
begin
  ExtractZipPage := CreateOutputProgressPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc));
  ExtractAbortButton := TNewButton.Create(ExtractZipPage);
  ExtractZipFiles := TStringList.Create;
  ExtractZipFilesOutputDirs := TStringList.Create;

  with ExtractAbortButton 
  do begin
    Caption := SetupMessage(msgButtonStopDownload);
    Parent := ExtractZipPage.Surface;
    Left := ExtractZipPage.ProgressBar.Left; 
    Top := ExtractZipPage.ProgressBar.Top + ExtractZipPage.ProgressBar.Height + ScaleY(8);
    Anchors := [akLeft, akTop];
    Width := WizardForm.CalculateButtonWidth([Caption]);
    Height := WizardForm.CancelButton.Height;
    Visible := False;
    OnClick := @ExtractAbortButtonOnClick;
  end;
end;

procedure ExtractZipPage_Show();
begin
  ExtractZipPage.Show;
  ExtractAbortButton.Visible := True;
end;

procedure ExtractZipPage_Hide();
begin
  ExtractZipPage.Hide;
  ExtractAbortButton.Visible := False;
end;

procedure ExtractZipPage_Clear();
begin
  ExtractZipFiles.Clear;
  ExtractZipFilesOutputDirs.Clear;
end;

procedure ExtractZipPage_Add(zipFileName, outputDir: String);
begin
  ExtractZipFiles.Add(zipFileName);
  ExtractZipFilesOutputDirs.Add(outputDir);
end;

function ExtractZipPage_OnExtractProgress(FileName: String; const Progress, ProgressMax: Int64): Boolean;
var
  TotalProgress, TotalProgressMax: Int64;
begin
  TotalProgress := ExtractingZipFileIndex * 1000 + Progress * 1000 / ProgressMax; 
  TotalProgressMax := ExtractZipFiles.Count * 1000;
  
  ExtractZipPage.SetProgress(TotalProgress, TotalProgressMax);
  ExtractZipPage.Msg1Label.Caption := 'Extracting...';
  ExtractZipPage.Msg2Label.Caption := FileName;

  ExtractZipPageCallback(FileName, Progress, ProgressMax);

  Result := not ExtractAborted;
end;

function ExtractZipPage_Extract(callback: TOnExtractProgress): Boolean;
var
  fileName, outputDir: String;
begin
  ExtractAborted:= False;
  ExtractZipPageCallback := callback;

  for ExtractingZipFileIndex := 0 to ExtractZipFiles.Count - 1 do
  begin
    fileName := ExtractZipFiles[ExtractingZipFileIndex];
    outputDir := ExtractZipFilesOutputDirs[ExtractingZipFileIndex];

    if not Unzip(fileName, outputDir, @ExtractZipPage_OnExtractProgress) then
    begin
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;
    