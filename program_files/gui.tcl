package require Tk
set file_name ""
#Proc to open file
set pwd1 [pwd]
proc -s {filename} {
  set rc [catch {file size $filename} size]
  return [expr {$rc == 0 && $size > 0}]
}
regsub {\\program_files\\(.*)$} $::argv0 {\program_files\errorfile} error_file_name
regsub {\\program_files\\(.*)$} $::argv0 {\program_files\error_proc_file} error_proc_file
regsub {\\program_files\\(.*)$} $::argv0 {\program_files\output} source_file_name1
set language_file_name ""
set language ""
proc set_language {language1} {
	global language_file_name language
	set language $language1
	set lang_file_name1 "\\program_files\\${language}_procs_file"	
	regsub {\\program_files\\(.*)$} $::argv0 $lang_file_name1 language_file_name
}
encoding system utf-8
proc compile {} {
	global file_name language_file_name error_file_name error_proc_file language
	if {$file_name == ""} {
		tk_messageBox -icon error -title "No file selected" -type ok -message "Open a file to compile"
	} else {
                regsub {\\program_files\\(.*)$} $::argv0 {\program_files\main_file} source_file_name
		if {$language_file_name == ""} {
			tk_messageBox -icon error -title "Language not selected" -type ok -message "Please select a language"
			return
		}
		if {[winfo exists .output]} {
			tk_messageBox -icon error -title "Output window not closed" -type ok -message "Please close output window for new execution"
			return
		}
		set a [open $error_file_name w]
		close $a
		source $language_file_name
		source $source_file_name
		set error_val [main $file_name]
		source $error_proc_file
		set err_text [$language]
		.result.op configure -state normal
		.result.op delete 0.0 end
		if {$err_text == ""} {
			.result.op insert end "Execution successful"
		} else {
			source $error_proc_file
			set err_text [$language]
			.result.op insert end "Execution failed\n"
			.result.op insert end $err_text
			tk_messageBox -icon error -title "Execution failed" -type ok -message "Oops!:(.Please see the result tab for error message."
			destroy .output
		}
		.result.op configure -state disabled 
	}
}

proc run {} {
	global file_name
	regsub {\\program_files\\(.*)$} $::argv0 {\program_files\output.html} output_file_name
	_launchBrowser $output_file_name
	file copy $output_file_name ${file_name}.html

}
proc save_file {} {
	global file_name
	if {[winfo exists .t] == 0 } {
		tk_messageBox -icon error -title "Text window not found" -type ok -message "Please open a new or existing file"
		return
 	} elseif {$file_name == ""} {
		tk_messageBox -icon error -title "File name not found" -type ok -message "Please use save as option to save file for first time"
		return
	}
	if { $file_name != "" } {
		set file1 [open $file_name w]
		fconfigure $file1 -encoding utf-8
		set i 1;
		while {$i < [.t index end]} {
			set j 0;
			set k 1
			set i1 ${i}.${j}
			set i2 ${i}.${k}
			while { $i2 == [.t index $i2] } {
				set b [.t get $i1 $i2];
				puts -nonewline $file1 $b
				set j [expr $j+1];
				set k [expr $k+1];
				set i1 ${i}.${j}
				set i2 ${i}.${k}
			}
			set i [expr $i+1];
			puts $file1 "\n"
		}
		close $file1
		set file1 [open $file_name r]
		set file2 [open ${file_name}_temp w]
		fconfigure $file1 -encoding utf-8
		fconfigure $file2 -encoding utf-8
		while {[gets $file1 line]>=0} {
			if {[regexp {^\s*$} $line] == 1} {
			} else {
				regsub -all {^M} $line {} line1
				puts $file2 $line1
			}
		}		
		close $file1
		close $file2
		set file1 [open $file_name w]
		set file2 [open ${file_name}_temp r]
		fconfigure $file1 -encoding utf-8
		fconfigure $file2 -encoding utf-8
		while {[gets $file2 line]>=0} {
			puts $file1 $line
		}		
		close $file1
		close $file2
		file delete ${file_name}_temp
	}
}
#Proc to save as file
proc save_as_file {} {
	global file_name
	if {[winfo exists .t] == 0 } {
		tk_messageBox -icon error -title "Text window not found" -type ok -message "Please open a new or existing file"
		return
 	} 
	set types {
		{{W Language Files} {.w}}
		{{All Files} *}
	}
        regsub {\\program_files\\(.*)$} $::argv0 {\my_files} initial_dir1
	set types {
		{{W Language Files} {.w}}
		{{All Files} *}
	}
	set file_name [tk_getSaveFile -defaultextension a -filetypes $types -initialdir $initial_dir1]
	if { $file_name != "" } {
		set file1 [open $file_name w]
		fconfigure $file1 -encoding utf-8
		set i 1;
		while {$i < [.t index end]} {
			set j 0;
			set k 1
			set i1 ${i}.${j}
			set i2 ${i}.${k}
			while { $i2 == [.t index $i2] } {
				set b [.t get $i1 $i2];
				puts -nonewline $file1 $b
				set j [expr $j+1];
				set k [expr $k+1];
				set i1 ${i}.${j}
				set i2 ${i}.${k}
			}
			set i [expr $i+1];
			puts $file1 "\n"
		}
		close $file1
		set file1 [open $file_name r]
		set file2 [open ${file_name}_temp w]
		fconfigure $file1 -encoding utf-8
		fconfigure $file2 -encoding utf-8
		while {[gets $file1 line]>=0} {
			if {[regexp {^\s*$} $line] == 1} {
			} else {
				regsub -all {^M} $line {} line1
				puts $file2 $line1
			}
		}		
		close $file1
		close $file2
		set file1 [open $file_name w]
		set file2 [open ${file_name}_temp r]
		fconfigure $file1 -encoding utf-8
		fconfigure $file2 -encoding utf-8
		while {[gets $file2 line]>=0} {
			puts $file1 $line
		}		
		close $file1
		close $file2
		file delete ${file_name}_temp
	}
}


