function detect_gaze_peaks_v1

% detect_gaze_peaks.m
%
% Detects peak gaze positions either globally (top 2 peaks) or bilaterally (peaks in left/right hemifields)
%
% Author: Y. Shigemune
% Released: 12/23/2024
% Last Modified:  12/26/2024
%
% Parameters:
%   peakDetectionType - Detection method (0:global, 1:bilateral)
%   Resolution_W - Screen width in pixels for hemifield separation (default: 1024)
%
% Input files:
%   - Gaze ratio files created by calculate_gaze_ratios.m in Input directory
%
% Output file:
%   - detected_peaks.xlsx in Output directory
%   - Contains coordinates (X,Y) of peaks based on detection type:
%     Global: First and second highest peaks
%     Bilateral: Highest peaks in left and right hemifields
%
% Output file:
%   - detected_peaks.xlsx in Output directory
%   - Contains coordinates (X,Y) of peak gaze positions for each hemifield
%
% Required external functions:
%   - readfromexcel (File ID: 4415-readfromexcel)
%   - xlswrite (File ID: 7881-xlswrite)

disp('Starting..');
disp(' ');

SUBJ = struct();

curDir = pwd;
CurFromPath =  strcat(curDir, filesep, 'Input'); % Folder containing the data files for the percentages in a phase created with Script02
CurToPath =  strcat(curDir, filesep, 'Output');
SUBJ.dataSet = dir(fullfile(CurFromPath,'*.xlsx'));

% set resolution
Resolution_W = 1024; % Width

% set ditection type
peakDetectionType = 1; % global:0, bilateral:1

if size(SUBJ.dataSet,1) > 0
    
    if peakDetectionType == 0
        OutPutHeader=[{'File'} {'1stX'} {'1stY'} {'2ndX'} {'2ndY'}];
    elseif peakDetectionType == 1
        OutPutHeader=[{'File'} {'LX'} {'LY'} {'RX'} {'RY'}];
    end
    
    DataSet=cell(size(SUBJ.dataSet,1),5);
    DataSet(:,:)=[{''}];
    
    for iCurFile = 1:size(SUBJ.dataSet,1)
        
        SubDataSet = readfromexcel(fullfile(CurFromPath, SUBJ.dataSet(iCurFile).name),'sheet','Sheet1','All');
        SubDataSet =  SubDataSet(2:end,:);
        
        % Find Peak
        SubDataSet = sortrows(SubDataSet,3,'descend'); % colum 3: percentage
        
        if peakDetectionType == 0
            
            DataSet(iCurFile,2:3)  = SubDataSet(1,1:2); % 1st peak
            DataSet(iCurFile,4:5)  = SubDataSet(2,1:2); % 2nd peak
            
        elseif peakDetectionType == 1
            
            onPeakL = 0;
            onPeakR = 0;
            for iCurLine = 1 : size(SubDataSet,1)
                % Left
                if SubDataSet{iCurLine,1} < Resolution_W/2
                    if onPeakL == 0
                        DataSet(iCurFile,2:3)  = SubDataSet(iCurLine,1:2);
                    end
                    onPeakL = onPeakL + 1;
                % Right
                elseif SubDataSet{iCurLine,1} >= Resolution_W/2
                    if onPeakR == 0
                        DataSet(iCurFile,4:5) = SubDataSet(iCurLine,1:2);
                    end
                    onPeakR = onPeakR + 1;
                end
                if onPeakR == 1 && onPeakL == 1
                    break
                end
            end
            
        end
        
        [x,FileName,y] = fileparts(SUBJ.dataSet(iCurFile).name);
        DataSet(iCurFile,1) =[{FileName}];
        
    end
    
    cd (CurToPath);
    xlswrite (DataSet,'',OutPutHeader, 'detected_peaks.xlsx');
    cd (curDir);
    
end

end
