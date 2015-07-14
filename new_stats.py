#!/usr/bin/env python3
"""This scripts helps generate statistics from a benchmark run. The helper
functions may be used independently if desired."""

import argparse
import csv
import io
import itertools
import math
import numpy as np
import os
import subprocess
#import sys
from collections import defaultdict
from collections import namedtuple
from enum import Enum
from scipy import stats
from scipy.stats import chi2

BARTLETT_CI = 0.95  # Does this need to be parameterized?
NORMAL_CI = 1-0.95  # Same


def chisquare_critical(confidence, df):
    # There must be a better way to get the critical value of chi-square.
    s = math.sqrt(chi2.ppf(confidence, 1))
    conf_int = chi2.cdf(s**2, 1)
    chi_squared = chi2.ppf(conf_int, df-1)
    return chi_squared


def is_equal_variance(mesa1, mesa2):
    """ Determine if two sets of values have equal variance.

    This uses the Bartlett test to determine whether or not the values are of
    equal variance. This test only holds for a normal distribution. The caller
    should have checked this for us.
    TODO: Implement Levene’s test for non-normally distributed data
    """
    # http://www.itl.nist.gov/div898/handbook/eda/section3/eda357.htm
    T, _p = stats.bartlett(mesa1, mesa2)
    x2 = chisquare_critical(BARTLETT_CI, len(mesa1))
    return T <= x2


def determine_significance(mesa1, mesa2):
    """ Determines if two sets of values are statistically significant.

    In the best case, we can determine a normal distribution, and equal
    variance. Once determined we can use the independent t-test function if the
    values are of equal variance.  If we have normal data, but the variance is unequal, the welch t-test is
    used.
    http://en.wikipedia.org/wiki/Student%27s_t-test#Independent_two-sample_t-test
    http://en.wikipedia.org/wiki/Student%27s_t-test#Equal_or_unequal_sample_sizes.2C_unequal_variances

    In the case where we cannot determine normality the mann-whitney u-test is
    desired to be used, but this test is only effective when there are greater
    than 20 samples.
    http://en.wikipedia.org/wiki/Mann%E2%80%93Whitney_U_test
    """
    # FIXME: Is it possible to determine these things with fewer samples?
    Distribution = Enum('Distribution', 'Normal, Non_normal Unknown')
    normality = Distribution.Normal
    try:
        k2, normal = stats.normaltest(mesa1)
        # FIXME: Unhardcode
        if (normal < NORMAL_CI):
            normality = Distribution.Non_normal

        k2, normal = stats.normaltest(mesa2)
        if (normal < NORMAL_CI):
            normality = Distribution.Non_normal
    except ValueError:
        normality = Distribution.Unkown

    equal_variance = is_equal_variance(mesa1, mesa2)

    if args.ttest:
        t, p = stats.ttest_ind(mesa1, mesa2, equal_var=equal_variance)
        return (p, normality == Distribution.Normal, "t-test" if equal_variance else "Welch's")
    elif args.mannwhitney:
        u, p = stats.mannwhitneyu(mesa1, mesa2)
        p *= 2 # We want a 2-tailed p-value
        return (p, len(mesa1) < 20 or len(mesa2) < 20, "Mann-Whitney")

    if normality == Distribution.Normal:
        t, p = stats.ttest_ind(mesa1, mesa2, equal_var=equal_variance)
        return (p, False, "t-test" if equal_variance else "Welch's")
    else:
        u, p = stats.mannwhitneyu(mesa1, mesa2)
        p *= 2 # We want a 2-tailed p-value
        flawed = len(mesa1) < 20 or len(mesa2) < 20
        return (p, flawed, "Mann-Whitney")


