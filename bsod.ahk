; ryunp 01/10/16
; Oh christ allimaginary what have I created!

; [Instructions]
;   This program looks for a file called "bsod.txt" for any custom text.
;   Enter a trigger hotkey or string (character sequence) below.
;     See https://autohotkey.com/docs/KeyList.htm for key combinations.
; [Options]
;   CLASSIC_MODE - Emulates the classic graphic driver failure look: 4:3 ratio.
;   DISABLE_TOGGLING - Toggling of BSOD screens with triggers. (EVIL_MODE)

; ++ Options ++
CLASSIC_MODE = 1
DISABLE_TOGGLING = 0

; ++ HOTKEY: Replace between the quotes ++
BSODhotkey := "#r" ; Run (Win + r)
ignoreMe()
; ++ HOTSTRING: Replace 'BSODsequence' with any character sequence ++
:*:BSODsequence::
	toggleBSOD()

return


; ----------------------------------
; -- Warranty void below here bub --
; ----------------------------------
ignoreMe() { ; guh, damn you hotstring and it's non-dynamic nature
	global
	surprise := new BSODSim(CLASSIC_MODE)
	DEBUG = 0

	local fn := func("toggleBSOD")
	hotkey, % BSODHotkey, % fn
	debugMsg(getMonitorInfo())
}

; -- Hotkey/string callback --
toggleBSOD() {
	global

	surprise.activate()
	if not (DISABLE_TOGGLING)
		if not (TOGGLE := !TOGGLE)
			surprise.deactivate()
}


; -- Classes --
class BSODSim {
	windows := []

	__New(classic_mode=0) {
		winData := {"BGcolor": "0000C0", "classic_mode": classic_mode}
		for i, mon in getMonitors()
			this.windows.push(new BSODwindow(mon, winData, getTextLines()))
	}

	activate() {
		for i, win in this.windows
			win.show()
	}

	deactivate() {
		for i, win in this.windows
			win.hide()
	}
}
class BSODwindow {
	window := {"hWnd": 0, "BGcolor": 0, "classic_mode": 0}
	monitor := {"index": 0, "x": 0, "y": 0, "width": 0, "height": 0}
	text := {"x": 0, "y": 0, "width": 0, "size": 0, "padRight": 0, "lines": []}

	__New(monitorData, windowData, textLines) {
		merge(this.monitor, monitorData)
		merge(this.window, windowData)
		this.text.lines := textLines

		debugMsg("index = "this.monitor.index "`r`n"
			. "x = "this.monitor.x "`r`n"
			. "y = "this.monitor.y "`r`n"
			. "width = "this.monitor.width "`r`n"
			. "height = "this.monitor.height "`r`n"
			. "lines = "this.text.lines.length() "`r`n"
			. "classic_mode = "this.window.classic_mode ", " windowData.classic_mode "`r`n"
			. "BGcolor = "this.window.BGcolor "`r`n")

		this.init()
	}

	init() {
		txt := this.text
		win := this.window
		mon := this.monitor

		; Register window
		gui, New, +hwndTMPHWND -Caption, % "bsod" mon.index
		win.hWnd := TMPHWND

		gui, Color, % win.BGcolor

		; Assume base width (covers full width)
		txt.width := mon.width
		
		; Change width if necessary (skip if already 4:3 ratio)
		if not (mon.height / mon.width = 0.75) {
			; Want black bars
			if win.classic_mode {
				; landscape
				if (mon.width > mon.height) {
					txt.width := Round(mon.height * 1.333333)
				} else if (mon.height > 768) {
					; Portrait, and width large than minumum
					txt.width := Round(mon.width / 1.333333)
				}
				; If we want bars, but not wide enough, no width set
				; which defaults to moniter width, which cancels out
				; to the expression (monWidth-monWidth)/2
				txt.x := (mon.width - txt.width) / 2
			}
		}

		; Other relative text properties
		txt.size := floor(txt.width * 0.014)
		txt.padRight := floor(txt.width * 0.04)

		; Add lines of text
		gui, font, % "cWhite s" txt.size, % "verdana"
		for i, line in txt.lines
			gui, add, text, % "x" txt.x " y+0 w" (txt.width - txt.padRight), % line

		; Rendering issues - Render bars after text
		if win.classic_mode {
			if (txt.width != mon.width) {
				Gui, Add, Progress, % "Background000000 x0 y" mon.y " w" txt.x " h" mon.height
				Gui, Add, Progress, % "Background000000 x" (mon.width - txt.x) " y" mon.y " w" txt.x " h" mon.height
			}
		}

		; DEBUG - create a ruler for pixel alignment test
		if DEBUG {
			steps := 5 0
			yOffsetPercent := 0.95
			gui, font, cff0000 s12 wbold
			loop, % steps
			{
				if (mod(A_Index-1, steps/5) == 0)
					gui, add, text, % "x" floor(mon.width/steps*(A_Index-1)) " y" mon.height*yOffsetPercent - 50, % (A_Index-1) * floor(mon.width/steps)
				gui, add, text, % "x" floor(mon.width/steps*(A_Index-1)) " y" mon.height*yOffsetPercent, % A_Index-1
			}
		}
	}

