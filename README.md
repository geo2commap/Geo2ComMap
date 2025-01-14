# Geo2ComMap: MIMO Throughput Prediction Based on Deep Learning and Geographic Databases

Geo2ComMap is a comprehensive framework designed for MIMO throughput prediction using deep learning and geographic databases.

## Table of Contents
1. [Overview](#overview)
2. [Ray Tracing-Based MIMO Throughput Simulation](#ray-tracing-based-mimo-throughput-simulation)
    - [Building Map Preparation](#building-map-preparation)
    - [Propagation Path Simulation](#propagation-path-simulation)
    - [MIMO Throughput Simulation](#mimo-throughput-simulation)
3. [Geo2ComMap Dataset](#geo2commap-dataset)

---

## Overview
Geo2ComMap leverages geographic data and a U-Net-based model to predict MIMO throughput with high efficiency and precision. The framework consists of three main components:

1. **Ray Tracing-Based Dataset Generation**: A simulation pipeline to compute MIMO throughput, generating high-quality datasets for training.
2. **U-Net Model Training**: A deep learning model trained using the generated dataset to predict full throughput maps for target areas.
3. **Special Sampling Strategy**: A novel approach to handle high-error outliers, significantly improving prediction accuracy by reducing extreme errors and RMSE compared to traditional random sampling.

Through experiments, Geo2ComMap evaluates the necessary input data for the U-Net model and explores performance across varying sparse point sampling strategies.

---

## Ray Tracing-Based MIMO Throughput Simulation

### Building Map Preparation
- Download building maps using [Blender Blosm](https://github.com/vvoovv/blosm) from [OpenStreetMap](https://www.openstreetmap.org/).
- Convert building maps into `.xml` format using [Blender Mitsuba](https://github.com/mitsuba-renderer/mitsuba-blender).

### Propagation Path Simulation
- Utilize [Sionna](https://nvlabs.github.io/sionna/) for ray tracing-based simulation. For a detailed example, see the [Sionna RT Video](https://www.youtube.com/watch?v=7xHLDxUaQ7c&t=1s) by NVIDIA developers.

### MIMO Throughput Simulation
- Perform MIMO throughput modeling using MATLAB, considering a 4-transmit antenna and 4-receive antenna OFDM MIMO system.
- Simulate channels on a per-subcarrier basis for realistic throughput estimation.

---

## Geo2ComMap Dataset
The dataset generated through the ray tracing-based MIMO throughput simulation is openly available for use and research:
- **Dataset Access**: [Download from Google Drive](https://drive.google.com/file/d/1Atfnq0iCt7LdDpGswa6yC3ecJqt7wbsr/view?usp=sharing).

This dataset is tailored for U-Net training and forms the foundation for the predictive capabilities of Geo2ComMap.

