%% Main script
clear all, close all;

%% Global options

% Show the difference image (DI)
GO_SHOW_CHANGE = false;
% Show the change map (CM)
GO_SHOW_MASK = false;
% Show the prettified detection results
GO_SHOW_PRETTIFIED = false;
% Plot the ROC curve
GO_SHOW_ROC_CURVE = false;

% PAUSE MODES:
% -1: resume next iteration when all figures closed;
% -2: press any key to continue
GO_PAUSE_MODE = 1;

PAUSE_EACH_ITER_ = GO_SHOW_CHANGE | GO_SHOW_MASK | GO_SHOW_PRETTIFIED | GO_SHOW_ROC_CURVE;

GO_CONFIG_ROC = {};
% Whether to print to the console
GO_VERBOSE = true;
% Whether to save the results
GO_SAVE_RESULTS = true;
% File to save the results
FILE_PATH = 'C:\Users\Owner\Documents\University\Y3\Q4\Research Project\Results\';
GO_OUT_FILE = append(FILE_PATH, 'justtestingyas');% 'LEVIR-factor-1-29.05-testset-cut-IRMAD-CVA-KMeans');

% If the file already exists, append a number until no file under that name
% exists
GO_OUT_FILE_PATH = append(GO_OUT_FILE, '.xls');
idx = 1;
while isfile(GO_OUT_FILE_PATH)
    GO_OUT_FILE_PATH = append(GO_OUT_FILE, '-', string(idx), '.xls');
    idx = idx + 1;
end

%% Configuration of algorithms, datasets, thresholding, metrics

% Available algorithms: CVA, DPCA, ImageDiff, ImageRatio, ImageRegr, IRMAD, MAD, PCAkMeans, PCDA
% Available datasets: AirChangeDataset, BernDataset, OSCDDataset, OttawaDataset, TaizhouDataset, LEVIRCDDataset
% -> NOTE: For LEVIRCDDataset, the data path needs to include the dataset directory (train/test/val)!
% Available binaryzation algorithms: FixedThre, KMeans, OTSU
% Available metrics: AUC, FMeasure, Kappa, OA, Recall, UA, ConfusionMatrix
% -> ConfusionMatrix will output TP, FP, FN, TN absolute values (pixel counts)

ALGS = {'IRMAD', 'CVA'}; %, 'DPCA', 'ImageRatio', 'ImageRegr', 'IRMAD', ...
    %'PCAkMeans', 'PCDA'};
DATASETS = {'LEVIRCDDataset'};
THRE_ALGS = {'KMeans'};
METRICS = {'AUC', 'ConfusionMatrix'};
%{'OA', 'UA', 'Recall', 'FMeasure', 'AUC', 'Kappa'};

% Whether to perform a band-wise pre-normalization on the inputs, requires a setting per algorithm
CONFIG_BAND_PRE_NORM = {false, true};
CONFIG_ALGS = {{}, {}, {}, {}, {}, {}, {}, {}, {}};
CONFIG_DATASETS = {
    {'C:\Users\Owner\Documents\University\Y3\Q4\Research Project\Datasets\LEVIR-dataset\LEVIR-CD_tiff_downsampled\LEVIR-CD_tiff_factor_16\test'}
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

% For debugging purposes
iterIdx = 0;

% Loop through all configured options (all combinations)
for aa = 1:length(ALGS)
    ALG = ALGS{aa};
    alg = Algorithms.(ALG)(CONFIG_ALGS{aa}{:});

    for dd = 1:length(DATASETS)
        DATASET = DATASETS{dd};
        dataset = Datasets.(DATASET)(CONFIG_DATASETS{dd}{:});
        
        for tt = 1:length(THRE_ALGS)
            iterDS = Datasets.CDDIterator(dataset);

            THRE_ALG = THRE_ALGS{tt};
            threAlg = ThreAlgs.(THRE_ALG)(CONFIG_THRE_ALGS{tt}{:});

            nMetrics = length(METRICS);
            metrics = cell(1, nMetrics);
            for ii = 1:nMetrics
                metrics{ii} = Metrics.(METRICS{ii})(CONFIG_METRICS{ii}{:});
            end
            nRows = iterDS.len;
            fileProps = cell(nRows, 1);
            
            %% Main loop
            curr = 0;
            while(iterDS.hasNext())
                curr = curr + 1;

                % Fetch data
                [t1, t2, ref, fprops] = iterDS.nextChunk();

                if GO_VERBOSE
                    % For debugging purposes
                    iterIdx = iterIdx + 1;
                    fprintf('NUMBER: %d\n', iterIdx);
                end

                fileProps{curr} = fprops; 
                
                if CONFIG_BAND_PRE_NORM{aa}
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

                        % ConfusionMatrix values will not be printed
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
            
            %% If enabled, collate and save results
            
            if GO_SAVE_RESULTS
                results = {};
                hasConfMatr = any(strcmp(METRICS,'ConfusionMatrix'));

                if nMetrics >= 1
                    if hasConfMatr
                        results = cell(nRows, nMetrics + 13);
                    else
                        results = cell(nRows, nMetrics + 10);
                    end
                
                    for ii = 1:nRows
                        results(ii, 1) = {alg.algName};
                        results(ii, 2) = {threAlg.algName};
                        results(ii, 3) = {CONFIG_BAND_PRE_NORM{aa}};
                        results(ii, 4) = {DATASET};
                        results(ii, 5) = CONFIG_DATASETS{dd};
                        fProps = fileProps{ii};
                        results(ii, 6) = fProps(1);
                        results(ii, 7) = fProps(2);
                        results(ii, 8) = fProps(3);
                        results(ii, 9) = fProps(4);
                        results(ii, 10) = fProps(5);

                        add = 10;
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

                if ~isfile(GO_OUT_FILE_PATH)
                    % The file does not exist yet, create it

                    header = ["name" "threAlg" "normalized" "dataset" "path" "t1Name" "t2Name" "refName" "refWidth" "refHeight"];
                    idx = 11;
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
            end
        end
    end
end