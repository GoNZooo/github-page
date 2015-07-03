#!/usr/bin/python2

import os

directories = ["etags", "cache"]

if __name__ == "__main__":
    # Check for necessary token environment variable, used for
    # fetching data from GitHub specific to the user.
    if not os.getenv("GITHUB_REPO_TOKEN_LOC", False):
        print "Cannot find value for environment variable" + \
                "'GITHUB_REPO_TOKEN_LOC'. This should be set."
    elif not os.access(os.getenv("GITHUB_REPO_TOKEN_LOC", False), os.R_OK):
        print "File that 'GITHUB_REPO_TOKEN_LOC' points to is not readable."

    # Check that necessary directories are present
    for directory in directories:
        if not os.path.isdir(directory):
            print "Directory '" + directory + "' does not exist. Creating."
            os.mkdir(directory)

