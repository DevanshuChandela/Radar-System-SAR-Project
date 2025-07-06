## Synthetic Aperture Radar Simulation in MATLAB

## 📡 Overview
This project implements a Synthetic Aperture Radar (SAR) simulation using MATLAB, analyzing radar returns from both point targets and real-world terrains via DEM (Digital Elevation Model) data. The simulation explores the impact of various radar and environmental parameters — such as velocity, elevation, weather, and power — on SAR image quality and resolution.

## 👨‍💻 Team Members
Abhinav Kumar Saxena (2022018)

Devanshu Chandela (2022153)

Naman Garg (2022602)

## ⚙️ Features
Stripmap SAR Simulation using a point target

DEM Integration: Generates SAR images from actual elevation data (.tif)

Weather Effects: Analyzes SAR image changes under Rain, Fog, and Snow

## Multi-Parameter Experiments: Simulations with different combinations of:

Altitude

Antenna gain 

Velocity 

PRI (Pulse Repetition Interval) 

Power 

Wavelength 

Elevation angles 


## 🧪 Technical Parameters
Carrier Frequency (fc): 10 GHz

Wavelength (λ): 0.03 m

Bandwidth (B): 20 MHz

Pulse Width: 10 µs

Chirp Rate (K): 2 × 10¹² Hz/s

Platform Velocity (vp): 150 m/s

Altitude: 5 km

Transmit Power (P_tx): 1 W

Antenna Gain (G): 0 dB

Pulses: 4096

Target Slant Range: 8600 m (7000 m ground + 5 km altitude)


## 🌍 DEM Terrain Imaging
DEM Source: NASA

File: olympex_ASO_USWA_OL_20140904_f1a1_mcc_bareDEM_3p0m_despiked.tif

Elevation Range:

High: Red/Yellow (> 1200 m)

Low: Blue (0–500 m)


## Observations
Effective topography-based imaging.

Strip map images reflect terrain features clearly.

Elevation artifacts were corrected using mean fill-in and NaN handling.


## 🌦 Weather Simulation Observations

| Condition | Visibility | Image Quality                      |
| --------- | ---------- | ---------------------------------- |
| **Fog**   | Good       | Mild signal loss                   |
| **Snow**  | Moderate   | Slight edge fading                 |
| **Rain**  | Poor       | Strong attenuation, dimmer returns |


## 🔬 Parameter Variation Results
The project explored >20 configurations; 5 notable ones were included in the report. Key takeaways:

Higher Power + Velocity → Sharper, high-SNR images

Low Velocity → Blurred azimuth resolution

High Altitude → Broader coverage but weaker returns

Short PRI → Better high-speed resolution but more ambiguity

Each parameter affects SAR trade-offs across resolution, coverage, and imaging performance.


## 🛠 Tech Stack

Language: MATLAB

Libraries/Toolboxes: Signal Processing, Image Processing

External Data: NASA DEM (.tif files)

