# GazeAnalysisGambling

A collection of MATLAB scripts for analyzing eye-tracking data in a gambling task.

## Overview

This script collection performs four main analyses:

1. Merges eye-tracking and behavioral data
2. Calculates gaze allocation ratios for each pixel on the screen  
3. Detects peak gaze positions for left and right sides
4. Calculates gaze allocation time within customizable concentric zones around peak positions

## Directory Structure

Each script is contained in its own directory with corresponding input/output folders:

    project_directory/
    ├── 01_merge_gaze_behavioral/
    │   ├── Input_Behavior/    # For behavioral data (.xlsx)
    │   ├── Input_EyeTracking/ # For eye-tracking data (.xlsx)
    │   ├── Output/            # For merged results
    │   └── merge_gaze_behavioral_v1.m
    │
    ├── 02_calculate_gaze_ratios/
    │   ├── Input/             # Place output from 01_merge_gaze_behavioral here
    │   ├── Output/            # For gaze ratio results
    │   └── calculate_gaze_ratios_v1.m
    │
    ├── 03_detect_gaze_peaks/
    │   ├── Input/             # Place output from 02_calculate_gaze_ratios here
    │   ├── Output/            # For peak detection results
    │   └── detect_gaze_peaks_v1.m
    │
    └── 04_analyze_concentric_zones/
        ├── Input/             # Place output from 01_merge_gaze_behavioral here
        ├── Output/            # For concentric zone analysis results
        └── analyze_concentric_zones_v1.m

Note: The `.gitkeep` files in empty directories are used to maintain the directory structure in GitHub. These files can be safely kept or deleted after downloading the repository - they do not affect the scripts' functionality.

## Requirements

### Required External Functions
These scripts require two external functions from MATLAB File Exchange:

* readfromexcel:
  - Author: Brett Shoelson, Ph.D.
  - Source: MATLAB Central File Exchange
  - File ID: 4415

* xlswrite:
  - Author: Andreas Sprenger (based on Scott Hirsch's original work)
  - Source: MATLAB Central File Exchange
  - File ID: 7881


## Usage

1. `merge_gaze_behavioral.m`
   - Place behavioral data (.xls) in Input_Behavior directory
   - Place eye-tracking data (.xlsx) in Input_EyeTracking directory
   - Running this script outputs merged data to the Output directory

2. `calculate_gaze_ratios.m`
   - Place files created by Script 1 in the Input directory
   - Running this script calculates gaze allocation ratios for each pixel and outputs results to the Output directory

3. `detect_gaze_peaks.m`
   - Place files created by Script 2 in the Input directory
   - Running this script detects peak gaze positions 
   - Detection mode can be set to global (entire screen) or bilateral (left/right)
   - Outputs "detected_peaks.xlsx" to the Output directory

4. `analyze_concentric_zones.m`
   - Place files created by Script 1 in the Input directory  
   - Place `detected_peaks.xlsx` (output from Script 3) in the working directory
   - Running this script calculates gaze allocation time within concentric zones
   - Three customizable parameters:
     - 'r': Base radius in pixels (default = 25px)
     - 'Repeat': Number of zones (default = 4)
     - 'peakDetectionType': Detection method (0:global, 1:bilateral)
   - Output columns format depends on peakDetectionType:
     - Global: 1st_01 to 1st_[n], 2nd_01 to 2nd_[n]
     - Bilateral: L_01 to L_[n], R_01 to R_[n]

## Input File Specifications

- Behavioral data: Excel format (.xlsx)
- Eye-tracking data: Excel format (.xlsx)
  - The scripts were originally developed using data from Tobii Pro Nano eye tracker and Tobii Pro Lab software, but should be compatible with data from other eye trackers as long as they can export:
    - X and Y gaze coordinates
    - Timestamps
    - Validity/quality metrics
  - Required data format can be adjusted in merge_gaze_behavioral.m to match your eye tracker's output format
  - Compatible with various sampling rates and screen resolutions
    - Original development used 60Hz sampling rate and 1024×768 pixels resolution
    - Different settings can be accommodated by adjusting parameters in the scripts

## Output Files

All script outputs are saved in Excel format (.xlsx).

## Important Notes

- Ensure all required directories are created before running scripts
- Verify that readfromexcel and xlswrite functions are added to your MATLAB path
- The scripts use Excel file operations, which may be time-consuming for large datasets
- Data validation is performed but should be verified for your specific use case

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Citation

If you use these scripts in your research, please cite the following paper:

Paper:
Shigemune, Y., Midorikawa, A. Focal attention peaks and laterality bias in problem gamblers: an eye-tracking investigation. Cogn Neurodyn 19, 51 (2025). https://doi.org/10.1007/s11571-025-10238-w

Software:
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14556986.svg)](https://doi.org/10.5281/zenodo.14556986)
