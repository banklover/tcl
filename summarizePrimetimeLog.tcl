# Script to parse a PrimeTime log file and summarize errors and warnings

# Function to parse the log file
proc parse_log {log_file} {
    set errors {}
    set warnings {}

    # Open the log file for reading
    set file [open $log_file r]
    while {[gets $file line] >= 0} {
        # Check for errors
        if {[regexp {^ERROR: (.+)} $line match error_msg]} {
            lappend errors $error_msg
        }
        # Check for warnings
        if {[regexp {^WARNING: (.+)} $line match warning_msg]} {
            lappend warnings $warning_msg
        }
    }
    close $file

    return [list $errors $warnings]
}

# Function to print the summary
proc print_summary {errors warnings} {
    puts "Summary of Errors and Warnings:"
    puts "--------------------------------"

    puts "\nErrors:"
    if {[llength $errors] == 0} {
        puts "  No errors found."
    } else {
        foreach error $errors {
            puts "  $error"
        }
    }

    puts "\nWarnings:"
    if {[llength $warnings] == 0} {
        puts "  No warnings found."
    } else {
        foreach warning $warnings {
            puts "  $warning"
        }
    }
}

# Main script
if {$argc != 1} {
    puts "Usage: tclsh test.tcl <log_file>"
    exit 1
}

set log_file [lindex $argv 0]

if {![file exists $log_file]} {
    puts "Error: File '$log_file' does not exist."
    exit 1
}

set result [parse_log $log_file]
set errors [lindex $result 0]
set warnings [lindex $result 1]

print_summary $errors $warnings