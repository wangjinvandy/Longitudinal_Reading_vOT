%%This code is used to remove the bad anat_T1 that is not in the
%%good_t1_list.txt

data_info='/dors/booth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/screening/t1_to_keep.xlsx';
data_path='/dors/booth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/preproc';
session='ses-7'; %edit
subjects={};

if isempty(subjects)
    M=readtable(data_info);
    subjects=M.participant_id;
    run_name=M.t1_ses_7;%edit
end

for i=1:length(subjects)
    sub_path=[data_path '/' subjects{i} '/' session '/anat'];
    list=dir(sub_path);
    all_names=extractfield(list,'name');
    index2=strfind(all_names,'sub');
    idx2=find(not(cellfun('isempty',index2)));
    all_a=all_names(idx2);
    
    for j=1:length(all_a)
        n=1;
        while n<=length(run_name)
            good_run=[run_name{n} '.nii'];
            if strcmp(all_a{j},good_run)
                break
            end
            n=n+1;
        end
        
        if n>length(run_name)
            delete([sub_path '/' all_a{j}]);
        end
    end
end