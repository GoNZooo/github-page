#!/usr/bin/python2

import os

def all_ok(path):
    return os.access(path, os.F_OK) and \
            os.access(path, os.R_OK) and \
            os.access(path, os.W_OK) 

def make_file(path):
    tmp_file = open(path, "w")
    tmp_file.close()

def read_write_warn(file_name):
    print "'" + file_name + "'is not readable/writable. (Re)making."

directories = ["etags", "cache"]
file_names = ["email", "repos", "user", "events"]

etag_files = [("etags/" + file_name + ".etag") for file_name in file_names]
cache_files = [("cache/" + file_name + ".cache") for file_name in file_names]

if __name__ == "__main__":
    # Check for necessary token environment variable, used for
    # fetching data from GitHub specific to the user.
    if not os.getenv("GITHUB_REPO_TOKEN_LOC", False):
        print "Cannot find value for environment variable 'GITHUB_REPO_TOKEN_LOC'. This should be set."
    elif not os.access(os.getenv("GITHUB_REPO_TOKEN_LOC", False), os.R_OK):
        print "File that 'GITHUB_REPO_TOKEN_LOC' points to is not readable."

    # Check that necessary directories are present
    for directory in directories:
        if not os.path.isdir(directory):
            print "Directory '" + directory + "' does not exist. Creating."
            os.mkdir(directory)

    # Check for necessary etag files
    for etag_file in  etag_files:
        if not all_ok(etag_file):
            read_write_warn(etag_file)

            if os.access(etag_file, os.F_OK):
                os.remove(etag_file)
            make_file(etag_file)

    # Check for necessary cache files
    for cache_file in cache_files:
        if not all_ok(cache_file):
            read_write_warn(cache_file)
            
            if os.access(cache_file, os.F_OK):
                os.remove(cache_file)
            make_file(cache_file)

