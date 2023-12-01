/*
 * =============================================================================================== *
 * Author           : RaptorX    <graptorx@gmail.com>
 * Script Name      : Hotshow
 * Script Version   : 1.0
 * Homepage         : 
 *
 * Creation Date    : September 22, 2010
 * Modification Date: 
 *
 * Description      :
 * ------------------
 *
 * -----------------------------------------------------------------------------------------------
 * License          :           Copyright �2011 RaptorX <GPLv3>
 *
 *          This program is free software: you can redistribute it and/or modify
 *          it under the terms of the GNU General Public License as published by
 *          the Free Software Foundation, either version 3 of  the  License,  or
 *          (at your option) any later version.
 *
 *          This program is distributed in the hope that it will be useful,
 *          but WITHOUT ANY WARRANTY; without even the implied warranty  of
 *          MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE.  See  the
 *          GNU General Public License for more details.
 *
 *          You should have received a copy of the GNU General Public License
 *          along with this program.  If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>
 * -----------------------------------------------------------------------------------------------
 *
 * [GUI Number Index]
 *
 * GUI 01 - Main [Background]
 * GUI 02 - HotkeyText
 *
 * =============================================================================================== *
 */ 

;+--> ; ---------[Includes]---------
#include *i %a_scriptdir%
#include lib\klist.h.ahk
;-
 
;+--> ; ---------[Directives]---------
#NoEnv
#SingleInstance Force
; --
SetBatchLines -1
SendMode Input
SetTitleMatchMode, Regex
SetWorkingDir %A_ScriptDir%
onExit, Clean
;-

;+--> ; ---------[Basic Info]---------
s_name      := "Hotshow"                ; Script Name
s_version   := "1.0"                    ; Script Version
s_author    := "RaptorX"                ; Script Author
s_email     := "graptorx@gmail.com"     ; Author's contact email
getparams()
; update(s_version)
;-

;+--> ; ---------[General Variables]---------
sec       :=  1000                      ; 1 second
min       :=  sec * 60                  ; 1 minute
hour      :=  min * 60                  ; 1 hour
; --
SysGet, mon, Monitor                    ; Get the boundaries of the current screen
SysGet, wa_, MonitorWorkArea            ; Get the working area of the current screen
mid_scrw  :=  a_screenwidth / 2         ; Middle of the screen (width)
mid_scrh  :=  a_screenheight / 2        ; Middle of the screen (heigth)
; --
s_ini     :=                            ; Optional ini file
s_xml     :=                            ; Optional xml file
;-

;+--> ; ---------[User Configuration]---------
BgColor := "BG-Green.png"
mods    := "Ctrl,Shift,Alt,LWin,RWin"
keylist := klist("all", "mods")
;-

;+--> ; ---------[Main]---------
if !FileExist("res")
{
    FileCreateDir, % "res"
    FileInstall, res\BG-Blue.png, res\BG-Blue.png, 1 ;Background Image
    FileInstall, res\BG-Red.png, res\BG-Red.png, 1
    FileInstall, res\BG-Green.png, res\BG-Green.png, 1
}

; Background GUI  [Main]
;{
Gui, +owner +AlwaysOnTop +Disabled +Lastfound -Caption 
Gui, Color, FFFFFF
Gui, Add, Picture,,res\%BgColor%
Winset, transcolor, FFFFFF 0

Gui, Show, w300 h70 Hide, % "Background" 
;}

; Hotkey Text GUI
;{
Gui, 2: +Owner +AlwaysOnTop +Disabled +Lastfound -Caption
Gui, 2: Color, 026D8D
Gui, 2: Font, Bold s15 Arial
Gui, 2: Add, Text, Center cWhite w300 vhotkeys
Winset, transcolor, 026D8D 0

Gui, 2: Show, w300 h70 Hide, % "HotkeyText"
;}

Loop, Parse, keylist, %a_space%
    if strLen(a_loopfield) = 1
        Hotkey, % "~*`" a_loopfield, Display
    else
        Hotkey, % "~*" a_loopfield, Display

Return ; End of autoexecute area
;-

;+--> ; ---------[Labels]---------
Display:
If a_thishotkey =
    Return
    
