; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
#include <idp.iss>

#define MyAppName "Virtual Trucker Rich Presence"
#define MyAppVersion "2.5.1"
#define MyAppPublisher "Virtual Trucker Rich Presence"
#define MyAppURL "https://github.com/VirtualTruckerRPC/Virtual-Trucker-Rich-Presence/"
#define MyAppExeName "VirtualTruckerRichPresence.exe"
#define MyServiceName "VirtualTruckerRichPresence"
#define RunHiddenVbs "RunHidden.vbs"
#define RebootVTRPC "RebootVTRPC.bat"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{29075F67-AFC2-4622-AE1B-7D965BC53408}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputBaseFilename=VirtualTruckerRichPresenceSetup
SetupIconFile=..\assets\vtrpc.ico
Compression=lzma
SolidCompression=yes
AppMutex={#MyAppExeName}

[Types]
Name: full;    Description: "Full installation";
Name: custom;    Description: "Update installation"; Flags: iscustom

[Components]
Name: app; Description: "Virtual Trucker Rich Presence"; Types: full custom; Flags: fixed
Name: etcars; Description: "ETCARS 0.15 (required)"; Types: full;

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\release\VirtualTruckerRichPresence.exe"; DestDir: "{app}"; Flags: ignoreversion;
Source: "..\vbs\RunHidden.vbs"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bat\RebootVTRPC.bat"; DestDir: "{app}"; Flags: ignoreversion;
Source: "..\node_modules\node-notifier\vendor\SnoreToast\SnoreToast.exe"; DestDir: "{app}\vendor\SnoreToast\"; Flags: ignoreversion;
Source: "..\node_modules\node-notifier\vendor\notifu\*.*"; DestDir: "{app}\vendor\notifu\"; Flags: ignoreversion;
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#RunHiddenVbs}""";
Name: "{commonstartup}\{#MyAppName}"; Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#RunHiddenVbs}"""; Tasks:StartMenuEntry;
Name: "{group}\Reboot VT-RPC"; Filename: "{app}\{#RebootVTRPC}";
Name: {group}\Uninstall; Filename: {uninstallexe};

[Tasks]
Name: "StartMenuEntry" ; Description: "Start {#MyAppName} when Windows starts (Recommended)" ; GroupDescription: "Windows Startup"; MinVersion: 4,4;
Name: "InstallETCARS"; Description: "Install ETCARS after installation"; GroupDescription: "Other Tasks"; Components: etcars;
Name: "SpeedUnitConfigurationMPH"; Description: "Use MPH for speed and distance units"; GroupDescription: "Configuration"; Flags: unchecked 

[Run]
Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#RunHiddenVbs}"""; Description: "Run {#MyAppName} immediately"; Flags: postinstall runhidden;
Filename: "{tmp}\etcars.exe"; Description: "Install ETCARS"; Flags: postinstall; Components: etcars; Tasks: InstallETCARS;

[UninstallRun]
Filename: "{cmd}"; Parameters: "/C ""taskkill /im {#MyAppExeName} /f /t";

[Code]
procedure InitializeWizard;
begin
    idpDownloadAfter(wpReady);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
    if CurPageID = wpReady then
    begin
        // User can navigate to 'Ready to install' page several times, so we 
        // need to clear file list to ensure that only needed files are added.
        idpClearFiles;

        if IsComponentSelected('etcars') then
            idpAddFile('https://myalpha.menzelstudios.com/downloads/ETCARSx64.exe', ExpandConstant('{tmp}\etcars.exe'));
  end;
end;

procedure PerformAfterInstallActions();
  var 
      clientConfFile : string;
  begin    

    clientConfFile := ExpandConstant('{app}\clientconfiguration.json');
  
    Log('PerformAfterInstallActions');

    if FileExists(clientConfFile) then         
    begin
      DeleteFile(clientConfFile);
    end;

    if IsTaskSelected('SpeedUnitConfigurationMPH') then
    begin
        SaveStringToFile(clientConfFile, '{ "configuration": { "distanceUnit": "m", "customMessage": "" } }', True);
    end
    else
    begin
        SaveStringToFile(clientConfFile, '{ "configuration": { "distanceUnit": "km", "customMessage": "" } }', True);
    end;
  end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if  CurStep=ssPostInstall then
    begin
         PerformAfterInstallActions();
    end
end;