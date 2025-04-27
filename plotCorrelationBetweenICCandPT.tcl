# PrimeTime TCL script to draw timing correlation scatter plot
# comparing setup slacks between ICC2 and PrimeTime

# Load ICC2 slack and endpoint data
set icc2_data_file "icc2_timing_data.txt"

# Read ICC2 timing data into a list of key-value pairs
set icc2_data [dict create]
set file [open $icc2_data_file r]
while {[gets $file line] != -1} {
    set fields [split $line " "]
    set endpoint [lindex $fields 0]
    set slack [lindex $fields 1]
    dict set icc2_data $endpoint $slack
}
close $file

# Initialize PrimeTime slack data
set pt_slacks [list]
# Iterate over ICC2 endpoints and query PrimeTime for matching slacks
foreach endpoint [dict keys $icc2_data] {
    # Query PrimeTime for the setup slack of the endpoint using get_timing_paths
    set timing_paths [get_timing_paths -to $endpoint -delay_type setup -nworst 1]
    set pt_slack ""
    if {[llength $timing_paths] > 0} {
        set path_info [lindex $timing_paths 0]
        set pt_slack [get_attribute $path_info slack]
    }
    lappend pt_slacks [list $endpoint $pt_slack]
}

# Check if the data sizes match
if {[dict size $icc2_data] != [llength $pt_slacks]} {
    puts "Error: Mismatch in data size between ICC2 and PrimeTime slacks."
    exit 1
}
    set pt_slack ""
    foreach pt_entry $pt_slacks {
        if {[lindex $pt_entry 0] eq $endpoint} {
            set pt_slack [lindex $pt_entry 1]
            break
        }
    }
# Create a scatter plot
set plot_file "correlation_plot.txt"
set file [open $plot_file w]
puts $file "# ICC2_Slack PrimeTime_Slack"
foreach endpoint [dict keys $icc2_data] {
    set icc2_slack [dict get $icc2_data $endpoint]
    set pt_slack [lindex [lsearch -inline $pt_slacks $endpoint] 1]
    puts $file "$icc2_slack $pt_slack"
}
close $file

# Use PrimeTime's built-in plotting tool to generate the scatter plot
report_timing_correlation -input $plot_file -title "Timing Correlation: ICC2 vs PrimeTime" \
    -xlabel "ICC2 Setup Slack (ns)" -ylabel "PrimeTime Setup Slack (ns)" \
    -output "timing_correlation_plot.pdf"

puts "Timing correlation scatter plot generated: timing_correlation_plot.pdf"