# 1. Locate and open the JTAG-to-Avalon Master Service
set service_paths [get_service_paths master]

if {[llength $service_paths] == 0} {
    puts "Error: No JTAG-to-Avalon Master Bridge found!"
    exit
}

# Select the first available master service path
set master_path [lindex $service_paths 0]
open_service master $master_path

# 2. Define memory parameters
# Note: Avalon Master Bridge uses BYTE addresses. 
# If your Avalon bus is word-addressed (16-bit), 25'h1FF_FFFE words = 0x3FFFFFC bytes.
set start_byte_address 0x0
set total_bytes 0x3FFFFFC

puts "Reading SDRAM from byte address $start_byte_address ($total_bytes bytes)..."

# 3. Perform a fast burst memory read
# This returns a Tcl list of byte values (integers 0-255)
set raw_data [master_read_memory $master_path $start_byte_address $total_bytes]

# 4. Stream data out to stdout so your Python script can capture it
foreach byte $raw_data {
    puts $byte
}

# 5. Clean up and close connection
close_service master $master_path
puts "SUCCESS: Read complete."