def process_comparison(bench, mesa1, mesa2):
    p_value, flawed, test_name = determine_significance(mesa1['values'], mesa2['values'])
    row = Row(bench, mesa1['average'], mesa2['average'],
              mesa2['average'] - mesa1['average'],
              float("{0:.2f}".format(100 * (mesa2['average'] - mesa1['average']) / mesa1['average'])),
              p_value < CONFIDENCE_INTERVAL, flawed, test_name)
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
        if args.verbose or row.ttest and not row.flawed:
            retrows.append(row)


def parse_single(filename):
    useless, benchmark_name, mesa_version = filename.split('_')
    assert useless == "bench"
    vals = np.loadtxt(filename, dtype=np.dtype(np.float32))
    return {'name': mesa_version,
            'bench': benchmark_name,
            'filename': filename,
            'values': vals,
            'average': np.average(vals),
            'stats': stats.describe(vals)}


def parse_results():
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

    return (mesas, benchmarks, database)


def create_row0(retrows, mesas):
    names = ["Benchmark"] + list(mesas) + ["diff", '%diff', "significant", "flawed", "test"]
    retrows.insert(0, Row._make(names))


def tuple_name(mesas):
    row_name = "name "
    i = 0
    for mesa in MESAS:
        row_name += "Mesa" + str(i) + " "
        i += 1
    row_name += "diff pdiff ttest flawed test"
    return row_name


def run_column(string):
    p = subprocess.Popen(['column', '-t'], stdin=subprocess.PIPE)
    p.communicate(bytes(string, "utf-8"))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
            description="Process benchmark data. By default it will take the \
                         properly named files from the sixonix runner and \
                         generate a table with statistical data. The data \
                         displayed is determined to be both from a normal \
                         distribution and significantly different. \
                         If files are specified, it will run in a \
                         ministat-like.")
    parser.add_argument('file1', nargs='?', type=argparse.FileType('r'),
                        help='The first file to be compared')
    parser.add_argument('file2', nargs='?', type=argparse.FileType('r'),
                        help='The second file to be compared')
    parser.add_argument('-i', '--interactive', action="store_true",
                        help='Bring up interactive mode')
    parser.add_argument('-o', '--output', type=argparse.FileType('w'),
                        help='Direct results to a CSV file')
    parser.add_argument('-m', '--mannwhitney', action="store_true",
                        help='Force the use of mann-whiteney u-test')
    parser.add_argument('-t', '--ttest', action="store_true",
                        help='Force the use of student t-test')
    parser.add_argument('-c', '--confidence', type=float, default=95,
                        help='Confidence interval used for determining \
                        significance of the t-test')
    parser.add_argument('-v', '--verbose', action="store_true",
                        help='Display all results, regardless of significance. \
                        (Equivalent to "-c 0")')
    args = parser.parse_args()

    CONFIDENCE_INTERVAL = 1-args.confidence/100

    RETROWS = list()
    MESAS, BENCHMARKS, DATABASE = parse_results()
    Row = namedtuple('Row', tuple_name(MESAS))

    if args.file1 and args.file2:
        mesa1 = parse_single(args.file1.name)
        mesa2 = parse_single(args.file2.name)
        print(process_comparison("NAME", mesa1, mesa2))
        exit(0)
    elif args.file1:
        print(stats.describe(np.loadtxt(args.file1,
                             dtype=np.dtype(np.float32))))
        exit(0)


    process(RETROWS, MESAS, BENCHMARKS, DATABASE)
    create_row0(RETROWS, MESAS)

    if args.output:
            c_writer = csv.writer(args.output, delimiter=',',  quotechar='|', quoting=csv.QUOTE_MINIMAL)
            c_writer.writerows(RETROWS)
    else:
            output = io.StringIO()
            c_writer = csv.writer(output, delimiter=' ',  quotechar='|', quoting=csv.QUOTE_MINIMAL)
            # Uncomment the below to dump the raw csv
            #c_writer = csv.writer(sys.stdout, delimiter=' ',  quotechar='|', quoting=csv.QUOTE_MINIMAL)
            c_writer.writerows(RETROWS)
            run_column(output.getvalue())
            output.close()
