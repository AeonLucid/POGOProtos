#!/usr/bin/env python

import argparse
import fnmatch
import ntpath
import sys
import os
import shutil
from subprocess import call


def query_yes_no(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.

    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
        It must be "yes" (the default), "no" or None (meaning
        an answer is required of the user).

    The "answer" return value is True for "yes" or False for "no".
    """
    valid = {"yes": True, "y": True, "ye": True,
             "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = raw_input().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' "
                             "(or 'y' or 'n').\n")


# Add this to your path
protoc_path = "protoc"

# Specify desired language / output
parser = argparse.ArgumentParser()
parser.add_argument("-l", "--lang", help="Language to produce protoc files")
parser.add_argument("-o", "--out_path", help="Output path for protoc files")
args = parser.parse_args()

# Set defaults
lang = args.lang or "csharp"
out_path = args.out_path or "out"
default_out_path = out_path == "out"

# Determine where to store
proj_root = os.path.abspath("../")
proto_path = os.path.abspath("pogo/")
out_path = os.path.abspath(out_path)

if not default_out_path:
    print 'Can we remove "%s"?' % out_path
    may_remove = query_yes_no("Please answer.", default="no")
else:
    may_remove = True

if may_remove and os.path.exists(out_path):
    shutil.rmtree(out_path)

# Find protofiles and compile
for root, dirnames, filenames in os.walk(proto_path):
    protos = fnmatch.filter(filenames, '*.proto')
    relative_out_path = None
    for filename in protos:
        relative_out_path = None

        proto_file = os.path.join(root, filename)
        relative_file_path = proto_file.replace(proto_path, "")
        relative_path = relative_file_path.replace(ntpath.basename(proto_file), "")

        if lang == "csharp":
            destination_path = os.path.abspath(out_path + relative_path)
        else:
            destination_path = os.path.abspath(out_path)

        if relative_out_path is None:
            relative_out_path = os.path.abspath(out_path + relative_path)

        if not os.path.exists(destination_path):
            os.makedirs(destination_path)

        print("Compiling " + relative_file_path + "..")

        command = """{0} --proto_path="{1}" --{2}_out="{3}" "{4}\"""".format(
            protoc_path,
            proto_path,
            lang,
            destination_path,
            os.path.abspath(proto_file)
        )

        print destination_path

        call(command, shell=True)

if lang == 'python':
    for root, dirnames, filenames in os.walk(out_path):
        open(os.path.join(root, '__init__.py'), 'w').close()

print("Done!")
