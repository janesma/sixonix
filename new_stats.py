#!/usr/bin/env python3
"""This scripts helps generate statistics from a benchmark run. The helper
functions may be used independently if desired."""

import os
import subprocess
import itertools
import math
import numpy as np
from scipy import stats
from scipy.stats import chi2
from collections import defaultdict
from collections import namedtuple


def chisquare_critical(confidence, df):
    # There must be a better way to get the critical value of chi-square.
    s = math.sqrt(chi2.ppf(confidence, 1))
    conf_int = chi2.cdf(s**2, 1)
    chi_squared = chi2.ppf(conf_int, df-1)
    return chi_squared

""" This uses the bartlett test to determine whether or not the values are of
equal variance. This test only holds for a normal distribution. The caller
should have checked this for us.
TODO: Implement Levene’s test for non-normal data"""
def is_equal_variance(mesa1, mesa2):
    # http://www.itl.nist.gov/div898/handbook/eda/section3/eda357.htm
    T, _p = stats.bartlett(mesa1, mesa2)
    # FIXME: is .95 always safe?
    x2 = chisquare_critical(.95, len(mesa1))
    return T <= x2

""" Returns a tuple of (significance, potentially incorrect data)"""
def determine_significance(mesa1, mesa2):
    # TODO: if the user wants to verify a test, or set of tests, they may use
    # the same mesa, for that you would want:
    # stats.ttest_rel(x, y)

    # equal sample size, and equal variance (Independent t-test). It appears
    # scipy supports unequal sample sizes implicitly
    # http://en.wikipedia.org/wiki/Student%27s_t-test#Independent_two-sample_t-test
    # unequal sample size or unequal variance (Welch)
    # http://en.wikipedia.org/wiki/Student%27s_t-test#Equal_or_unequal_sample_sizes.2C_unequal_variances
    t, p = stats.ttest_ind(mesa1, mesa2,
                           equal_var=is_equal_variance(mesa1, mesa2))

    # All of the above require a normal distribution of the data. If that is
    # false, or we cannot determine (due to limited sample size), make sure the
    # user knows.
    # FIXME: Is it possible to determine these things with few samples?
    bad_data = False
    try:
        k2, normal = stats.mstats.normaltest(mesa1)
        # FIXME: Unhardcode
        if (normal < 0.05):
            bad_data = True
        k2, normal = stats.mstats.normaltest(mesa2)
        if (normal < 0.05):
            bad_data = True
    except ValueError:
        bad_data = True

    return (p, bad_data)

def process_comparison(bench, mesa1, mesa2):
    p_value, flawed = determine_significance(mesa1['values'], mesa2['values'])
    row = Row(bench, mesa1['average'], mesa2['average'],
            mesa2['average'] - mesa1['average'],
            p_value < CONFIDENCE_INTERVAL,
            flawed)
    return row

def process(retrows, mesas, benchmarks, database):
    for bench in benchmarks:
        i = 0
        x = {}
        for mesa in mesas:
            cell = database[bench][mesa]
            x[i] = cell['values']
            i = i+1
        row = process_comparison(bench,
                database[bench][mesas[0]],
                database[bench][mesas[1]])
        retrows.append(row)

def parse_single(filename):
    useless, benchmark_name, mesa_version = filename.split('_')
    assert useless == "bench"
    vals = np.loadtxt(filename, dtype=np.dtype(np.float32))
    return { 'name': mesa_version,
            'bench': benchmark_name,
            'filename': filename,
            'values': vals,
            'average': np.average(vals),
            'stats': stats.describe(vals)}

def parse_results(retrows):
    database = defaultdict(defaultdict)
    mesas = list()
    benchmarks = list()
    for filename in os.listdir('.'):
        if '_' in filename:
            useless, benchmark_name, mesa_version = filename.split('_')
            database[benchmark_name][mesa_version] = parse_single(filename)
            mesas.append(mesa_version)
            benchmarks.append(benchmark_name)

    mesas = np.unique(mesas)
    benchmarks = np.unique(benchmarks)
    process(retrows, mesas, benchmarks, database)

    return (mesas, benchmarks, database)


def create_row0(retrows):
    temp_row = Row("Benchmark", "Mesa1", "Mesa2", "diff", "significant", "flawed")
    retrows.append(temp_row)

def run_column(string):
    p = subprocess.Popen(['column', '-t'], stdin=subprocess.PIPE)
    p.communicate(bytes(string, "utf-8"))


CONFIDENCE_INTERVAL = 0.05  # 5% CI
if __name__ == "__main__":
    Row = namedtuple('Row', 'name Mesa1 Mesa2 diff ttest flawed')
    RETROWS = list()
    create_row0(RETROWS)
    MESAS, BENCHMARKS, DATABASE = parse_results(RETROWS)
    # Only support two columns for doing statistics. We can try to fix this in
    # the future.
    assert(len(MESAS) == 2)

    for row in sorted(RETROWS):
        print(row)
