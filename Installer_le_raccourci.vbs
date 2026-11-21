Option Explicit
' Cree les raccourcis "Armoire Designer" (Bureau + menu Demarrer) avec l'icone.
' Double-cliquez une seule fois sur ce fichier.
Dim sh, fso, dir, html, ico, exe, args, cands, p, url, k, lnk, dest, made
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
dir  = fso.GetParentFolderName(WScript.ScriptFullName)
html = dir & "\ArmoireDesigner.html"
ico  = dir & "\ArmoireDesigner.ico"
If Not fso.FileExists(html) Then
  MsgBox "ArmoireDesigner.html est introuvable dans " & dir, 16, "Armoire Designer"
  WScript.Quit
End If
url = "file:///" & Replace(Replace(html, "\", "/"), " ", "%20")
exe = ""
cands = Array( _
  sh.ExpandEnvironmentStrings("%ProgramFiles(x86)%") & "\Microsoft\Edge\Application\msedge.exe", _
  sh.ExpandEnvironmentStrings("%ProgramFiles%") & "\Microsoft\Edge\Application\msedge.exe", _
  sh.ExpandEnvironmentStrings("%ProgramFiles%") & "\Google\Chrome\Application\chrome.exe", _
  sh.ExpandEnvironmentStrings("%ProgramFiles(x86)%") & "\Google\Chrome\Application\chrome.exe", _
  sh.ExpandEnvironmentStrings("%LocalAppData%") & "\Google\Chrome\Application\chrome.exe")
For Each p In cands
  If exe = "" Then
    If fso.FileExists(p) Then exe = p
  End If
Next
made = ""
For Each k In Array(sh.SpecialFolders("Desktop"), sh.SpecialFolders("Programs"))
  dest = k & "\Armoire Designer.lnk"
  Set lnk = sh.CreateShortcut(dest)
  If exe <> "" Then
    lnk.TargetPath = exe
    lnk.Arguments = "--app=""" & url & """ --window-size=1600,950"
  Else
    lnk.TargetPath = html
  End If
  lnk.WorkingDirectory = dir
  lnk.Description = "Armoire Designer - conception de coffrets et armoires electriques"
  If fso.FileExists(ico) Then lnk.IconLocation = ico & ",0"
  lnk.WindowStyle = 1
  lnk.Save
  made = made & vbCrLf & dest
Next
If exe = "" Then
  MsgBox "Raccourcis crees (navigateur par defaut) :" & made, 64, "Armoire Designer"
Else
  MsgBox "Raccourcis crees (fenetre application) :" & made & vbCrLf & vbCrLf & "Vous pouvez aussi epingler l'application a la barre des taches.", 64, "Armoire Designer"
End If
