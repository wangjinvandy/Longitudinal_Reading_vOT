%This is the get_betas.m code modifed to extract beta from PPI folder
addpath('/dors/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12_elp');

% make sure marsbar is in the path
if(length(which('marsbar.m')) < 1)
	% edit this next line according to where you have marsbar installed
   	addpath(genpath('/dors/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12_elp/toolbox/marsbar'));
end
marsbar('on');


% What directory has all your subject folders? We assume that in each subject folder is
% a folder containing the SPM.mat file for that subject's 1st level analysis
rootDIR  = '/dors/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/preproc';


% Where do you want the text file containing the betas to be written?
writeDIR  = '/dors/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/';

% What directory has all your ROIS?
roi_file_root = '/dors/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/analysis3/s4_sphere_8--46_-53_-20_mask_topvoxels_ROIs/';

% make sure the scriptdir is in the path
addpath(pwd);

roi_is_image=1; % 0 if the image is "_roi.mat", 1 if the image is ".nii"; 
namerois = {'sphere_8--46_-53_-20_mask_rhyme_vs_onset_ses-7_p1_k100_adjust_mask' }; 

ROItype=2; % 1 if everyone has the same ROI, 2 if everyone has their own ROI.

%list all the subjects here
namesubjects={};
data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/screening/t1_to_keep.xlsx';
if isempty(namesubjects)
    M=readtable(data_info);
    namesubjects=M.participant_id;
end


numsubjects = length(namesubjects);
PPI_folder = 'analysis_ses5_s4/deweight/PPI_VOI_postSTG_rhyme7_vs_onset_gPPI';

%This information can be found in SPM.xX.name. You can only mention the related variables
nameconditions={'Sn(1) PPI_P_C','Sn(1) PPI_P_O','Sn(1) PPI_P_R', 'Sn(1) PPI_P_U', 'Sn(2) PPI_P_C','Sn(2) PPI_P_O','Sn(2) PPI_P_R', 'Sn(2) PPI_P_U'};
numconditions = length(nameconditions);

%These entries correspond to the condition names in nameconditions. I'd like to use these for column headings.
friendlyconditions=	{'PPI_perc1', 'PPI_onset1','PPI_rhyme1', 'PPI_unrelated1','PPI_perc2',  'PPI_onset2','PPI_rhyme2', 'PPI_unrelated2'};


%create an roi loop
roi = 1:length(namerois);
for w = roi
    thisroi = namerois(w);
    cd(writeDIR);

    fextension='.txt'; %our results file will have a .txt extension
    %fprefix='betas_';
    fprefix='betas_ctrl5_'; %it's also possible to make our results file have a prefix.

    writefile=char([char(fprefix) char(thisroi) char(fextension)]); %our results file will be named after the ROI associated with the betas it contains.

    delete(writefile); %deletes the data results file if it already exists (i.e., if you ran this script once already and made a whoopsie)
    headings=sprintf('%s\t',friendlyconditions{:}); % making a tab-delimited string of the condition headings in the order the betas are collected
    headings = ['ID	' headings];%We also need a column for the Subject ID
    fid=fopen(writefile, 'w');
    fprintf(fid,'%s',headings); %Now this results file has a header line containing human-readable condition names.	
    fprintf(fid,'\n');%we need a trailing newline character so our betas start on the next line. 
    % create a subject loop
    subj = 1:numsubjects;
    for x = subj
    thisguy = namesubjects(x);
      
    D=[];
    R=[];
    Y=[];
    xCON=[];
    E=[];
        fprintf('Working on participant %s for ROI %s\n', char(thisguy), char(thisroi));
	  
        switch ROItype %%%% OPTION 1: Everyone uses the same ROI: uncomment next block %%%%%
            case 1
                if (roi_is_image)
                    roi_file = char([char(roi_file_root) filesep char(thisroi) char('.nii')]);  %IF .NII FILE
                    R = maroi_image(roi_file);
                else
                    roi_file = char([char(roi_file_root) filesep char(thisroi) char('_roi.mat')]); %IF .MAT FILE
                    R  = maroi(roi_file);
                    
                end
            case 2  %%%%% OPTION 2: Each person has their own ROI: uncomment next block %%%%%
                if (roi_is_image)
                    roi_file = char([char(roi_file_root) filesep char(thisguy) filesep char(thisroi) char('.nii')]);  %IF .NII FILE
                    R = maroi_image(roi_file);
                else
                    roi_file = char([char(roi_file_root) filesep char(thisguy) filesep char(thisroi) char('_roi.mat')]); %IF .MAT FILE
                    R  = maroi(roi_file);
                    
                end
                
        end
        
        % piece together the name of the subject directory containing the SPM.mat file
        swd = [rootDIR filesep char(namesubjects(x)) filesep PPI_folder];
        %change to the subjects directory
        cd(swd);

    %try
    spm_name=load(fullfile(swd,'SPM.mat'));
    load('SPM.mat');
    cnames = transpose(SPM.xX.name); %get the condition names	

    % Make marsbar design object
    D  = mardo(spm_name);
   

    % Fetch data into marsbar data object
    Y  = get_marsy(R, D, 'mean');

    % Estimate design on ROI data
    E = estimate(D, Y);
    % get design betas
    B = betas(E);

    C=[];
    %for each condition
    %average the B value across runs
    for c = 1:(numconditions)
        betasum = 0;
        ctr = 0; %count number of betas you've grabbed for this condition. Initialize to zero because we haven't started grabbing them just yet.
        thiscondition = char(nameconditions(c)); %get name of the condition as a character array
        for bindex = 1:length(B)
        %go through cnames vector
            betaname = cnames(bindex);
            found = strfind(cnames(bindex), thiscondition); %looking for whether this beta matches thiscondition
            found = length(found{1,1});
            if found > 0 %condition matches
                betasum = betasum + B(bindex); %tack on the beta for this condition, which is a Run1 beta
		ctr = ctr+1; %increment the ctr
		%If you look at the SPM.xX.name vector, you will see that the Run2 entries are 6 entries after
		%the corresponding Run1 entry. That's because there are 6 regressors per condition in the model 
		%betasum = betasum + B(bindex+6); %add on the corresponding Run2 beta, which is 6 entries further on (bindex+6)
		%ctr = ctr+1; %increment the ctr. We grabbed 2 betas, so the counter should now be at 2.                
            end
        end
    
	C(length(C)+1)=betasum/ctr; %store average value for this condition
    end

      cd(writeDIR);
      fmt=[repmat('%f ', 1, size(C, 2)), '\n'];
      fprintf(fid, '%s ', char(thisguy));
      fprintf(fid, fmt, C);
      
    end
end


