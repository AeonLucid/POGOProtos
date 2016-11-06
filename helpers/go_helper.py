#!/usr/bin/env python


def convert_to_go_package(pkg):
    pkg = pkg.replace("POGOProtos.", "")
    pkg = pkg.replace(".", "_").lower()
    if pkg == "map":
        pkg = "maps"

    return pkg