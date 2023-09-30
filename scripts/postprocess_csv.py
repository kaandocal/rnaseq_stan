# Utility to truncate Stan output files. Deletes all columns
# starting with `raw_`, used in the Stan models for convenience.
# Usage:
#     postprocess_csv.py <input.csv >output.csv
#
import sys
import csv

def filter_rows(row):
    if row.startswith("#"):
        print(row, end="")
        return False
    return True

def saverow(row, idcs, writer):
    row = [ row[i] for i in idcs ]
    writer.writerow(row)

it = filter(filter_rows, sys.stdin)

reader = csv.reader(it, delimiter=",")
writer = csv.writer(sys.stdout)

def col_filter(name):
    return not name.startswith("raw_")

for (line, row) in enumerate(reader):
    if line == 0:
        idcs = [ i for (i, col) in enumerate(row) if col_filter(col) ]
    saverow(row, idcs, writer)
    if line % 100 == 0:
        sys.stdout.flush()
