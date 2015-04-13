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

    This function will automatically use the independent t-test function if the
    values are of equal variance. If not, it will use the Welch t-test.
    # http://en.wikipedia.org/wiki/Student%27s_t-test#Independent_two-sample_t-test
    # http://en.wikipedia.org/wiki/Student%27s_t-test#Equal_or_unequal_sample_sizes.2C_unequal_variances
    TODO: paired t-test function in for evaluating test variability?
    # stats.ttest_rel(x, y)
    """

    t, p = stats.ttest_ind(mesa1, mesa2,
                           equal_var=is_equal_variance(mesa1, mesa2))

    # All of the above require a normal distribution of the data. If that is
    # false, or we cannot determine (due to limited sample size), make sure the
    # user knows.
    # FIXME: Is it possible to determine these things with fewer samples?
    bad_data = False
    try:
        k2, normal = stats.mstats.normaltest(mesa1)
        # FIXME: Unhardcode
        if (normal < NORMAL_CI):
            bad_data = True
        k2, normal = stats.mstats.normaltest(mesa2)
        if (normal < NORMAL_CI):
            bad_data = True
    except ValueError:
        bad_data = True

    return (p, bad_data)


def process_comparison(bench, mesa1, mesa2):
    p_value, flawed = determine_significance(mesa1['values'], mesa2['values'])
    row = Row(bench, mesa1['average'], mesa2['average'],
              mesa2['average'] - mesa1['average'],
              float("{0:.2f}".format(100 * (mesa2['average'] - mesa1['average']) / mesa1['average'])),
              p_value < CONFIDENCE_INTERVAL, flawed)
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
    names = ["Benchmark"] + list(mesas) + ["diff", '%diff', "significant", "flawed"]
    retrows.insert(0, Row._make(names))


def tuple_name(mesas):
    row_name = "name "
    i = 0
    for mesa in MESAS:
        row_name += "Mesa" + str(i) + " "
        i += 1
    row_name += "diff pdiff ttest flawed"
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
    parser.add_argument('-c', '--confidence', type=float, default=95,
                        help='Confidence interval used for determining \
                        significance of the t-test')
    parser.add_argument('-v', '--verbose', action="store_true",
                        help='Display all results, regardless of significance. \
                        (Equivalent to "-c 0")')
    args = parser.parse_args()

    CONFIDENCE_INTERVAL = 1-args.confidence/100

    if args.file1 and args.file2:
        mesa1 = parse_single(args.file1.name)
        mesa2 = parse_single(args.file2.name)
        print(process_comparison("NAME", mesa1, mesa2))
        exit(0)
    elif args.file1:
        print(stats.describe(np.loadtxt(args.file1,
                             dtype=np.dtype(np.float32))))
        exit(0)

    RETROWS = list()
    MESAS, BENCHMARKS, DATABASE = parse_results()
    Row = namedtuple('Row', tuple_name(MESAS))

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