Loop, Parse, mods,`,
{
    GetKeyState, mod, %a_loopfield%
    If mod = D
        prefix = %prefix%%a_loopfield% +
}

StringTrimLeft, key, a_thishotkey, 2
if key=%a_space%
    key=Space
Gosub, Show
Return

Show:
Alpha=0
Duration=150
Imgx=23
Imgy=630
StringUpper, key, key, T
GuiControl, 2: Text, Hotkeys, %prefix% %key%
prefix := key :=
Gui, Show, x%imgx% y%imgy% NoActivate
imgx-=10
imgy+=15
Gui, 2: Show, x%imgx% y%imgy% NoActivate

Gosub, Fadein
Sleep 2000
Gosub, Fadeout
Gui, Hide
Gui, 2: Hide
Return

Fadein:
If faded=1 ;Do not fade if the window already faded in.
{
    Winset, transcolor, FFFFFF 255, Background
    Winset, transcolor, 026D8D 255, HotkeyText
    return
}

Loop, %duration% ; Fade in routine.
{
    Alpha+=255/duration
    Winset, transcolor, FFFFFF %Alpha%, Background
    Winset, transcolor, 026D8D %Alpha%, HotkeyText
    faded=1
}
Return

Fadeout:
Loop, %duration% ; Fade out routine
{
    Alpha-=255/duration
    Winset, transcolor, FFFFFF %Alpha%, Background
    Winset, transcolor, 026D8D %Alpha%, HotkeyText
    faded=0
}
return

Clean:
    if a_iscompiled
        FileDelete, res\*.png
    ExitApp
;-

;+--> ; ---------[Functions]---------
getparams(){
    global
    ; First we organize the parameters by priority [-sd, then -d , then everything else]
    ; I want to make sure that if i select to save a debug file, the debugging will be ON
    ; since the beginning because i use the debugging inside the next parameter checks as well.
    Loop, %0%
        param .= %a_index% .  a_space           ; param will contain the whole list of parameters
    
    if (InStr(param, "-h") || InStr(param, "--help")
    ||  InStr(param, "-?") || InStr(param, "/?")){
        debug ? debug("* ExitApp [0]", 2)
        Msgbox, 64, % "Accepted Parameters"
                  , % "The script accepts the following parameters:`n`n"
                    . "-h    --help`tOpens this dialog.`n"
                    . "-v    --version`tOpens a dialog containing the current script version.`n"
                    . "-d    --debug`tStarts the script with debug ON.`n"
                    . "-sd  --save-debug`tStarts the script with debug ON but saves the info on the `n"
                    . "`t`tspecified txt file.`n"
                    . "-sc  --source-code`tSaves a copy of the source code on the specified dir, specially `n"
                    . "`t`tuseful when the script is compiled and you want to see the source code."
        ExitApp
    }
    if (InStr(param, "-v") || InStr(param, "--version")){
        debug ? debug("* ExitApp [0]", 2)
        Msgbox, 64, % "Version"
                  , % "Author: " s_author " <" s_email ">`n" "Version: " s_name " v" s_version "`t"
        ExitApp
    }
    if (InStr(param, "-d") 
    ||  InStr(param, "--debug")){
        sparam := "-d "                         ; replace sparam with -d at the beginning.
    }
    if (InStr(param, "-sd") 
    ||  InStr(param, "--save-debug")){
        RegexMatch(param,"-sd\s(\w+\.\w+)", df) ; replace sparam with -sd at the beginning
        sparam := "-sd " df1  a_space           ; also save the output file name next to it
    }
    Loop, Parse, param, %a_space%
    {
        if (a_loopfield = "-d" || a_loopfield = "-sd" 
        ||  InStr(a_loopfield, ".txt")){        ; we already have those, so we just add the
            continue                            ; other parameters    
        }
        sparam .= a_loopfield . a_space
    }        
    sparam := RegexReplace(sparam, "\s+$","")   ; Remove trailing spaces. Organizing is done
    
    Loop, Parse, sparam, %a_space%
    {
        if (sdebug && !debugfile && (!a_loopfield || !InStr(a_loopfield,".txt") 
        || InStr(a_loopfield,"-"))){
            debug ? debug("* Error, debug file name not specified. ExitApp [1]", 2)
            Msgbox, 16, % "Error"
                      , % "You must provide a name to a txt file to save the debug output.`n`n"
                        . "usage: " a_scriptname " -sd file.txt"
            ExitApp
        }
        else if (sdebug){
            debugfile ? :debugfile := a_loopfield
            debug ? debug("") 
        }
        if (a_loopfield = "-d" 
        ||  a_loopfield = "--debug"){
            debug := True, sdebug := False
            debug ? debug("* " s_name " Debug ON`n* " s_name " [Start]`n* getparams() [Start]", 1)
        }
        if (a_loopfield = "-sd" 
        ||  a_loopfield = "--save-debug"){
            sdebug := True, debug := True
        }
        if (a_loopfield = "-sc" 
        ||  a_loopfield = "--source-code"){
            sc := True
            debug ? debug("* Copying source code")
            FileSelectFile, instloc, S16, source_%a_scriptname%
                          , % "Save source file to..."
                          , % "AutoHotkey Script (*.ahk)"
            if (!instloc){
                debug ? debug("* Canceled. ExitApp [1]", 2)
                ExitApp
            }
            FileInstall,HotShow.ahk,%instloc%
            if (!ErrorLevel){
                debug ? debug("* Source code successfully copied")
                MsgBox, 64, % "Source code copied"
                          , % "The source code was successfully copied"
                          , 10 ; 10s timeout
            }
            else 
            {
                debug ? debug("* Error while copying the source code")
                Msgbox, 16, % "Error while copying"
                          , % "There was an error while copying the source code.`nPlease check that "
                          . "the file is not already present in the current directory and that "
                          . "you have write permissions on the current folder."
                          , 10 ; 10s timeout
            }
        }
    }
    debug ? : debug("* " s_name " Debug OFF")
    if (sdebug && !debugfile){                      ; needed in case -sd is the only parameter given
        debug ? debug("* Error, debug file name not specified. ExitApp [1]", 2)
        Msgbox, 16, % "Error"
                  , % "You must provide a name to a txt file to save the debug output.`n`n"
                  .   "usage: " a_scriptname " -sd file.txt"
        ExitApp
    }
    if (sc = True){
        debug ? debug("* ExitApp [0]", 2)
        ExitApp
    }
    debug ? debug("* getparams() [End]", 2)
    return
}
debug(msg,delimiter = False){
    global
    static ft := True   ; First time
    
    t := delimiter = 1 ? msg := "* ------------------------------------------`n" msg
    t := delimiter = 2 ? msg := msg "`n* ------------------------------------------"
    t := delimiter = 3 ? msg := "* ------------------------------------------`n" msg 
                             .  "`n* ------------------------------------------"
    if (!debugfile){
        sdebug && ft ? (msg := "* ------------------------------------------`n"
                            .  "* " s_name " Debug ON`n* " s_name "[Start]`n"
                            .  "* getparams() [Start]`n" msg, ft := 0)
        OutputDebug, %msg%        
    }
    else if (debugfile){
        ft ? (msg .= "* ------------------------------------------`n"
                  .  "* " s_name " Debug ON`n* " s_name 
                  .  " [Start]`n* getparams() [Start]", ft := 0)
        FileAppend, %msg%`n, %debugfile%
    }
}
/*
update(lversion, rfile="github", logurl="", vline=1){
        global script, conf, debug

        debug ? debug("* update() [Start]", 1), node := conf.selectSingleNode("/AHK-Toolkit/@version")
        if  node.text != script.version
        {
            node.text := script.version
            conf.save(script.conf), conf.load(script.conf), node:=root:=options:=null             ; Save & Clean
        }
        
        if a_thismenuitem = Check for Updates
            Progress, 50,,, % "Updating..."

        logurl := rfile = "github" ? "https://raw.github.com/" script.author
                                   . "/" script.name "/ver/ver" : logurl

        RunWait %ComSpec% /c "Ping -n 1 google.com" ,, Hide  ; Check if we are connected to the internet
        if connected := !ErrorLevel
        {
            debug ? debug("* Downloading log file")

            if a_thismenuitem = Check for Updates
                Progress, 90

            UrlDownloadToFile, %logurl%, %a_temp%\logurl
            FileReadLine, logurl, %a_temp%\logurl, %vline%
            debug ? debug("* Version: " logurl)
            RegexMatch(logurl, "v(.*)", Version)
            rfile := rfile = "github" ? ("https://www.github.com/"  
                                      . script.author "/" 
                                      . script.name "/zipball/" (a_iscompiled ? "latest-compiled" : "latest"))
                                      : rfile
            debug ? debug("* Local Version: " lversion " Remote Version: " Version1)
            
            if (Version1 > lversion){
                Progress, Off
                debug ? debug("* There is a new update available")
                Msgbox, 0x40044
                      , % "New Update Available"
                      , % "There is a new update available for this application.`n"
                        . "Do you wish to upgrade to " Version "?"
                      , 10 ; 10s timeout
                IfMsgbox, Timeout
                {
                    debug ? debug("* Update message timed out", 3)
                    return 1
                }
                IfMsgbox, No
                {
                    debug ? debug("* Update aborted by user", 3)
                    return 2
                }
                debug ? debug("* Downloading file to: " a_temp "\ahk-tk.zip")
                Download(rfile, a_temp "\ahk-tk.zip")
                oShell := ComObjCreate("Shell.Application")
                oDir := oShell.NameSpace(a_temp), oZip := oShell.NameSpace(a_temp "\ahk-tk.zip")
                oDir.CopyHere(oZip.Items), oShell := oDir := oZip := ""
                
                ; FileCopy instead of FileMove so that file permissions are inherited correctly.
                Loop, % a_temp "\RaptorX*", 1
                    FileCopyDir, %a_loopfilefullpath%, %a_scriptdir%, 1
                
                FileDelete, %a_temp%\ahk-tk.zip
                FileDelete, %a_temp%\RaptorX*
                
                Msgbox, 0x40040
                      , % "Installation Complete"
                      , % "The application will restart now."
                
                Reload
            }
            else if (a_thismenuitem = "Check for Updates")
            {
                Progress, Off
                debug ? (debug("* Script is up to date"), debug("* update() [End]", 2))
                Msgbox, 0x40040
                      , % "Script is up to date"
                      , % "You are using the latest version of this script.`n"
                        . "Current version is v" lversion
                      , 10 ; 10s timeout

                IfMsgbox, Timeout
                {
                    debug ? debug("* Update message timed out", 3)
                    return 1
                }
                return 0
            }
            else
            {
                debug ? (debug("* Script is up to date"), debug("* update() [End]", 2))
                return 0
            }
        }
        else
        {
            Progress, Off
            debug ? (debug("* Connection Failed", 3), debug("* update() [End]", 2))
            return 3
        }
    }
*/
;-

;+--> ; ---------[Hotkeys/Hotstrings]---------
~*Esc::ExitApp
Pause::Suspend, toggle
;-
