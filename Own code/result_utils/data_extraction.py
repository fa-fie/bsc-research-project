import os
import pandas as pd

# Lambdas for calculating metrics/properties
metric_lambdas = {
    'OA' : lambda x: (x.TP + x.TN) / (x.TP + x.TN + x.FP + x.FN),
    'FMeasure' : lambda x: x.TP / (x.TP + 1/2 * (x.FP + x.FN)),
    'Precision' : lambda x: x.TP / (x.TP + x.FP),
    'Recall' : lambda x: x.TP / (x.TP + x.FN),
    'False Alarm' : lambda x: x.FP / (x.FP + x.TN),
    'Missed Alarm' : lambda x: x.FN / (x.TP + x.FN)
}

# Initial resolutions of datasets in m/px
res_per_ds = {
    'LEVIRCDDataset' : 0.5,
    'OSCDDataset' : 10,
    'OSCDDatasetRGBBands' : 10
}

def merge_list_values(a, b):
    for key, vals_b in b.items():
        a[key].extend(vals_b)

def get_res(dataset):
    return res_per_ds[dataset]

def load_data_to_dataframe(
        directory,
        metrics_calc
):

    add_cols_lambdas = {}
    for metric in metrics_calc:
        add_cols_lambdas[metric] = metric_lambdas[metric]

    add_cols_lambdas['scaledRes'] = lambda x: x.dsResolution * x.factor
    add_cols_lambdas['mWidth'] = lambda x: x.refWidth * x.dsResolution * x.factor
    add_cols_lambdas['mHeight'] = lambda x: x.refHeight * x.dsResolution * x.factor
    add_cols_lambdas['groundN'] = lambda x: x.TN + x.FP
    add_cols_lambdas['groundP'] = lambda x: x.TP + x.FN
    add_cols_lambdas['pChange'] = lambda x: (x.TP + x.FN) / (x.TP + x.TN + x.FP + x.FN)
    add_cols_lambdas['Size'] = lambda x: x.refWidth * x.refHeight

    full_data = {}
    # Read in all the files
    for fname in os.listdir(directory):
        fpath = os.path.join(directory, fname)
        ftype = os.path.splitext(fname)[-1].lower()

        # Check if it is an Excel file
        if os.path.isfile(fpath) and ftype == '.xls':
            # Read data
            file_df = pd.read_excel(fpath, header=[0])

            # Add columns
            file_df['factor'] = int(fname.split('-')[2])
            file_df['dsResolution'] = file_df['dataset'].apply(get_res)
            file_df = file_df.assign(**add_cols_lambdas)

            # Append
            if full_data == {}:
                full_data = file_df.to_dict('list')
            else:
                merge_list_values(full_data, file_df.to_dict('list'))

    return pd.DataFrame(full_data)