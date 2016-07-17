POGOProtos
===================

This repository contains the [ProtoBuf](https://github.com/google/protobuf) `.proto` files needed to decode the PokémonGo RPC.

# Use
## Preparation
### Windows
Be sure to add te newest version of `protoc` to your environmental path.

### *nix
Ensure that you have the newest version of `protoc` installed.

### OS X
Use `homebrew` to install `protobuf ` with `brew install --devel protobuf`

## Compilation
To compile, run `python compile.py` to recursively compile everything.

# Flags

 - Add the `-l` or `--language` flag to compile to whatever language you need, the default is C#.
 - Add the `-o` or `--output` flag to set an output directory, the deafult is `out`.
