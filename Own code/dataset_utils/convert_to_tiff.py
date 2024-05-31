import os
from osgeo import gdal

from util_functions import *



# ------ Settings ------
# => These variables should be set to the desired settings!

# Dataset and directories
dir_in = '' # The directory of the dataset
dir_out = '' # The directory to save the modified dataset to
datatype = 'bmp' # The image datatype

# -----------------------



tiff_driver = gdal.GetDriverByName('GTiff')

# Convert a given file to a .tiff file
# Reference: https://github.com/Bobholamovic/ChangeDetectionToolbox (raster2tiff script)
# Their references: https://gis.stackexchange.com/questions/42584/how-to-call-gdal-translate-from-python-code,
# https://gdal.org/tutorials/raster_api_tut.html#using-createcopy
def convert_to_tiff(dir, rel_path, fpath, datatype, dir_out, params):
    fname = os.path.basename(fpath).split('.')[0]
    data_in = gdal.Open(fpath)
    
    dir_file_out = os.path.join(dir_out, rel_path)
    if not os.path.exists(dir_file_out):
        os.makedirs(dir_file_out)
    
    tiff_driver.CreateCopy(os.path.join(dir_file_out, fname + '.tiff'), data_in, 0)

# Run
rec_dir(dir_in, '', datatype, dir_out, convert_to_tiff, {})