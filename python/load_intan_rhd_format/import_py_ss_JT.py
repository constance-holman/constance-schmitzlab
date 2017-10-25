import glob
from load_intan_rhd_format import read_data
import numpy as np
import os

#possible probe types:
#'CNT32_edge'
#'4x8LFP'
#'CNT64'


def convert_files(dir,probename):
    os.chdir(dir)
    filelist_rhd = sorted(glob.glob("*.rhd"))

    for file in filelist_rhd:
        temp = read_data(file)
        temp_data = temp['amplifier_data']
        np.save(file[:-4],temp_data)

    filelist_npy = sorted(glob.glob("*.npy"))

    numpy_vars = {}
    for np_name in filelist_npy:
        print np_name
        numpy_vars[np_name] = np.load(np_name)

    final_array = np.concatenate(numpy_vars.values(),1)

    if probename == 'CNT32_edge':
        remap_list = [4,13,5,12,15,6,2,11,14,7,3,10,8,9,16,1,20,29,21,28,31,22,18,27,30,23,19,26,24,25,32,17]
    elif probename == '4x8LFP':
        remap_list = [27,17,22,21,20,26,25,30,29,24,18,19,31,23,16,28,8,13,9,2,7,15,1,0,5,11,12,10,4,14,3,6]
    elif probename == 'CNT64':
        [60, 57, 52, 51, 64, 63, 15, 16, 13, 14, 12, 11, 10, 9, 8, 7, 55, 58, 57, 50, 56, 49, 51, 52, 30, 54, 53,4, 1, 6, 5, 2, 48, 45, 46, 44, 47, 43, 42, 3, 41, 29, 40, 37, 31, 28, 27, 32, 38, 39, 36, 35, 34, 33, 17,18, 19, 20, 22, 21, 24, 23, 26, 25]
    elif probename == 'poly2_optrode_intan':
        remap_list = [8, 24, 2, 29, 7, 26, 15, 21, 11, 23, 12, 28, 6, 18, 13, 22, 5, 27, 4, 31, 10, 20, 9, 25, 14, 30, 3, 19, 16, 32, 1, 17]
    elif probename == 'poly3_optrode_intan':
        remap_list = [1, 27, 17, 5, 31, 16, 4, 22, 32, 13, 18, 3, 6, 28, 19, 12, 23, 14, 11, 21, 30, 15, 26, 9, 7, 29, 25, 2, 24, 10, 8, 20]
    # NOTE poly2 and poly3 remaps are based on anatomical layout
    # ie putting intan ch# for most dorsal site first, then left to right sites down to tip
    # add alternative probe types here
    i = np.argsort(remap_list)
    sorted_array = final_array[i,:]

    np.save('JT_bpac1_rec2_6minsbaseline.npy', sorted_array)
    (open('JT_bpac1_rec2_6minsbaseline.dat', 'wb')).write(sorted_array.T.tostring())


