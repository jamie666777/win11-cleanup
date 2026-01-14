response = MsgBox("Open the cleanup log file?", 36, "View Log")

If response = 6 
Then
    Set o = CreateObject("WScript.Shell")
    o.Run "notepad.exe log.log"
End If