import glob
from load_intan_rhd_format import read_data
import numpy as np
import os


def convert_files(dir):
    os.chdir(dir)
    filelist_rhd = sorted(glob.glob("*.rhd"))
    print(filelist_rhd)

    for file in filelist_rhd:
        temp = read_data(file)
        temp_data = temp['amplifier_data']
        np.save(file[:-4],temp_data)

    filelist_npy = sorted(glob.glob("*.npy"))
    
    numpy_vars = {}
    for np_name in filelist_npy:
        print(np_name)
        numpy_vars[np_name] = np.load(np_name)
    print(numpy_vars.values())

    final_array = np.concatenate(numpy_vars.values(),1)
    np.save('L71_LH_rec1.npy', final_array)
    (open('L71_LH_rec1.dat', 'wb')).write(final_array.T.tostring())
