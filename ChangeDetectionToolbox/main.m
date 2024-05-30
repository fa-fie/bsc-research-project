%% Main script
clear all, close all;

%% Global options
GO_SHOW_CHANGE = false;	% Show the difference image (DI)
GO_SHOW_MASK = false;	% Show the change map (CM)
GO_SHOW_PRETTIFIED = true;	% Show the prettified detection results
GO_SHOW_ROC_CURVE = false;	% Plot the ROC curve

GO_BAND_PRE_NORM = false;	% Perform a band-wise pre-normalization on the inputs

GO_CONFIG_ROC = {};
GO_VERBOSE = true;
GO_SAVE_RESULTS = true;
GO_OUT_FILE = '';		    % File to save the results
GO_OUT_FILE_TYPE = 'xls';	% Filetype for saving the results
GO_ALL_RESULTS = true;      % Save all metric values, not only average

% If the file already exists, append a number until no file under that name
% exists
GO_OUT_FILE_PATH = append(GO_OUT_FILE, '.', GO_OUT_FILE_TYPE);
idx = 1;
while isfile(GO_OUT_FILE_PATH)
    GO_OUT_FILE_PATH = append(GO_OUT_FILE, '-', string(idx), '.', GO_OUT_FILE_TYPE);
    idx = idx + 1;
end

% PAUSE MODES:
% -1: resume next iteration when all figures closed;
% -2: press any key to continue
GO_PAUSE_MODE = 1;

PAUSE_EACH_ITER_ = GO_SHOW_CHANGE | GO_SHOW_MASK | GO_SHOW_PRETTIFIED | GO_SHOW_ROC_CURVE;

%% Opt and configure the IMPORTANT ones
%{
	Available algorithms: CVA, DPCA, ImageDiff, ImageRatio, ImageRegr, IRMAD, MAD, PCAkMeans, PCDA

	Available datasets: AirChangeDataset, BernDataset, OSCDDataset,
 OttawaDataset, TaizhouDataset, LEVIRCDDataset

    NOTE: For LEVIRCDDataset, the data path needs to include the dataset
    directory (train/test/val)!

	Available binaryzation algorithms: FixedThre, KMeans, OTSU

	Available metrics: AUC, FMeasure, Kappa, OA, Recall, UA
%}
ALGS = {'IRMAD', 'CVA'}; %, 'DPCA', 'ImageRatio', 'ImageRegr', 'IRMAD', ...
    %'PCAkMeans', 'PCDA'};
DATASETS = {'LEVIRCDDataset'};
THRE_ALGS = {'KMeans'};
METRICS = {'AUC', 'ConfusionMatrix'};
%{'OA', 'UA', 'Recall', 'FMeasure', 'AUC', 'Kappa'};

CONFIG_ALGS = {{}, {}, {}, {}, {}, {}, {}, {}, {}};
CONFIG_DATASETS = {
    {'C:\Users\Owner\Documents\University\Y3\Q4\Research Project\Datasets\LEVIR-dataset\LEVIR-CD_tiff_cut_2\test'}
};
CONFIG_THRE_ALGS = {{}};
CONFIG_METRICS = {{}, {}, {}, {}, {}, {}};

% Check it
if GO_SHOW_ROC_CURVE
    [~, loc] = ismember('AUC', METRICS);
    if loc == 0
        error('AUC was not included in the desired metrics');
    end
end

iterIdx = 0;

