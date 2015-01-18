#!/usr/bin/env python

import os
import subprocess
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

def determine_significance(mesa):
    averages=[]
    for files in sorted(mesa):
        d = np.loadtxt(files)
        averages.append(np.average(d))

    # FIXME: support more than 2
    assert(len(averages) == 2)
    diff = np.diff(averages)
    averages.append(diff)
    return np.round(averages, 3)

def run_column(string):
    p = subprocess.Popen(['column', '-t'], stdin=subprocess.PIPE)
    p.communicate(bytes(string, "utf-8"))

def do_the_numbers():
    benchmarks = defaultdict(list)
    mesas = set()
    for filename in os.listdir('.'):
        if '_' in filename:
            useless, benchmark_name, mesa_version = filename.split('_')
            benchmarks[benchmark_name].append(filename)
            mesas.add(mesa_version)

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


if __name__ == "__main__":
    run_column(do_the_numbers())