#Proc to open new file
proc new_file1 {} {
   global file_name
   if {[winfo exists .t]} {
      set answer [tk_messageBox -icon question -title "Save existing file???" -type yesnocancel -message "Do you want to save existing file?"]
      switch -- $answer {
         yes {
                save_file
               destroy .t
         }
         no {destroy .t}
         cancel {return}
      }
   }
   destroy .f
   global res_win
   set res_win [text .t -width 1000 -height 290]
   pack .t -expand 0 -side top
   focus .t
   set file_name ""
}

proc new_file {} {
   global file_name
   if {[winfo exists .t]} {
      set answer [tk_messageBox -icon question -title "Save existing file???" -type yesnocancel -message "Do you want to save existing file?"]
      switch -- $answer {
         yes {
                save_file
               destroy .t
         }
         no {destroy .t}
         cancel {return}
      }
   }
   destroy .f
   global res_win
   set res_win [text .t -width 1000 -height 290]
   pack .t -expand 0 -side top
   focus .t
}
proc open_file {} {
	global file_name
	set types {
		{{W Language Files} {.w}}
		{{All Files} *}
	}
        regsub {\\program_files\\(.*)$} $::argv0 {\my_files} initial_dir1
	set file_name [tk_getOpenFile -filetypes $types -initialdir $initial_dir1]
	if {$file_name != ""} {
		set file1 [open $file_name r]
		fconfigure $file1 -encoding utf-8
		set line_no 0
		new_file 	
		while {[gets $file1 line]>=0} {
			.t insert end ${line}\n
		}
		close $file1
	}
}

proc launchBrowser url {
    global tcl_platform

    if {$tcl_platform(platform) eq "windows"} {
        # first argument to "start" is "window title", which is not used here
        set command [list {*}[auto_execok start] {}]
        # (older) Windows shell would start a new command after &, so shell escape it with ^
        #set url [string map {& ^&} $url]
        # but 7+ don't seem to (?) so this nonsense is gone
        if {[file isdirectory $url]} {
            # if there is an executable named eg ${url}.exe, avoid opening that instead:
            set url [file nativename [file join $url .]]
        }
    } elseif {$tcl_platform(os) eq "Darwin"} {
        # It *is* generally a mistake to use $tcl_platform(os) to select functionality,
        # particularly in comparison to $tcl_platform(platform).  For now, let's just
        # regard it as a stylistic variation subject to debate.
        set command [list open]
    } else {
        set command [list xdg-open]
    }
    exec {*}$command $url &
}

proc _launchBrowser {url} {
    if [catch {launchBrowser $url} err] {
        tk_messageBox -icon error -message "error '$err' with '$command'"
    }
}

wm title . "W" 
#wm resizable . 0 0
frame .f -width 1000 -height 490
pack .f
#set file_name "Click on open button to open file here"
menu .menu
. configure -menu .menu
bind . <KeyPress-Control_L><n> {new_file1}
bind . <KeyPress-Control_R><n> {new_file1}
bind . <KeyPress-Control_L><o> {open_file}
bind . <KeyPress-Control_R><o> {open_file}
bind . <KeyPress-Control_L><s> {save_file}
bind . <KeyPress-Control_R><s> {save_file}
bind . <F9> {compile}
bind . <F10> {run}

menu .menu.file1
.menu add cascade -menu .menu.file1 -label File
.menu.file1 add command -label "New    ctrl+n" -command {new_file1} 
.menu.file1 add command -label "Open   ctrl+o" -command {open_file} 
.menu.file1 add command -label "Save   ctrl+s" -command {save_file} 
.menu.file1 add command -label "Save as" -command {save_as_file} 

menu .menu.execute
.menu add cascade -menu .menu.execute -label Execute
.menu.execute add command -label "Compile   F9" -command {compile}
.menu.execute add command -label "Launch.. F10" -command {run}

encoding system utf-8
menu .menu.language 
.menu add cascade -menu .menu.language -label Language
.menu.language add radiobutton -label "Hindi" -command "set_language hindi"
.menu.language add radiobutton -label "Tamil" -command "set_language tamil"
.menu.language add radiobutton -label "Samskritham" -command "set_language sanskrit"
#.menu.language add radiobutton 

menu .menu.help
.menu add cascade -menu .t.menu.help -label Help

# Result window
set result [frame .result -width 1000 -height 6 ]
#.result configure -state disabled
pack .result -side bottom 
label .result.res_label -text "Result" -font {{Times New Roman} 10 bold} -foreground blue -justify left
pack .result.res_label -side top
text .result.op -width 1000 -height 9
.result.op configure -state disabled 
pack .result.op -expand 1 -fill both
#.menu.execute add cascade -menu [list .f.menu.execute.compile .f.menu.execute.run] -label Execute
#.menu.execute.compile add command -label Compile -command {compile} 
#.menu.execute.run add command -label Run -command {run}
