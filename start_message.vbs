response = MsgBox("Windows cleanup is about to begin. Continue?", 52, "Cleanup")
If response = 7
Then
    WScript.Quit(1)
End If