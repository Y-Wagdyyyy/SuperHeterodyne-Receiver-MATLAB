# 📡 Super-Heterodyne Receiver Simulation in MATLAB

This repository contains a MATLAB implementation of a **Super-Heterodyne Receiver** simulation for multiple AM-SC (Amplitude Modulation – Suppressed Carrier) audio signals.  
It demonstrates the complete RF signal processing chain — from baseband audio to RF transmission, intermediate frequency (IF) conversion, and final demodulation back to baseband.

---

## ✨ Features
- 🎵 Reads and processes multiple `.wav` audio signals.
- 🎚 Converts stereo audio to mono for signal processing.
- 📶 Implements **AM-SC modulation** for each signal with configurable carrier frequencies.
- 📡 Combines multiple modulated signals into a single RF channel.
- 🎯 Band-pass filtering for channel selection at **RF** and **IF** stages.
- 🔄 Down-conversion to IF and then to baseband.
- 📊 Visualization of:
  - Time-domain signals
  - Frequency spectra
  - Intermediate stages
- 🔊 Plays the recovered audio of the selected channel after demodulation.

---

## 🛠 Stages Implemented
1. **Baseband Audio Processing** – Read audio, mono conversion, and zero-padding.
2. **AM-SC Modulation** – Carrier generation and signal modulation.
3. **RF Stage** – Combine signals and visualize spectrum.
4. **Bandpass Filtering** – Select one channel from the combined RF.
5. **IF Stage** – Down-convert to Intermediate Frequency.
6. **Baseband Stage** – Final down-conversion and low-pass filtering.
7. **Audio Output** – Resample and playback recovered audio.

---

## 📂 Project Structure
├── Audio signals/
│ ├── Short_BBCArabic2.wav
│ ├── Short_FM9090.wav
│ ├── Short_QuranPalestine.wav
│ ├── Short_RussianVoice.wav
│ └── Short_SkyNewsArabia.wav
├── Super_heterodyne_Receiver.m
└── README.md

---

## 🚀 Usage
1. **Clone this repo**:
   ```bash
   git clone https://github.com/Y-Wagdyyyy/SuperHeterodyne-Receiver-MATLAB.git
2. Open MATLAB and set the working directory to the repository folder.

3. Run the script:
Super_heterodyne_Receiver

4. Select a channel (1–5) when prompted.

---

📋 Requirements

- MATLAB R2018a or newer.
- DSP System Toolbox.
- Audio files included in Audio signals folder.

---

🎯 Applications

- Educational demonstration of the super-heterodyne architecture.
- DSP and RF communication systems learning.
- MATLAB-based radio receiver simulation.

---

👤 Author

Youssef Wagdy
📧 youssefwagdy68@gmail.com

📜 Licensed under the MIT License – see LICENSE for details.
