classdef ConfusionMatrix < Metrics.CDMetric
    methods
        function obj = ConfusionMatrix()
            % Confusion matrix: TP, FP, TN, FN
            obj@Metrics.CDMetric();
        end
    end
    
    methods (Access=public)
        function values = gauge(obj, pred, gnd, ~)
            TP = obj.getTP(pred, gnd);
            FP = obj.getFP(pred, gnd);
            TN = obj.getTN(pred, gnd);
            FN = obj.getFN(pred, gnd);
            values = {TP, FP, TN, FN};
        end
    end
end