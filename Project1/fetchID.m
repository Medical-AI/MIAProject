function files=fetchID(id)
% Define search folders here
benignFolder=dir('../../MIAData/MammoTraining/benign');
healthyFolder=dir('../../MIAData/MammoTraining/healthy');
malignantFolder=dir('../../MIAData/MammoTraining/malignant');

if(id>3000)
    %     Then look in the malignant data folder
    for i=1:length(malignantFolder)
        %         Whenever you find the ID
        if contains(malignantFolder(i).name,[num2str(id),'_','LEFT.png'])
            %             It should automatically be the left one first
            files.L=imread([malignantFolder(i).folder,'/',malignantFolder(i).name]);
            %             For the next two files in the series
            for j=1:2
                %                 Look for the corresponding files and store them
                if contains(malignantFolder(i+j).name,[num2str(id),'_','RIGHT.png'])
                    files.R=imread([malignantFolder(i+j).folder,'/',malignantFolder(i).name]);
                elseif contains(malignantFolder(i+j).name,[num2str(id),'_','RIGHT_MASK.png'])
                    %                     LR bit is 1 if right mask is to be used
                    files.lr=1;
                    files.mask=imread([malignantFolder(i+j).folder,'/',malignantFolder(i).name]);
                elseif contains(malignantFolder(i+j).name,[num2str(id),'_','LEFT_MASK.png'])
                    %                     If LR=0 then use it as left mask
                    files.lr=0;
                    files.mask=imread([malignantFolder(i+j).folder,'/',malignantFolder(i).name]);
                end
            end
            return;
        end
    end
%     If its not found after searching then throw an error
    error('File ID not found');
elseif(id>2000)
    for i=1:length(benignFolder)
        if contains(benignFolder(i).name,num2str(id))
            files.L=imread([benignFolder(i).folder,'/',benignFolder(i).name]);
            for j=1:2
                if contains(benignFolder(i+j).name,[num2str(id),'_','RIGHT.png'])
                    files.R=imread([benignFolder(i+j).folder,'/',benignFolder(i).name]);
                elseif contains(benignFolder(i+j).name,[num2str(id),'_','RIGHT_MASK.png'])
                    files.lr=1;
                    files.mask=imread([benignFolder(i+j).folder,'/',benignFolder(i).name]);
                elseif contains(benignFolder(i+j).name,[num2str(id),'_','LEFT_MASK.png'])
                    files.lr=0;
                    files.mask=imread([benignFolder(i+j).folder,'/',benignFolder(i).name]);
                end
            end
            return;
        end
    end
    error('File ID not found');
elseif(id>1000)
    for i=1:length(healthyFolder)
        if contains(healthyFolder(i).name,num2str(id))
            files.L=imread([healthyFolder(i).folder,'/',healthyFolder(i).name]);
            files.R=imread([healthyFolder(i+1).folder,'/',healthyFolder(i+1).name]);
            files.mask=-1;
            return;
        end
    end
    error('File ID not found');
else
    error('File ID not found');
end