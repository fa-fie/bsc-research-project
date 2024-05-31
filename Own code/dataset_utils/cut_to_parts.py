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

# The amount of images to cut to, for one side, meaning = 2 will cut the image into 2x2 (i.e., 4 images)
# NOTE: The cut has to result in an integer number of pixels!
amount_one_side = 2

# The image datatype
datatype = 'tiff'

# The dataset name, selected from: AirChange, LEVIR, OSCD
dataset = 'LEVIR' 

# -----------------------



# Cut image into parts
def cut_image_into_parts(dir, rel_path, fpath, datatype, dir_out, params):
    dir_file_out = os.path.join(dir_out, rel_path)
    if not os.path.exists(dir_file_out):
        os.makedirs(dir_file_out)
    
    image = cv2.imread(fpath)
    is_binary = is_binary_file(dir, rel_path, fpath, params['dataset'])

    if is_binary:
        img_max = np.maximum.reduce(image, 2)
        img_min = np.minimum.reduce(image, 2)

        # Safety check
        if not np.all(img_max == img_min):
            sys.exit('Invalid binary result file')

        # 'Reduce' the image
        image = img_max

    amt_pixels = [int(image.shape[0] / params['amount_one_side']), int(image.shape[1] / params['amount_one_side'])]
    
    # Reference: https://stackoverflow.com/questions/53755910/how-can-i-split-a-large-image-into-small-pieces-in-python
    for r_idx, row in enumerate(range(0, image.shape[0], amt_pixels[0])):
        for c_idx, col in enumerate(range(0, image.shape[1], amt_pixels[1])):
            fname_components = os.path.basename(fpath).split('.')
            write_path = os.path.join(dir_file_out, fname_components[0] + f'_row_{r_idx}_col_{c_idx}.' + fname_components[1])

            if is_binary:
                cv2.imwrite(write_path, image[row : row + amt_pixels[0], col : col + amt_pixels[1]])
            else:
                cv2.imwrite(write_path, image[row : row + amt_pixels[0], col : col + amt_pixels[1], :])

# Run
fparams = {
    'amount_one_side' : amount_one_side,
    'dataset' : dataset
}

rec_dir(dir_in, '', datatype, dir_out, cut_image_into_parts, fparams)