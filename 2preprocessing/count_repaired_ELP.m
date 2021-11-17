%%
%count_repaired
%This script calculate the movement, accuracy, and rt for each run. written
%by Jin Wang 1/3/2021, updated 1/5/2021
%The number of volumes being replaced (the second column) and how many chunks of more than 6 consecutive volumes being
%replaced (the third column) are based on the output of art-repair (in the code main_just_for_movement.m). 
%The acc and rt for each condition of a run are calculated based on the
%documented in ELP/bids/derivatives/func_mv_acc_rt/ELP_Acc_RT_final_2020_12_18.doc

global CCN;
root='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/preproc';
addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/scripts_to_share/2preprocessing'));
CCN.func_n='sub*Phon*';
CCN.ses='ses-5';
n=6; %number of consecutive volumes being replaced. no more than 6 consecutive volumes being repaired.
writefile='movement_Phone_ses-5.txt';
subjects = {}; % if this is empty, it will read data_info.
data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/screening/all_subjects.xlsx';

if isempty(subjects)
    M=readtable(data_info);
    subjects=M.participant_id;
end

%%%%%%%%%%%%%%should not edit below%%%%%%%%%%%%%%%%%%%%%%
cd(root);
if exist(writefile)
    delete(writefile);
end
fid=fopen(writefile,'w');
hdr='subjects run_name num_repaired chunks';
fprintf(fid, '%s', hdr);
fprintf(fid, '\n');
for i=1:length(subjects)
    func_p=[root '/' subjects{i}];
    func_f=expand_path([func_p '/[ses]/func/[func_n]/']);
    for j=1:length(func_f)
        run_n=func_f{j}(1:end-1);
        [run_p, run_name]=fileparts(run_n);
        %get the movement data from art_repair
        cd(run_n);
        fileid=fopen('art_repaired.txt');
        m=fscanf(fileid, '%f');
        [num_repaired, col]=size(m);
        N=n; %N=(n-1); it is no more than 6 consecutive volumes repaired described in the paper. This is wrong, corrected by Jin 6/21/2020
        x=diff(m')==1;
        ii=strfind([0 x 0], [0 1]);
        jj=strfind([0 x 0], [1 0]);
        %idx=max(jj-ii);
        %out=(idx>=N);
        out=((jj-ii)>=N);
        if out==0
            chunks=0;
        else
            %chunks=length(out); This is wrong. corrected on 5/1/2020 by
            %Jin Wang
            chunks=sum(out(:)==1);
        end
        
           
        %save all the values to txt
        fprintf(fid,'%s %s %d %d \n', ...
            subjects{i}, run_name, num_repaired, chunks);
    end
end




