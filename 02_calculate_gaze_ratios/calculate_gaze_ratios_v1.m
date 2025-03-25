function calculate_gaze_ratios_v1

% calculate_gaze_ratios.m
%
% Calculates gaze allocation ratios for each pixel on the screen.
%
% Author: Y. Shigemune
% Released: 12/26/2024
% Last Modified:  12/26/2024
%
% Parameters:
%   Resolution_W - Screen width (default: 1024)
%   Resolution_H - Screen height (default: 768)
%
% Input files:
%   - Merged data files created by merge_gaze_behavioral.m in Input directory
%
% Output files:
%   - [filename]_ratio_01.xlsx: Ratios for decision phase
%   - [filename]_ratio_02.xlsx: Ratios for feedback phase
%   - [filename]_ratio_03.xlsx: Ratios for fixation phase
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

% set resolution
Resolution_W = 1024; % Width
Resolution_H = 768; % Height
    
if size(SUBJ.dataSet,1) > 0
    
    % make codinates
    Cordinate =cell(Resolution_W*Resolution_H,2);
    Cordinate(:,:)=[{0}];
    
    for x = 1 : Resolution_W % width
        for y = 1: Resolution_H % height 
            Cordinate{Resolution_H*(x-1)+y,1} = x;
            Cordinate{Resolution_H*(x-1)+y,2} = y;
        end
    end
    
    OutPutHeader=[{'X'} {'Y'} {'Parcentage'}]; 
    
    for iCurFile = 1 : size(SUBJ.dataSet,1)
        
        SubDataSet = readfromexcel(fullfile(CurFromPath, SUBJ.dataSet(iCurFile).name),'sheet','Sheet1','All');
        SubDataSet = SubDataSet(2:end,:); 
        
        DataSet=cell(Resolution_W*Resolution_H,3); % Line: Cordinate, Column: Phase
        DataSet(:,:)=[{0}];
        
        % to calculate total time of valid measurement
        tResponse=0;
        tFeedback=0;
        tFixation=0;
        
        for iCurLine = 1 : size(SubDataSet,1)
            if  isnan(SubDataSet{iCurLine,73}) == 0 && isnan(SubDataSet{iCurLine,74}) == 0 % Column 73: Gaze point X, Column 74: Gaze point Y 
                if  0 < SubDataSet{iCurLine,73} && SubDataSet{iCurLine,73} <= Resolution_W 
                    if 0 < SubDataSet{iCurLine,74} && SubDataSet{iCurLine,74} <= Resolution_H                        
                        if SubDataSet{iCurLine,33} == 1  % colom 33: Phase 
                            DataSet{Resolution_H*(SubDataSet{iCurLine,73}-1)+SubDataSet{iCurLine,74},1} = DataSet{Resolution_H*(SubDataSet{iCurLine,73}-1)+SubDataSet{iCurLine,74},1} + SubDataSet{iCurLine,130};
                        elseif SubDataSet{iCurLine,33} == 2
                            DataSet{Resolution_H*(SubDataSet{iCurLine,73}-1)+SubDataSet{iCurLine,74},2} = DataSet{Resolution_H*(SubDataSet{iCurLine,73}-1)+SubDataSet{iCurLine,74},2} + SubDataSet{iCurLine,130};
                        elseif SubDataSet{iCurLine,33} == 3
                            DataSet{Resolution_H*(SubDataSet{iCurLine,73}-1)+SubDataSet{iCurLine,74},3} = DataSet{Resolution_H*(SubDataSet{iCurLine,73}-1)+SubDataSet{iCurLine,74},3} + SubDataSet{iCurLine,130};
                        end                        
                    end
                end
            end 
            if SubDataSet{iCurLine,33} == 1
                tResponse = tResponse + SubDataSet{iCurLine,130};  % Column 130: Duration 
            elseif SubDataSet{iCurLine,33} == 2
                tFeedback = tFeedback + SubDataSet{iCurLine,130};
            elseif SubDataSet{iCurLine,33} == 3
                tFixation = tFixation + SubDataSet{iCurLine,130};
            end
        end
        
        for iCurLine = 1 : size(DataSet,1)
            DataSet{iCurLine,1} = DataSet{iCurLine,1}/tResponse;
            DataSet{iCurLine,2} = DataSet{iCurLine,2}/tFeedback;
            DataSet{iCurLine,3} = DataSet{iCurLine,3}/tFixation;
        end
        
        [x,FileName,y] = fileparts(SUBJ.dataSet(iCurFile).name);
        FileName01 = strcat(FileName,'_ratio_01','.xlsx');
        FileName02 = strcat(FileName,'_ratio_02','.xlsx');
        FileName03 = strcat(FileName,'_ratio_03','.xlsx');
        
        DataSet01 = [Cordinate DataSet(:,1)];
        DataSet02 = [Cordinate DataSet(:,2)];
        DataSet03 = [Cordinate DataSet(:,3)];
        
        cd (CurToPath);
        xlswrite (DataSet01,'',OutPutHeader, FileName01);
        xlswrite (DataSet02,'',OutPutHeader, FileName02);
        xlswrite (DataSet03,'',OutPutHeader, FileName03);
        cd (curDir);
        
    end
    
end

end
