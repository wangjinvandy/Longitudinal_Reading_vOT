function ROIoverlaps
% This script will combine all the individual ROIs, and using mricron to
% show color-code clusters depending on the amount of overlaps. written by
% Jin Wang 5/3/2019

addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabTools/nifti')); % addpath the nifti function tools, for this script it is mainly using the load_nii.m and save_nii.m.

root_dir = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/analysis5/postSTG_topvoxels_ROIs/'; % your individual ROI paths

subjects = {};
data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/screening/t1_to_keep.xlsx';
if isempty(subjects)
    M=readtable(data_info);
    subjects=M.participant_id;
end

%roi_name= 'postSTG_onset_vs_rhyme_ses-5_p1_k100_adjust_mask.nii';
%roi_name= 'postSTG_onset_vs_rhyme_ses-7_p1_k100_adjust_mask.nii';
%roi_name= 'postSTG_rhyme_vs_onset_ses-5_p1_k100_adjust_mask.nii';
roi_name= 'postSTG_rhyme_vs_onset_ses-7_p1_k100_adjust_mask.nii';

    %set s.img as zeros, the matrix sized depends on the first subejct
    %s.img size
    idx = 1; 
    roi_dir = [root_dir '/' subjects{1} '/' roi_name];
    s = load_nii(roi_dir);
    s.img = zeros(size(s(1).img));
    
    % add subjects s.img up
    for ii = 1:length(subjects)
        roi_dir = [root_dir '/' subjects{ii} '/' roi_name];
        m(idx) = load_nii(roi_dir);
        s.img = s.img + double(m(idx).img);
        idx=idx+1;
    end
cd(root_dir);
%save_nii(s,'combined_ROIs_sphere_8--46_-53_-20_mask_rhyme_vs_onset_ses7.nii')  % The name of your combined ROI
save_nii(s,['combined_ROIs_',roi_name]) 

end