% Loop through all configured options (all combinations)
for aa = 1:length(ALGS)
    for dd = 1:length(DATASETS)
        for tt = 1:length(THRE_ALGS)
            %% Assign variables
            ALG = ALGS{aa};
            DATASET = DATASETS{dd};
            THRE_ALG = THRE_ALGS{tt};

            %% Construct objects
            alg = Algorithms.(ALG)(CONFIG_ALGS{aa}{:});
            dataset = Datasets.(DATASET)(CONFIG_DATASETS{dd}{:});
            iterDS = Datasets.CDDIterator(dataset);
            threAlg = ThreAlgs.(THRE_ALG)(CONFIG_THRE_ALGS{tt}{:});
            nMetrics = length(METRICS);
            metrics = cell(1, nMetrics);
            for ii = 1:nMetrics
                metrics{ii} = Metrics.(METRICS{ii})(CONFIG_METRICS{ii}{:});
            end
            
            %% Main loop
            n = 0;
            while(iterDS.hasNext())
                n = n + 1;
                
                % Fetch data
                [t1, t2, ref] = iterDS.nextChunk();

                iterIdx = iterIdx + 1;
                fprintf('NUMBER: %d\n', iterIdx);
                
                if GO_BAND_PRE_NORM
                    % Perform a band-wise z-score normalization before any further
                    % algorithm is applied
                    fcnNorm = @Utilities.normMeanStd;
                    [t1, t2] = deal(fcnNorm(double(t1)), fcnNorm(double(t2)));
                end
                
                % Make difference image
                DI = alg.detectChange(t1, t2);
                % Segment
                CM = threAlg.segment(DI);
                % Measure
                cellfun(@(obj) obj.update(CM, ref, DI), metrics);
                
                if GO_VERBOSE
                    for ii = 1:nMetrics
                        m = metrics{ii};

                        if ~strcmp(METRICS{ii}, 'ConfusionMatrix')
                            fprintf('type: %s\n', METRICS{ii});
                            fprintf('\tnewest: %f\n', m.val(end));
                            fprintf('\taverage: %f\n', m.avg);
                        end
                    end
                    fprintf('\n')
                end
                
                if PAUSE_EACH_ITER_
                    handles = [];
                    if GO_SHOW_CHANGE
                        figure('Name', 'Change Map'),
                        chns = size(DI, 3);
                        if  chns ~= 1 && chns ~=3
                            imshow(Utilities.normMinMax(Utilities.mergeAvg(DI)));
                        else
                            imshow(Utilities.normMinMax(DI));
                        end
                        handles = [handles, gcf];
                    end
                    
                    if GO_SHOW_MASK
                        figure('Name', 'Change Mask'),
                        imshow(CM);
                        handles = [handles, gcf];
                    end
                    
                    if GO_SHOW_PRETTIFIED
                        figure('Name', 'Prettified Change Map'),
                        imshow(Utilities.pretty(DI, CM, ref));
                        handles = [handles, gcf];
                    end
                    
                    if GO_SHOW_ROC_CURVE
                        if ~exist('aucer', 'var')
                            aucer = metrics{loc};
                        end
                        fig = aucer.plotROC(GO_CONFIG_ROC{:});
                        handles = [handles, fig];
                    end
                    
                    if (iterDS.hasNext())
                        if GO_PAUSE_MODE == 1
                            for h = handles
                                waitfor(h);
                            end
                        elseif GO_PAUSE_MODE == 2
                            pause
                        else
                            ;
                        end
                    end
                end
            end
            
            %% Collate and save results

            results = {};
            if GO_ALL_RESULTS
                hasConfMatr = any(strcmp(METRICS,'ConfusionMatrix'));

                if nMetrics >= 1
                    if hasConfMatr
                        results = cell(n, nMetrics + 6);
                    else
                        results = cell(n, nMetrics + 3);
                    end
             
                    for ii = 1:n
                        results(ii, 1) = {alg.algName};
                        results(ii, 2) = {threAlg.algName};
                        results(ii, 3) = {DATASET};

                        add = 3;
                        for jj = 1:nMetrics
                            if strcmp(METRICS{jj}, 'ConfusionMatrix')
                                results(ii, jj + add) = metrics{jj}.val((ii - 1) * 4 + 1);
                                results(ii, jj + add + 1) = metrics{jj}.val((ii - 1) * 4 + 2);
                                results(ii, jj + add + 2) = metrics{jj}.val((ii - 1) * 4 + 3);
                                results(ii, jj + add + 3) = metrics{jj}.val(ii * 4);

                                add = add + 3;
                            else
                                results(ii, jj + add) = {metrics{jj}.val(ii)};
                            end
                        end
                    end
                end
            else
                for ii = 1:nMetrics
                    results{ii} = metrics{ii}.avg;
                end
            end
            
            if GO_SAVE_RESULTS
                [~, ~, ext] = fileparts(GO_OUT_FILE_PATH);
                switch ext
                    % TODO
                    % case '.mat'
                    %    save(GO_OUT_FILE_PATH, 'results');
                    case {'.xls', '.xlsx'}
                        if ~isfile(GO_OUT_FILE_PATH)
                            % The file does not exist yet, create

                            header = ["name" "threAlg" "dataset"];
                            idx = 4;
                            for jj = 1:nMetrics
                                if strcmp(METRICS{jj}, 'ConfusionMatrix')
                                    header(idx) = "TP";
                                    header(idx + 1) = "FP";
                                    header(idx + 2) = "TN";
                                    header(idx + 3) = "FN";
                                    idx = idx + 4;
                                else
                                    header(idx) = METRICS{jj};
                                    idx = idx + 1;
                                end
                            end

                            writematrix(header, GO_OUT_FILE_PATH);
                        end
                        writecell(results, GO_OUT_FILE_PATH, 'WriteMode', 'append');
                    otherwise
                        error('Unsupported type of file');
                end
            end
        end
    end
end