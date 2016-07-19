#!/usr/bin/env python

import argparse
import os
import shutil
import re
from subprocess import call

# Add this to your path
protoc_path = "protoc"

# Specify desired language / output
parser = argparse.ArgumentParser()
parser.add_argument("-l", "--lang", help="Language to produce protoc files")
parser.add_argument("-o", "--out_path", help="Output path for protoc files")
parser.add_argument("-d", "--desc_file", action='store_true', help="For generating a .desc file only")
args = parser.parse_args()

# Set defaults
lang = args.lang or "csharp"
out_path = args.out_path or "out"
desc_file = args.desc_file
default_out_path = out_path == "out"

# Determine where to store
proto_path = os.path.abspath("pogo")
tmp_path = os.path.abspath("tmp")
out_path = os.path.abspath(out_path)

# Clean up previous
if os.path.exists(tmp_path):
    shutil.rmtree(tmp_path)

if default_out_path and os.path.exists(out_path):
    shutil.rmtree(out_path)

# Create necessary directory
os.makedirs(tmp_path)
os.makedirs(out_path)

created_packages = []


def get_package(path):
    for file_name in os.listdir(path):
        file_name_path = os.path.join(path, file_name)
        if os.path.isfile(file_name_path) and file_name.endswith('.proto'):
            with open(file_name_path, 'r') as proto_file:
                for proto_line in proto_file.readlines():
                    if proto_line.startswith("package"):
                        return re.search('package (.*?);', proto_line).group(1)


def walk_files(main_file, path, package, imports=None):
    if imports is None:
        imports = []

    main_file.write('syntax = "proto3";\n')
    main_file.write('package %s;\n\n' % package)

    messages = ""

    for file_name in os.listdir(path):
        file_name_path = os.path.join(path, file_name)
        if os.path.isfile(file_name_path):
            with open(file_name_path, 'r') as proto_file:
                is_header = True
                for proto_line in proto_file.readlines():
                    if proto_line.startswith("message") or proto_line.startswith("enum"):
                        is_header = False

                    if is_header:
                        if proto_line.startswith("import"):
                            import_from_package = re.search('import (public )?"(.*?)(\/)?([a-zA-Z]+\.proto)";',
                                                            proto_line).group(2).replace("/", ".")

                            if import_from_package == "":
                                import_from_package = "POGOProtos"

                            if not import_from_package == "POGOProtos":
                                import_from_package = "POGOProtos." + import_from_package

                            if import_from_package not in imports:
                                imports.append(import_from_package)

                    if not is_header:
                        messages += proto_line

                        if proto_line == "}":
                            messages += "\n"

    for package_import in imports:
        if package_import != package:
            main_file.write('import public "%s.proto";\n' % package_import)

    if len(imports) is not 0:
        main_file.write('\n')

    main_file.writelines(messages)


def walk_directory(path):
    for dir_name in os.listdir(path):
        dir_name_path = os.path.join(path, dir_name)
        if os.path.isdir(dir_name_path):
            package = get_package(dir_name_path)
            package_file_path = os.path.join(tmp_path, package + ".proto")

            with open(package_file_path, 'a') as package_file:
                walk_files(package_file, dir_name_path, package)
                created_packages.append(package)

            walk_directory(dir_name_path)

walk_directory(proto_path)

# Compile =)
if desc_file:
    root_package_file_path = os.path.join(tmp_path, "POGOProtos.proto")
    with open(root_package_file_path, 'a') as root_package_file:
        walk_files(root_package_file, proto_path, "POGOProtos", created_packages)

    command = """{0} --include_imports --proto_path="{1}" --descriptor_set_out="{2}" "{3}\"""".format(
        protoc_path,
        tmp_path,
        os.path.abspath(out_path + "/POGOProtos.desc"),
        os.path.join(tmp_path, "POGOProtos.proto")
    )

    call(command, shell=True)
else:
    for proto_file_name in os.listdir(tmp_path):
        proto_file_name_path = os.path.join(tmp_path, proto_file_name)
        if os.path.isfile(proto_file_name_path):
            command = """{0} --proto_path="{1}" --{2}_out="{3}" "{4}\"""".format(
                protoc_path,
                tmp_path,
                lang,
                out_path,
                proto_file_name_path
            )

            call(command, shell=True)


print("Done!")
