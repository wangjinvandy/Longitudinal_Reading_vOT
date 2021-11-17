%%This code is to clean the bad data after main_just_for_movment.m and
%%count_repaired_acc.m. What I did was to screen the data using excel using
%%the ouput of count_repaired_acc.m. Then make a data_to_keep excel file that
%%saves the subjects, run_name1,run_name2 etc. Each
%%variable should be a column.

filenm='func_to_keep.xlsx';
path='/dors/booth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/screening';
data_folder='/dors/booth/JBooth-Lab/BDL/jinwang/ReadingvOT_5_7/preproc';
session ='ses-7';

%read in the data in excel
M=readtable([path '/' filenm]);
good_subjects=M.participant_id;
good_run_list=M.ses_7;

%%%%%%%%%%%%%%%%%%%%%%%should not edit below%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%read in the good subject lists from your data_to_keep excel
%read in all the subjects in your data_folder
listing=dir(data_folder);
all_list=extractfield(listing,'name');
index=strfind(all_list,'sub-');
idx=find(not(cellfun('isempty',index)));
subjects=all_list(idx);

for i=1:length(subjects)
    m=1;
    while m<=length(good_subjects)
        if strcmp(subjects{i},good_subjects{m})
            break
        end
        m=m+1;
    end
    if m<=length(good_subjects)
        sub_path=[data_folder '/' subjects{i} '/' session];
        list=dir([sub_path '/func']);
        all_names=extractfield(list,'name');
        index2=strfind(all_names,'sub');
        idx2=find(not(cellfun('isempty',index2)));
        all_f=all_names(idx2);
        for j=1:length(all_f)
            n=1;
            while n<=length(good_run_list)
                good_run=good_run_list{n};
                if strcmp(all_f{j},good_run)
                    break
                end
                n=n+1;
            end
            if n>length(good_run_list)
                rmdir([sub_path '/func/' all_f{j}], 's');
            end
        end
    else
        rmdir([data_folder '/' subjects{i}],'s');
    end
end



