%%
% This is the code for copying data from bids to your project folder 
% written by Jin Wang July 2nd 2019
% This is only for math project

root='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/ELP/bids';  %This is the path where the data raw data sits
subjects={}; %  %This is the subject lists that you want for your own project
data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/screening/all_subjects.xlsx';
if isempty(subjects)
    M=readtable(data_info);
    subjects=M.participant_id;
end

new_root='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/preproc'; %This is the folder path where you want to do analysis
addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/scripts_to_share/1copy_your_data')); %make sure you copied the code expand_path.m in your codes 
global CCN;
CCN.funcf1='sub*Phon*.nii.gz'; %This is the functional folder you want to copy. In this example, it's everything.
CCN.anat='*_T1w.nii.gz'; % This is the file name of your anatomical data
session='ses-5';% Here is the time point, whether you want T1 data or T2 data, specify here

for i= 1:length(subjects)
    %old_dir=[root '/' subjects{i} '/ses-T1/'];
    old_dir=[root '/' subjects{i} '/' session];
    new_dir=[new_root '/' subjects{i} '/' session]; 
     if exist([old_dir '/func'])
        if ~exist(new_dir)
            mkdir(new_dir);
            mkdir([new_dir '/func']);
            mkdir([new_dir '/anat']);
        end
        source=expand_path([old_dir '/func/[funcf1]']);
        for jj=1:length(source)
            [f_path, f_name, ext]=fileparts(source{jj});
            f_name=f_name(1:end-4);
            mkdir([new_dir '/func/' f_name]);
            dest=[new_dir '/func/' f_name '/' f_name '.nii.gz'];
            dest_tsv=[new_dir '/func/' f_name '/' f_name(1:end-5) '_events.tsv'];
            copyfile(source{jj},dest);
            source_tsv=[f_path,'/', f_name(1:end-5),'_events.tsv'];
            copyfile(source_tsv,dest_tsv);
            system(['chmod -R 770 ', dest])
            system(['chmod -R 770 ', dest_tsv])
            gunzip(dest);
            delete(dest);
        end
        
        
        sanat=expand_path([old_dir '/anat/[anat]']); %Make sure this place you defined the correct MPRAGE path
        for kk=1:length(sanat)
        [a_path, a_name, ext]=fileparts(char(sanat{kk}));
        dt=[new_dir '/anat/' a_name ext]; %Here is the anat data you need
        copyfile(char(sanat{kk}),dt);
        system(['chmod -R 770 ', dt])
        cd(fileparts(dt));
        gunzip(dt);
        delete(dt);
        end
     else 
       fprintf('%s not found', subjects{i}); % I made this modificaiton to have a record of failed subjects based on Chris' suggestion. Not tested yet. 5/1/2020 Jin Wang
     end
end


