classdef OSCDDatasetRGBBands < Datasets.CDDataset
    methods
        function obj = OSCDDatasetRGBBands(data_path)
            obj@Datasets.CDDataset(data_path);
            
            obj.refStr = 'Onera Satellite Change Detection dataset';
            
            obj.loaders.ref = @Datasets.Loaders.tiffLoader;  % Use .tif labels
            %
            % For test phase declare a new subclass that extends
            % OSCDDataset and change some bahaviours
        end
        function initFileSys(obj)
            imgFolder = fullfile(obj.dataPath, 'Onera Satellite Change Detection dataset - Images');
            labFolder = fullfile(obj.dataPath, 'Onera Satellite Change Detection dataset - Test Labels');
            % Read folder names (training set only)
            fid = fopen(fullfile(imgFolder, 'test.txt'));
            names = fscanf(fid, '%s');
            fclose(fid);
            names = split(names, ',');
            bands = {'B02.tif', 'B03.tif', 'B04.tif'};
            
            for ii = 1:length(names)
                % Lists contain only the resampled-at-10m-resolution
                % images, i.e. the 'rect' ones
                name = names{ii};
                subFolder = fullfile(imgFolder, name, 'imgs_1_rect');
                % Sorted in alphabetical order
                for jj = 1:length(bands)
                    obj.t1List{ii}{jj} = fullfile(subFolder, bands{jj});
                end
                
                subFolder = fullfile(imgFolder, name, 'imgs_2_rect');
                % Corresponding to t1
                for jj = 1:length(bands)
                    obj.t2List{ii}{jj} = fullfile(subFolder, bands{jj});
                end
                
                obj.refList{ii} = fullfile(labFolder, name, sprintf('cm\\%s-cm.tif', name));
            end
            
        end
    end
end