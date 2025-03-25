function merge_gaze_behavioral_v1 

% merge_gaze_behavioral.m
% 
% Merges eye-tracking data and behavioral data from a gambling task.
%
% Author: Y. Shigemune
% Released: 12/26/2024
% Last Modified:  3/25/2025
%
% Input files:
%   - Behavioral data (.xls) in Input_Behavior directory
%   - Eye-tracking data (.xlsx) in Input_EyeTracking directory 
%
% Output file:
%   - [filename]_merge.xlsx in Output directory
%   - Contains behavioral data, phase information, and eye-tracking data
%
% Required external functions:
%   - readfromexcel (File ID: 4415-readfromexcel)
%   - xlswrite (File ID: 7881-xlswrite)

disp('Starting..');
disp(' ');

SUBJ = struct();
EXPER = struct();

curDir = pwd;
CurFromPath01 =  strcat(curDir, filesep, 'Input_Behavior'); % Folder containing behavioral data files
CurFromPath02 =  strcat(curDir, filesep, 'Input_EyeTracking'); % Folder containing eye-tracking data files for each run
CurToPath =  strcat(curDir, filesep, 'Output');
SUBJ.dataSet01 = dir(fullfile(CurFromPath01,'*.xlsx')); % Behavior data
SUBJ.dataSet02 = dir(fullfile(CurFromPath02,'*.xlsx')); % Eye-Tracking data

EXPER.numRuns = 2;  % number of runs
EXPER.numTrials(1:EXPER.numRuns) = 60;  % number of trials
EXPER.trialFed = 1500; % duration of feedback
EXPER.trialFix = 1000; % duration of fixation

if size(SUBJ.dataSet01,1) > 0
        
    for iCurFile = 1 : size(SUBJ.dataSet01,1)
        
        SubDataSet01 = readfromexcel(fullfile(CurFromPath01, SUBJ.dataSet01(iCurFile).name),'A1:AF181'); % Behavior data
        OutPutHeader01 = SubDataSet01(1,:);
        SubDataSet01 =  SubDataSet01(2:end,:);
        
        for absRun = 1 : EXPER.numRuns
                                    
            SubDataSet02 = readfromexcel(fullfile(CurFromPath02, SUBJ.dataSet02((iCurFile-1)*EXPER.numRuns+absRun).name),'ALL'); % Eye-Tracking data
            OutPutHeader02 = [SubDataSet02(1,:) {'Duration'}];
            SubDataSet02 = [SubDataSet02(2:end,:) cell(size(SubDataSet02,1)-1, 1)];
            
            % Count number of events & exclide them
            empty_counter = 0;
            for p = 1 : size(SubDataSet02,1)                
                if  isempty(SubDataSet02{p,38}) == 0 % column 38: event
                    empty_counter = empty_counter + 1;
                end
            end
            
            SubDataSet03=cell(size(SubDataSet02,1)-empty_counter, size(SubDataSet02,2)); 
            SubDataSet03(:,:)=[{''}];            
            
            empty_counter = 0;
            for i = 1 : size(SubDataSet02,1)
                if i == 1
                    SubDataSet03(1,1:size(SubDataSet02,2)) = SubDataSet02(1,:);
                else
                    if  isempty(SubDataSet02{i,38}) == 1
                        SubDataSet03(i-empty_counter,1:size(SubDataSet02,2)) = SubDataSet02(i,:);
                    else 
                        empty_counter = empty_counter + 1;
                    end
                end
            end
            
            %@Calcurate duration
            for r = 1 : size(SubDataSet03,1)                   
                if r ~= size(SubDataSet03,1)
                    SubDataSet03(r,end) = [{(SubDataSet03{r+1,37} -  SubDataSet03{r,37})/1000}]; % column 37: timestamp
                end
            end
            
            %@Identify phase 
            data_counter_t0 = 0;
            data_counter_t1 = 0;
            for k = 1 : EXPER.numTrials(absRun)
                
                end_dec = SubDataSet01{sum(EXPER.numTrials(1:(absRun-1)))+k,21}; % end of decision = onset of feedback (column 21)
                end_fed = SubDataSet01{sum(EXPER.numTrials(1:(absRun-1)))+k,21} + EXPER.trialFed; % end of feedback = onset of feedback + duration of feedback                 
                if k ~=  EXPER.numTrials(absRun)
                    end_fix = SubDataSet01{sum(EXPER.numTrials(1:(absRun-1)))+k+1,20}; % end of fixation = onset of next trial (column 20)
                else 
                    end_fix = SubDataSet01{sum(EXPER.numTrials(1:(absRun-1)))+k,21} + EXPER.trialFed + EXPER.trialFix; % onset of feedback + duration of feedback & fixation
                end
                
                data_counter_t0 = data_counter_t0 + data_counter_t1;
                data_counter_t1 = 0;                
                for q = data_counter_t0+1:size(SubDataSet03,1)
                    if (SubDataSet03{q,37} - SubDataSet03{1,37})/1000 >= end_fix % column 37: timestamp
                        break
                    end
                    data_counter_t1 = data_counter_t1 + 1;
                end
                
                SubDataSet04=cell(data_counter_t1, size(SubDataSet01,2)+1+size(SubDataSet03,2));
                SubDataSet04(:,:)=[{''}];
                
                for l = 1 :  size(SubDataSet04,1)
                    SubDataSet04(l,1:size(SubDataSet01,2)) = SubDataSet01(sum(EXPER.numTrials(1:(absRun-1)))+k,:);
                    SubDataSet04(l,size(SubDataSet01,2)+2:size(SubDataSet04,2)) = SubDataSet03(data_counter_t0+l,:);
                    if (SubDataSet03{data_counter_t0+l,37}-SubDataSet03{1,37})/1000 < end_dec
                        SubDataSet04(l,size(SubDataSet01,2)+1) = [{'1'}];
                    elseif (SubDataSet03{data_counter_t0+l,37}-SubDataSet03{1,37})/1000 >= end_dec &  (SubDataSet03{data_counter_t0+l,37}-SubDataSet03{1,37})/1000 < end_fed
                        SubDataSet04(l,size(SubDataSet01,2)+1) = [{'2'}];
                    elseif (SubDataSet03{data_counter_t0+l,37}-SubDataSet03{1,37})/1000 >= end_fed &  (SubDataSet03{data_counter_t0+l,37}-SubDataSet03{1,37})/1000 < end_fix
                        SubDataSet04(l,size(SubDataSet01,2)+1) = [{'3'}];
                    end                    
                end
                
                if k == 1
                    SubDataSet05 =SubDataSet04;
                else
                    SubDataSet05 = [SubDataSet05; SubDataSet04];
                end
            end
            
            if absRun ==1
                SubDataSet06 = SubDataSet05;
            else
                SubDataSet06 = [SubDataSet06; SubDataSet05];
            end
            
        end
        
        [x,FileName01,y] = fileparts(SUBJ.dataSet01(iCurFile).name);
        FileName02 = strcat(FileName01,'_merge','.xlsx');
        OutPutHeader = [OutPutHeader01 {'phase'} OutPutHeader02];
                
        cd (CurToPath);
        xlswrite (SubDataSet06,'',OutPutHeader, FileName02);
        cd (curDir);
        
    end
    
end

end       
 
