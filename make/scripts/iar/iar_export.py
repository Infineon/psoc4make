#!/usr/bin/env python3

import os
import os.path
import sys

import iar_export_core

def main():
    try:
        iar_export_core.run_export(False)
    except Exception as error:
        print("ERROR: %s" % error)
        sys.exit(1)

if __name__ == '__main__':
    main()
