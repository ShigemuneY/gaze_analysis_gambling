# gaze_analysis_gambling
MATLAB scripts for analyzing eye-tracking data in gambling tasks - Merges behavioral data, calculates gaze allocation, and analyzes peak gaze positions

## Overview

This script collection performs four main analyses:

1. Merges eye-tracking and behavioral data
2. Calculates gaze allocation ratios for each pixel on the screen  
3. Detects peak gaze positions for left and right sides
4. Calculates gaze allocation time within customizable concentric zones around peak positions

## Requirements

### Required External Functions
These scripts require two external functions from MATLAB File Exchange:

* readfromexcel:
  - Author: Brett Shoelson, Ph.D.
  - Source: MATLAB Central File Exchange
  - File ID: 4415
  - Citation: Brett Shoelson (2024). readfromexcel (https://www.mathworks.com/matlabcentral/fileexchange/4415-readfromexcel), MATLAB Central File Exchange. Retrieved December 26, 2024.

* xlswrite:
  - Author: Andreas Sprenger (based on Scott Hirsch's original work)
  - Source: MATLAB Central File Exchange
  - File ID: 7881
  - Citation: Andreas Sprenger (2024). xlswrite (https://www.mathworks.com/matlabcentral/fileexchange/7881-xlswrite), MATLAB Central File Exchange. Retrieved December 26, 2024.


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

[Under Review]
