import numpy as np
from matplotlib import pyplot as plt

# Configuration
NUM_SAMPLES = 1024
BIT_WIDTH = 16
MAX_VAL = (2**BIT_WIDTH) - 1  # 65535 for 16-bit
OUTPUT_FILE = "sine_table.mem"

# 1. Generate 1024 points of a sine wave from 0 to 2*pi
x = np.linspace(0, 2 * np.pi, NUM_SAMPLES, endpoint=False)
y = np.sin(x)

# 2. Scale and shift to 16-bit Unsigned range (0 to 65535)
# Moving the sine wave up so its center is at 32767.5 instead of 0
y_unsigned = (y + 1.0) * (MAX_VAL / 2.0)

# Round to the nearest integer and cast to an unsigned 16-bit int type
y_int = np.round(y_unsigned).astype(np.uint16)

# 3. Write to the .mem file in hex format
with open(OUTPUT_FILE, "w") as f:
    for value in y_int:
        # Format as a 4-digit hex string padded with zeros (e.g., 00af, 7fff)
        f.write(f"{value:04X}\n")

print(f"Success! '{OUTPUT_FILE}' has been generated with {NUM_SAMPLES} entries.")

plt.plot(x,y_unsigned)
plt.show()

