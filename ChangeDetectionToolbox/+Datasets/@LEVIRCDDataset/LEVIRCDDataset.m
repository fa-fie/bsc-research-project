classdef LEVIRCDDataset < Datasets.CDDataset
    methods
        function obj = LEVIRCDDataset(data_path)
            obj@Datasets.CDDataset(data_path);
            
            obj.refStr = 'LEVIR Change Detection dataset';
            
            obj.loaders.ref = @Datasets.Loaders.tiffLoader;  % Use .tif labels
        end
        function initFileSys(obj)
            % Load files
            % Important: the data path needs to include the dataset
            % directory (train/test/val)!

            t1Folder = dir(fullfile(obj.dataPath, 'A', '*.tiff'));
            t2Folder = dir(fullfile(obj.dataPath, 'B', '*.tiff'));
            labFolder = dir(fullfile(obj.dataPath, 'label', '*.tiff'));
            
            for ii = 1:length(t1Folder)
                obj.t1List{ii} = fullfile(t1Folder(ii).folder, t1Folder(ii).name);
            end

            for ii = 1:length(t2Folder)
                obj.t2List{ii} = fullfile(t2Folder(ii).folder, t2Folder(ii).name);
            end

            for ii = 1:length(labFolder)
                obj.refList{ii} = fullfile(labFolder(ii).folder, labFolder(ii).name);
            end
        end
    end
end