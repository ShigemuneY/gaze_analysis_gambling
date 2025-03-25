function analyze_concentric_zones_v1

% analyze_concentric_zones.m
%
% Calculates gaze allocation time within concentric zones around peak positions.
% The analysis divides the area around each peak into multiple concentric zones
% defined by a base radius. For example, with radius=25px and 4 zones:
% Zone 1: 0-25px, Zone 2: 25-50px, Zone 3: 50-75px, Zone 4: 75-100px
%
% Author: Y. Shigemune
% Released: 12/26/2024
% Last Modified:  3/25/2025
%
% Parameters:
%   - r: Base radius in pixels for zone calculation (default: 25px)
%   - Repeat: Number of concentric zones to analyze (default: 4)
%   - peakDetectionType: Peak detection method (0:global, 1:bilateral)
%
% Input files:
%   - Merged data files created by merge_gaze_behavioral.m in Input directory
%   - detected_peaks.xlsx created by detect_gaze_peaks.m in working directory
%
% Output file:
%   - concentric_zone_[r]px.xlsx in Output directory
%   - Contains percentage of gaze time in each concentric zone
%
% Required external functions:
%   - readfromexcel (File ID: 4415-readfromexcel)
%   - xlswrite (File ID: 7881-xlswrite)

disp('Starting..');
disp(' ');

SUBJ = struct();

curDir = pwd;
CurFromPath =  strcat(curDir, filesep, 'Input'); % Folder containing files created with Script01
CurToPath =  strcat(curDir, filesep, 'Output');
SUBJ.dataSet = dir(fullfile(CurFromPath,'*.xlsx'));

% set concentric zones
r = 25; % radius
Repeat = 4; % number of zones

% set ditection type
peakDetectionType = 1; % global:0, bilateral:1
    
if size(SUBJ.dataSet,1) > 0
    
    if peakDetectionType == 0
        peak01 = '1st';
        peak02 = '2nd';
    elseif peakDetectionType == 1
        peak01 = 'L';
        peak02 = 'R';
    end
        
    DataSet = cell(size(SUBJ.dataSet,1), 1+Repeat*2);
    DataSet(:,:) = [{0}];
    
    OutputHeader = cell(1, 1+Repeat*2);
    OutputHeader(1,1) = [{'Subject'}];
    for iCurZone = 1 : Repeat
        OutputHeader(1,1+iCurZone) = [{sprintf('%s_%02d', peak01, iCurZone)}];
    end
    for iCurZone = 1 : Repeat
        OutputHeader(1,1+Repeat+iCurZone) = [{sprintf('%s_%02d', peak02, iCurZone)}];
    end
    
    Peaks = readfromexcel(fullfile( curDir,'detected_peaks.xlsx'),'sheet','Sheet1','All'); % file of peak coordinates of all subjects created with Script03
    Peaks =  Peaks(2:end,:);
        
    for iCurFile = 1 : size(SUBJ.dataSet,1)
        
        SubDataSet = readfromexcel(fullfile(CurFromPath, SUBJ.dataSet(iCurFile).name),'sheet','Sheet1','All');
        SubDataSet = SubDataSet(2:end,:);
        
        [x,FileName,y] = fileparts(SUBJ.dataSet(iCurFile).name);
        DataSet(iCurFile,1) =[{FileName}];
        
        % Left/1st peak
        subPeak01X = Peaks{iCurFile,2};
        subPeak01Y = Peaks{iCurFile,3};
        
        % Right/2nd peak
        subPeak02X = Peaks{iCurFile,4};
        subPeak02Y = Peaks{iCurFile,5};
        
        % for left/1st peak
        Total_Duration = 0;
        
        % create buffers for each zone
        for iCurZone = 1 : Repeat
            eval([sprintf('Circle_Duration_%02d = 0;',iCurZone)]);
        end
        
        % add duration for each pixel to the appropriate buffer
        for iCurLine = 1 : size(SubDataSet,1)
            if isnan(SubDataSet{iCurLine,2}) == 0
                if SubDataSet{iCurLine,33} == 1 % column 33: phase
                    for iCurZone = 1 : Repeat
                        if eval([sprintf('(SubDataSet{iCurLine,73}-subPeak01X)^2 + (SubDataSet{iCurLine,74}-subPeak01Y)^2 <= (r*%d)^2 && (SubDataSet{iCurLine,73}-subPeak01X)^2 + (SubDataSet{iCurLine,74}-subPeak01Y)^2 > (r*(%d-1))^2',iCurZone,iCurZone)])
                            eval([sprintf('Circle_Duration_%02d = Circle_Duration_%02d + SubDataSet{iCurLine,130};',iCurZone,iCurZone)]);
                        end
                    end
                    Total_Duration = Total_Duration + SubDataSet{iCurLine,130}; % column 130: duration
                end
            end
        end
        
        % calculate percentage
        for iCurZone = 1 : Repeat
            eval([sprintf('DataSet{iCurFile,1+%d} =  Circle_Duration_%02d/Total_Duration*100;',iCurZone,iCurZone)]);
        end
        
        % for right/2nd peak
        Total_Duration = 0;
        
        % create buffers for each zone
        for iCurZone = 1 : Repeat
            eval([sprintf('Circle_Duration_%02d = 0;',iCurZone)]);
        end
        
        % add duration for each pixel to the appropriate buffer
        for iCurLine = 1 : size(SubDataSet,1)
            if isnan(SubDataSet{iCurLine,2}) == 0
                if SubDataSet{iCurLine,33} == 1 % column 33: phase
                    for iCurZone = 1 : Repeat
                        if eval([sprintf('(SubDataSet{iCurLine,73}-subPeak02X)^2 + (SubDataSet{iCurLine,74}-subPeak02Y)^2 <= (r*%d)^2 && (SubDataSet{iCurLine,73}-subPeak02X)^2 + (SubDataSet{iCurLine,74}-subPeak02Y)^2 > (r*(%d-1))^2',iCurZone,iCurZone)])
                            eval([sprintf('Circle_Duration_%02d = Circle_Duration_%02d + SubDataSet{iCurLine,130};',iCurZone,iCurZone)]);
                        end
                    end
                    Total_Duration = Total_Duration + SubDataSet{iCurLine,130}; % column 130: duration
                end
            end
        end
        
        % calculate percentage
        for iCurZone = 1 : Repeat
            eval([sprintf('DataSet{iCurFile,1+Repeat+%d} =  Circle_Duration_%02d/Total_Duration*100;',iCurZone,iCurZone)]);
        end
        
    end
    
    FileName = sprintf('concentric_zone_%dpx.xlsx', r);
    
    cd (CurToPath);
    xlswrite (DataSet,'',OutputHeader, FileName);
    cd (curDir);
    
end

end
