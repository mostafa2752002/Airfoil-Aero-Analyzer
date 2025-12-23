# Airfoil Aerodynamic Analysis & Boundary Correction Tool

This repository contains a robust MATLAB script designed to process experimental wind tunnel data for an airfoil. The tool automates data ingestion, performs vectorized aerodynamic calculations, applies necessary wind tunnel wall corrections, and generates high-quality plots for analysis.

## 🚀 Features

* **Automated Data Import:** Utilizes `readmatrix` to dynamically pull pressure tap locations and experimental readings from Excel/CSV files, eliminating manual data entry.
* **Vectorized Processing:** Replaces heavy nested loops with matrix operations for high-performance calculations of $C_p$, $C_l$, $C_d$, and $C_m$.
* **Boundary Interference Corrections:** Implementation of correction factors for **solid blockage**, **wake blockage**, and **streamline curvature** ($\sigma$ and $\epsilon$ corrections).
* **Comparative Analysis:** Automatically compares experimental results against:
    * **XFOIL** data (user-provided).
    * **Thin Airfoil Theory** ($C_l = 2\pi\alpha$).
    * **Corrected vs. Uncorrected** experimental data.
* **Comprehensive Visualization:** Generates subplots for $C_p$ distributions, wake profiles, and integrated performance curves ($L/D$).

## 📁 File Structure

* `AirfoilAnalysis.m`: The main MATLAB script.
* `cleanDataGroup30.xlsx`: Sample data file containing pressure readings, freestream conditions, and tap locations.

## 🛠 Installation & Usage

1.  **Clone** this repository to your local machine.
2.  **Format your data** in an Excel file (refer to `cleanDataGroup30.xlsx` for the required schema).
3.  **Place the data file** in the same directory as the script.
4.  **Run** `AirfoilAnalysis.m` in MATLAB.

## 📊 Calculations Covered

The script processes data using the following aerodynamic principles:

1.  **Pressure Coefficient ($C_p$):** $$C_p = \frac{p - p_{\infty}}{q_{\infty}}$$
2.  **Lift Coefficient ($C_l$):** Derived via numerical integration of the pressure distribution over the upper and lower surfaces.
3.  **Drag Coefficient ($C_d$):** Calculated using the **Wake Survey Method** (Momentum Integral) based on total pressure deficit in the wake.
4.  **Pitching Moment ($C_m$):** Calculated about the quarter-chord ($0.25c$).
5.  **Glide Ratio ($L/D$):** Calculation of aerodynamic efficiency for performance analysis.



## ⚖️ Wind Tunnel Corrections

To account for the confined flow of the wind tunnel environment, the following corrections are applied to the raw data:

* **Solid Blockage:** Accounts for the reduction in flow area due to the physical model.
* **Wake Blockage:** Accounts for the reduced velocity in the wake causing a pressure gradient.
* **Streamline Curvature:** Adjusts the lift and moment coefficients due to the tunnel walls preventing the normal curvature of streamlines.