	show() {
		mon := this.monitor
		gui, % this.window.hWnd ":show", % "x" mon.x "y" mon.y " w" mon.width " h" mon.height
	}

	hide() {
		gui, % this.window.hWnd ":hide"
	}
}


; -- Functions --
; Check for custom text file or default back to orignal BSOD text
getTextLines() {
	file := "bsod.txt"

	hFile := FileOpen(file, "r")
	if (hFile.length()) {
		lines := []
		while (line := hFile.ReadLine())
			lines.push(line)
	} else {
		lines := ["A problem has been detected and Windows has been shut down to prevent damage to your computer.", ""
		, "The problem seems to be caused by the following file: SPCMDCON.SYS", ""
		, "PAGE_FAULT_IN_NONPAGED_AREA", ""
		, "If this is the first time you've seen this stop error screen, restart your computer. If this screen appears again, follow these steps:", ""
		, "Check to make sure any new hardware or software is properly installed. If this is a new installation, ask your hardware or software manufacturer for any Windows updates you might need.", ""
		, "If problems continue, disable or remove any newly installed hardware or software. Disable BIOS memory options such as caching or shadowing. If you need to use Safe Mode to remove or disable components, restart your computer, press F8 to select Advanced Startup Options, and then select Safe Mode.", ""
		, "Technical information:", ""
		, "*** STOP: 0x00000050 (0xFD3094C2, 0x00000001, 0xFBFE7617, 0x00000000)", ""
		, "*** SPCMDCON.SYS - Address FBFE7617 base at FBFE5000, DateStamp 3d6dd67c"]
	}
	hFile.close()

	return lines
}
getMonitors() {
	mons := []

	SysGet, mCount, 80
	loop, %mCount%
		mons.push(getMonitor(A_Index))

	return mons
}
getMonitor(idx) {
	SysGet, MonitorName, MonitorName, %idx%
	SysGet, Monitor, Monitor, %idx%
	SysGet, MonitorWorkArea, MonitorWorkArea, %idx%
	data := {"index": idx, "name": MonitorName
		, "x": MonitorLeft, "work_x": MonitorWorkAreaLeft
		, "y": MonitorTop, "work_y": MonitorWorkAreaTop
		, "width": MonitorRight - MonitorLeft, "work_width": MonitorWorkAreaRight - MonitorWorkAreaLeft
		, "height": MonitorBottom - MonitorTop, "work_height": MonitorWorkAreaBottom - MonitorWorkAreaTop}

	return data
}
getMonitorInfo(idx=0) {
	list := []

	for i, mon in getMonitors() {
		list.push("index: " mon.index "`r`n"
			. "name: " mon.name "`r`n"
			. "x: " mon.x " (" mon.work_x ")`r`n"
			. "y: " mon.y " (" mon.work_y ")`r`n"
			. "width: " mon.width " (" mon.work_width ")`r`n"
			. "height: " mon.height " (" mon.work_height ")`r`n")
	}

	return idx ? list[idx] : join(list, "`r`n")
}


; -- Object Helper Functions --
merge(to, from) {
	for k,v in from
		if to.HasKey(k)
			to[k] := from[k]
}

join(array, delim) {
	str := ""
	for i, v in array
		str .= v (i < array.length() ? delim : "")
	return str
}


; -- That one function every other funciton hates and is forced to the bottom --
debugMsg(msg) {
	if DEBUG
		msgbox % "--DEBUG--`r`n" msg
}

; -- :( --