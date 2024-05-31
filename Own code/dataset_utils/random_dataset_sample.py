import random
import os
import cv2
import numpy as np
import sys

from util_functions import *



# NOTE: This code does not take label distributions into account, and is a simple random sampling 
# of the training set of LEVIR-CD. If used, it should be used with caution, and not for the evaluations of models.

# ------ Settings ------
# => These variables should be set to the desired settings!

# Number of image pairs to sample
num_samples = 120 
# The directory of the *training* dataset
dir_in = ''
# The directory to save the sampled dataset to
dir_out = ''

# -----------------------



# Create and set folders
a_folder_in = os.path.join(dir_in, 'A')
b_folder_in = os.path.join(dir_in, 'B')
label_folder_in = os.path.join(dir_in, 'label')

a_folder_out = os.path.join(dir_out, 'A')
b_folder_out = os.path.join(dir_out, 'B')
label_folder_out = os.path.join(dir_out, 'label')

if not os.path.exists(a_folder_out):
    os.makedirs(a_folder_out)

if not os.path.exists(b_folder_out):
    os.makedirs(b_folder_out)

if not os.path.exists(label_folder_out):
    os.makedirs(label_folder_out)

# Check how many images there are
all_names = os.listdir(a_folder_in)
num_tot = len(all_names)
if num_samples > num_tot:
    sys.exit('Invalid sample amount')

# Randomly sample a set size from the list
samples = random.sample(all_names, num_samples)

# Create copies
for sample in samples:
    a_img = cv2.imread(os.path.join(a_folder_in, sample))
    b_img = cv2.imread(os.path.join(b_folder_in, sample))
    label_img = cv2.imread(os.path.join(label_folder_in, sample))

    cv2.imwrite(os.path.join(a_folder_out, sample), a_img)
    cv2.imwrite(os.path.join(b_folder_out, sample), b_img)

    img_max = np.maximum.reduce(label_img, 2)
    img_min = np.minimum.reduce(label_img, 2)

    # Safety check
    if not np.all(img_max == img_min):
        sys.exit('Invalid binary result file')

    # 'Reduce' the label image
    label_img = img_max
    cv2.imwrite(os.path.join(label_folder_out, sample), label_img)