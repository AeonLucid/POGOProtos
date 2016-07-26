#!/usr/bin/env python

import argparse
import os
import shutil
import re

from helpers import compile_helper
from helpers import go_helper

from subprocess import call

# Add this to your path
protoc_path = "protoc"

# Specify desired language / output
parser = argparse.ArgumentParser()
parser.add_argument("-l", "--lang", help="Language to produce protoc files")
parser.add_argument("-o", "--out_path", help="Output path for protoc files")
parser.add_argument("-d", "--desc_file", action='store_true', help="For generating a .desc file only")
parser.add_argument("--go_import_prefix", help="Prefix all imports in output go files for vendoring all dependencies")
parser.add_argument("--go_package", help="The name of the exported go package")
parser.add_argument("--java_multiple_files", action='store_true', help="Write each message to a separate .java file.")
args = parser.parse_args()

# Set defaults
lang = args.lang or "csharp"
out_path = args.out_path or "out"
desc_file = args.desc_file
default_out_path = out_path == "out"
go_import_prefix = args.go_import_prefix
go_package = args.go_package or "protos"
java_multiple_files = args.java_multiple_files

# Determine where to store
proto_path = os.path.abspath("src")
tmp_path = os.path.abspath("tmp")
out_path = os.path.abspath(out_path)

# Clean up previous
if os.path.exists(tmp_path):
    shutil.rmtree(tmp_path)

if default_out_path and os.path.exists(out_path):
    shutil.rmtree(out_path)

# Create necessary directory
os.makedirs(tmp_path)

if not os.path.exists(out_path):
    os.makedirs(out_path)

created_packages = []
package_mappings = []

# Go specific
go_package_mappings = []

def get_package(path):
    for file_name in os.listdir(path):
        file_name_path = os.path.join(path, file_name)
        if os.path.isfile(file_name_path) and file_name.endswith('.proto'):
            with open(file_name_path, 'r') as proto_file:
                for proto_line in proto_file.readlines():
                    if proto_line.startswith("package"):
                        return re.search('package (.*?);', proto_line).group(1)
    return None

def walk_files(main_file, path, package, imports=None):
    if imports is None:
        imports = []

    if not desc_file and package == "POGOProtos":
        print("Can't compile..")
        print("File: '%s'" % path)
        print("Please place the file in 'src/POGOProtos/' in a sub-directory.")
        exit()

    main_file.write('syntax = "proto3";\n')

    short_package_name = str.split(package, '.')[-1].lower()

    main_file.write('package %s;\n\n' % package)

    if lang == "go":
        package = go_helper.convert_to_go_package(package)
        main_file.write('option go_package = "%s";\n' % go_package)

    if java_multiple_files:
        main_file.write('option java_multiple_files = true;\n')

    messages = ""

    for file_name in os.listdir(path):
        file_name_path = os.path.join(path, file_name)
        if file_name_path.endswith(".proto") and os.path.isfile(file_name_path):
            with open(file_name_path, 'r') as proto_file:
                is_header = True
                for proto_line in proto_file.readlines():
                    if proto_line.startswith("message") or proto_line.startswith("enum"):
                        is_header = False

                    if is_header:
                        if proto_line.startswith("import"):
                            import_from_package_re = re.search('import (public )?"(.*?)(\/)?([a-zA-Z0-9]+\.proto)";', proto_line)

                            if import_from_package_re is None:
                                print("Can't compile..")
                                print("File: '%s'" % file_name_path)
                                print("Bad import line: '%s'" % proto_line)
                                exit()

                            import_from_package = import_from_package_re.group(2).replace("/", ".")

                            if lang == "go":
                                import_from_package = go_helper.convert_to_go_package(import_from_package)

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
            if package is not None:
                if lang == "go":
                    file_name = go_helper.convert_to_go_package(package)
                    package_mappings.append([file_name, (file_name + ".proto")])
                else:
                    file_name = package
                    package_mappings.append([file_name, (file_name + ".proto")])

                package_file_path = os.path.join(tmp_path, file_name + ".proto")

                if lang == "go":
                    package_directory = os.path.dirname(package_file_path)
                    compile_helper.mkdir_p(package_directory)

                with open(package_file_path, 'a') as package_file:
                    walk_files(package_file, dir_name_path, package)
                    created_packages.append(package)

            walk_directory(dir_name_path)

def compile_go_package(path):

    proto_files = compile_helper.abslistdir(path)

    # Compile with the grpc plugin
    command_out_path = "plugins=grpc"

    # Allow to specify import_prefix for complete vendoring of dependencies
    if go_import_prefix:
        command_out_path += ",import_prefix=%s" % go_import_prefix

    # Combine the output with all other output options
    command_out_path = "%s:%s" % (command_out_path, os.path.abspath(out_path))

    command = """{0} --proto_path="{1}" --go_out={2} {3}""".format(
        protoc_path,
        tmp_path,
        command_out_path,
        proto_files
    )

    call(command, shell=True)

def compile_directories(path):
    for proto_file_name in os.listdir(path):
        command_out_path = os.path.abspath(out_path)
        item_path = os.path.join(path, proto_file_name)

        if os.path.isfile(item_path):

            command = """{0} --proto_path="{1}" --{2}_out="{3}" "{4}\"""".format(
                protoc_path,
                tmp_path,
                lang,
                command_out_path,
                item_path
            )

            call(command, shell=True)

        elif os.path.isdir(item_path):
            compile_directories(item_path)

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
    if lang == "go":
        compile_go_package(tmp_path)
    else:
        compile_directories(tmp_path)

    compile_helper.finish_compile(out_path, lang)

print("Done!")
