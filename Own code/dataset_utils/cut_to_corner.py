import os
import cv2
import numpy as np
import sys

from util_functions import *



# ------ Settings ------
# => These variables should be set to the desired settings!

# Dataset and directories

# The directory of the dataset
dir_in = ''

# The directory to save the modified dataset to
dir_out = ''

# Amount of pixels for one side (it is cut to a square)
size_side = 512

# The image datatype
datatype = 'tif'

# The dataset name, selected from: AirChange, LEVIR, OSCD
dataset = 'OSCD'

# -----------------------



# Cut images to a part in the upper left corner of the image
def cut_image_corner(dir, rel_path, fpath, datatype, dir_out, params):
    dir_file_out = os.path.join(dir_out, rel_path)
    if not os.path.exists(dir_file_out):
        os.makedirs(dir_file_out)
    
    image = cv2.imread(fpath)
    is_binary = is_binary_file(dir, rel_path, fpath, params['dataset'])

    if is_binary:
        image = reduce_to_one_band(image)

    if os.path.basename(fpath) == 'B01.tif':
        print(f"Size img {image.shape}")

    #if is_binary:
        #cv2.imwrite(os.path.join(dir_file_out, os.path.basename(fpath)), 
        #            image[:params['size_side'], :params['size_side']])
    #else:
        #cv2.imwrite(os.path.join(dir_file_out, os.path.basename(fpath)), image[:params['size_side'], :params['size_side'], :])

# Run
fparams = {
    'size_side' : size_side,
    'dataset' : dataset
}

rec_dir(dir_in, '', datatype, dir_out, cut_image_corner, fparams)