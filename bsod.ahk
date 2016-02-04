BSODtext := ["A problem has been detected and Windows has been shut down to prevent damage to your computer."
	, "The problem seems to be caused by the following file: SPCMDCON.SYS"
	, "PAGE_FAULT_IN_NONPAGED_AREA AND YOU MOM IS REALLY A MAN"
	, "If this is the first time you've seen this stop error screen, restart your computer. If this screen appears again, follow these steps:"
	, "Check to make sure any new hardware or software is properly installed. If this is a new installation, ask your hardware or software manufacturer for any Windows updates you might need."
	, "If problems continue, disable or remove any newly installed hardware or software. Disable BIOS memory options such as caching or shadowing. If you need to use Safe Mode to remove or disable components, restart your computer, press F8 to select Advanced Startup Options, and then select Safe Mode."
	, "Technical information:"
	, "*** STOP: 0x00000050 (0xFD3094C2,0x00000001,0xFBFE7617,0x00000000)"
	, "*** SPCMDCON.SYS - Address FBFE7617 base at FBFE5000, DateStamp 3d6dd67c"]
TOGGLE := 0

gui, MyGui:new, -Caption, BSODlol
gui, MyGui:color, 000082

for i, line in BSODtext {
	addLine(line)
	addLine("")
}

return ; End AutoExec

Escape::
	gui, MyGui:show, % "w" A_ScreenWidth " h" A_ScreenHeight " x0 y0"
return

F1::
	TOGGLE := !TOGGLE

	if TOGGLE
		gui, MyGui:show, % "w" A_ScreenWidth " h" A_ScreenHeight " x0 y0"
	else
		gui, MyGui:hide
return


addLine(text, color:="FFFFFF") {
	textSizeRatio := 0.015625
	textSize := floor(textSizeRatio * A_ScreenWidth)

	gui, font, % "s" textSize " c" color, Lucida Console
	gui, add, text, % "x0 y+0 w" A_ScreenWidth - 40, % text
}

:*:ryan::
	gui, MyGui:show, % "w" A_ScreenWidth " h" A_ScreenHeight " x0 y0"
return

