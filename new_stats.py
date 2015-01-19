#!/usr/bin/env python

import os
import subprocess
import itertools
import struct
import numpy as np
import scipy as sp
from scipy import stats
from scipy.stats import norm

from collections import defaultdict

def statistically_signficant(x, y):
#    x = np.array([22.6195, 22.8267, 22.7055, 22.6648])
#    y = np.array([22.6868, 23.0453, 22.8111, 22.8756])
#    nobs, minmax, mean, variance, skewness, kurtosis = stats.describe(x)
#    t, prob = stats.ttest_ind(x, y)
#    print('Probability that there is difference (INDEPENDENT): %.3f%%' % prob)
#    t, prob = stats.ttest_ind(x, y, equal_var=False)
#    print('Probability that there is difference (WELCH): %.3f%%' % prob)
#    t, prob = stats.ttest_rel(x, y)
#    print('Probability that there is difference (RELATED): %.3f%%' % prob)
    return True

def determine_significance(mesa1, mesa2):
    return True

def do_the_numbers(mesas):
    OUTPUT="benchmark "
    for mesa in mesas:
        OUTPUT += str(mesa) + " "
    OUTPUT += "diff"
    OUTPUT += "%"
    OUTPUT += '\n'

    for bench in sorted(benchmarks, key=str.lower):
        OUTPUT += str(bench) + " "
        col1, col2, diff = determine_significance(benchmarks[bench])
        OUTPUT += str(col1) + " "
        OUTPUT += str(col2) + " "
        OUTPUT += str(diff) + " "
        OUTPUT += str(np.round(diff/col1, 2)) + " "
        OUTPUT += '\n'

    return OUTPUT

def run_column(string):
    p = subprocess.Popen(['column', '-t'], stdin=subprocess.PIPE)
    p.communicate(bytes(string, "utf-8"))

def process(mesas, benchmarks, database):
    # Numpy parses whole numbers as xxx. which doesn't work for scipy
    with np.errstate(invalid='ignore'):
        for r in itertools.product(mesas, benchmarks):
            cell = database[r[1]][r[0]]
            cell['average'] = np.average(cell['values'])
            cell['stats']=stats.describe(cell['values'])

def parse_results():
    database = defaultdict(defaultdict)
    mesas = list()
    benchmarks = list()
    for filename in os.listdir('.'):
        if '_' in filename:
            useless, benchmark_name, mesa_version = filename.split('_')
            database[benchmark_name][mesa_version] = {
                    'name' : mesa_version,
                    'bench' : benchmark_name,
                    'filename' : filename,
                    'values': np.around(np.loadtxt(filename, dtype=np.dtype(np.float32)), 3)}
            row[benchmark_name].name = benchmark_name
            mesas.append(mesa_version)
            benchmarks.append(benchmark_name)
            assert(useless == "bench")

    mesas = np.unique(mesas)
    benchmarks = np.unique(benchmarks)
    process(mesas, benchmarks, database)

    return (mesas, benchmarks, database)

def print_results(mesa, benchmarks, database):
    OUTPUT="benchmark "
    for mesa in mesas:
        OUTPUT += str(mesa) + " "
    OUTPUT += '\n'
    for bench in benchmarks:
        OUTPUT += bench + " "
        for mesa in mesas:
            OUTPUT+=str(database[bench][mesa]['average']) + " "
        OUTPUT += '\n'

    run_column(OUTPUT)

def print_results2(mesa, benchmarks, database):
    for bench in benchmarks:
        for key, value in database[bench].items():
            print(key)
            print(value['average'])
            print(value['bench'])

if __name__ == "__main__":
    parse_results()
    mesas, benchmarks, database = parse_results()
    print_results2(mesas, benchmarks, database)
    #print_results(mesas, benchmarks, database)
#   run_column(do_the_numbers())
