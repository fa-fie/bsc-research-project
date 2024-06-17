from matplotlib import pyplot as plt
from osgeo import gdal
import numpy as np

files = [
    
]

for file in files:
    data_file = gdal.Open(file)
    arr_vals = data_file.ReadAsArray()
    plt.figure()
    plt.imshow(arr_vals)

plt.show()