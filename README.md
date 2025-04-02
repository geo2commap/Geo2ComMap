# Geo2ComMap: Deep Learning-Based MIMO Throughput Prediction Using Geographic Data

## Introduction
This repository contains the official implementation of the paper:  
**Fan-Hao Lin, Tzu-Hao Huang, Chao-Kai Wen, Trung Q. Duong**,  
*"Geo2ComMap: Deep Learning-Based MIMO Throughput Prediction Using Geographic Data,"*  
**arXiv preprint arXiv:2504.00351**, April 2025.  
[View on arXiv](https://arxiv.org/abs/2504.00351) 

---

## Table of Contents
1. [Overview](#overview)
2. [Requirements](#Requirements)
3. [Ray Tracing-Based MIMO Throughput Simulation](#ray-tracing-based-mimo-throughput-simulation)
    - [Building Map Preparation](#building-map-preparation)
    - [Propagation Path Simulation](#propagation-path-simulation)
    - [MIMO Throughput Simulation](#mimo-throughput-simulation)
4. [Geo2ComMap Dataset](#geo2commap-dataset)

---

## Overview
Geo2ComMap leverages geographic data and a U-Net-based model to predict MIMO throughput with high efficiency and precision. The framework consists of three main components:

1. **Ray Tracing-Based Dataset Generation**: A simulation pipeline to compute MIMO throughput, generating high-quality datasets for training.
2. **U-Net Model Training**: A deep learning model trained using the generated dataset to predict full throughput maps for target areas.
3. **Special Sampling Strategy**: A novel approach to handle high-error regions, significantly improving prediction accuracy by reducing extreme errors and RMSE compared to traditional random sampling.

Through experiments, Geo2ComMap evaluates the necessary input data for the U-Net model and explores performance across varying sparse point sampling strategies.

---
## Requirements
- python==3.8.20
- opencv-python==4.10.0.84
- sionna==0.18.0
- torch==2.4.1
- numpy==1.24.3

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
- **Dataset Access**: [Download from Dropbox](https://www.dropbox.com/scl/fo/puy6ggsto5kp7nwdcxndd/AA8EkX4v2Nf449AUBvFts4I?rlkey=y4h5cdox21m25duqlgeknu1qe&st=t1dsqecn&dl=0).

This dataset is tailored for U-Net training and forms the foundation for the predictive capabilities of Geo2ComMap.


