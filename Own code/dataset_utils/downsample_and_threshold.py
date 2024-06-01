import os
import cv2
import numpy as np
import sys
from osgeo import gdal

from util_functions import *



# ------ Settings ------
# => These variables should be set to the desired settings!

# Thresholding binary maps
min = 1     # Minimum value of a band in one pixel
max = 2     # Maximum value of a band in one pixel
threshold = min + (max - min) / 2.0     # Threshold for setting a pixel to be 'true' (i.e., change)
inclusive_upper = True  # Whether a value equal to the threshold value should be set to 'true' (i.e., change)

# Downsampling
interpolation_alg = cv2.INTER_AREA  # The interpolation algorithm for downsampling
downsample_factor = 4   # The inverse factor of downsampling (e.g., 2 results in 1/2 of the size)

# Dataset and directories

# The directory of the dataset
dir_in = ''
# The directory to save the modified dataset to
dir_out = dir_in + '_factor_' + str(downsample_factor) 
datatype = 'tif' # The image datatype
dataset = 'OSCD' # The dataset name, selected from: AirChange, LEVIR, OSCD

# -----------------------


# Thresholding util function
def threshold_val(value, inclusive_upper, threshold):
    if inclusive_upper:
        if value >= threshold:
            return max
        else:
            return min
    else:
        if value > threshold:
            return max
        else:
            return min
        
# Downsample image and threshold binary maps
def downsample_and_threshold(dir, rel_path, fpath, datatype, dir_out, params):
    dir_file_out = os.path.join(dir_out, rel_path)
    if not os.path.exists(dir_file_out):
        os.makedirs(dir_file_out)
    
    image = None
    if dataset == 'OSCD':
        image = gdal.Open(fpath).ReadAsArray() 
    else:
        image = cv2.imread(fpath)
    
        if is_binary_file(dir, rel_path, fpath, params['dataset']):
            image = reduce_to_one_band(image)

    # Resize the image
    size_1 = int(image.shape[0] * 1 / params['downsample_factor'])
    size_2 = int(image.shape[1] * 1 / params['downsample_factor'])
    resized = cv2.resize(image, dsize=(size_2, size_1), interpolation=params['interpolation_alg'])

    # Apply threshold
    if is_binary_file(dir, rel_path, fpath, params['dataset']):
        # Reference: https://numpy.org/doc/stable/reference/arrays.nditer.html
        with np.nditer(resized, op_flags=['readwrite']) as iterator:
            for value in iterator:
                value[...] = threshold_val(value, params['inclusive_upper'], params['threshold'])

    # Write to file
    cv2.imwrite(os.path.join(dir_file_out, os.path.basename(fpath)), resized)

# Run
fparams = {
    'downsample_factor' : downsample_factor,
    'interpolation_alg' : interpolation_alg,
    'threshold' : threshold,
    'inclusive_upper': inclusive_upper,
    'dataset' : dataset
}

rec_dir(dir_in, '', datatype, dir_out, downsample_and_threshold, fparams)