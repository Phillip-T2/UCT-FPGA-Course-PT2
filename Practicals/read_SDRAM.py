import subprocess
import os
import numpy as np

# Define paths (adjust to your Intel FPGA Quartus installation directory)
system_console_path = "C:/altera_lite/25_1std/quartus/sopc_builder/bin/system-console.exe"
tcl_script = "read_sdram.tcl"

print("Launching System Console to read SDRAM over JTAG...")

# Run System Console silently with the Tcl script
process = subprocess.Popen(
    [system_console_path, "--cli", f"--script={tcl_script}"],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True
)

# Capture stdout line by line
counter = 0
raw_bytes = []
for line in process.stdout:
    clean_line = line.strip()
    if clean_line.isdigit():
        raw_bytes.append(int(clean_line))
        counter += 1
        if (counter % 1000) == 0:
            print(f"Reading line {counter}")
    elif "SUCCESS" in clean_line:
        print("Data successfully retrieved from FPGA.")

process.wait()

# Dump all raw integers straight into a NumPy uint8 byte array
bytes_np = np.array(raw_bytes, dtype=np.uint8)

# Cast pairs of 8-bit bytes directly into 16-bit integers (Little-Endian)
samples_array = bytes_np.view(dtype=np.uint16)

# Apply a vectorised bitmask to isolate your 14-bit data
# This instantly strips the 2 padded bits from every single element simultaneously
samples_array = samples_array & 0x3FFF

print(f"NumPy processing complete! Processed {len(samples_array)} ADC samples.")

# Save the np array
np.save("adc_capture.npy", samples_array)
print("Saved binary capture to 'adc_capture.npy'")