import os
import sys
import numpy as np

# Recursively search a directory, applying a given function to each file if it is of a specific datatype
def rec_dir(dir, rel_path, datatype, dir_out, f, fparams):
    current_dir = os.path.join(dir, rel_path)

    for fname in os.listdir(current_dir):
        fpath = os.path.join(current_dir, fname)
        ftype = os.path.splitext(fpath)[-1].lower()

        if os.path.isfile(fpath) and ftype == '.' + datatype:
            f(dir, rel_path, fpath, datatype, dir_out, fparams)
        elif not os.path.isfile(fpath):
            rec_dir(dir, os.path.join(rel_path, fname), datatype, dir_out, f, fparams)

# Check if a file is a binary change map
def is_binary_file(dir, rel_path, fpath, dataset):
    if dataset == 'AirChange':
        dtype = os.path.basename(fpath).split('.')[0]
        return dtype == 'gt'
    elif dataset == 'LEVIR':
        return 'label' in rel_path
    elif dataset == 'OSCD':
        return 'Labels' in rel_path
    else:
        sys.exit('Invalid dataset selected')

# Make sure binary files only have one "band" (i.e., 2 dimensional)
def reduce_binary_to_2D(image):
    img_max = np.maximum.reduce(image, 2)
    img_min = np.minimum.reduce(image, 2)

    # Safety check
    if not np.all(img_max == img_min):
        sys.exit('Invalid binary result file')

    # 'Reduce' the image
    return img_max