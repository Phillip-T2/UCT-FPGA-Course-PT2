import matplotlib.pyplot as plt
import numpy as np
from pydub import AudioSegment
from scipy.signal import stft

fmax_index = 200

# 1. Load and trim audio
file_path = "Recording (2).m4a"
audio = AudioSegment.from_file(file_path, format="m4a")
audio_trimmed = audio[1000:]  # Remove first second

sr = audio_trimmed.frame_rate
channels = audio_trimmed.channels
samples = np.array(audio_trimmed.get_array_of_samples(), dtype=np.float32)

if channels == 2:
    samples = samples.reshape((-1, channels)).mean(axis=1)

max_possible_val = (
    np.iinfo(np.int16).max if audio_trimmed.sample_width == 2 else np.iinfo(np.int32).max
)
samples /= max_possible_val

# 2. Compute STFT
frequencies, times, Zxx = stft(samples, fs=sr, nperseg=2048)
amplitude_db = 20 * np.log10(np.abs(Zxx) + 1e-10)


# === FIGURE 1: Full Spectrogram Window ===
""" plt.figure(1, figsize=(10, 6))  # Explicitly names this Window 1
plt.pcolormesh(times, frequencies[0:fmax_index], amplitude_db[0:fmax_index,:], cmap="inferno", shading="gouraud")
plt.title("Spectrogram", fontsize=14)
plt.xlabel("Time (seconds)", fontsize=12)
plt.ylabel("Frequency (Hz)", fontsize=12)
# plt.ylim(0, sr / 2)

cbar = plt.colorbar()
cbar.set_label("Intensity (dB)", fontsize=12)
 """
# Optional visual line tracking where the 1.5s slice is located
target_time = 1.5
# plt.axvline(x=target_time, color="white", linestyle="--", alpha=0.7)
# plt.tight_layout()


# === FIGURE 2: 1.5-Second Frequency Spectrum Window ===
plt.figure(2, figsize=(10, 5))  # Explicitly names this Window 2
# Dynamically locate the time column closest to 1.5s
time_index = np.argmin(np.abs(times - target_time))

# Plot using the proper [:, time_index] indexing
plt.plot(frequencies[0:fmax_index], amplitude_db[0:fmax_index, time_index], color="crimson")
# plt.title(f"Frequency Spectrum", fontsize=14)
plt.xlabel("Frequency (Hz)", fontsize=12)
plt.ylabel("Intensity (dB)", fontsize=12)
plt.xlim(0, 3000)
plt.xticks(np.arange(0,3250,250))
plt.grid(True)
plt.tight_layout()


# === DISPLAY BOTH WINDOWS ===
# This single call launches both distinct popup windows simultaneously
plt.show()
