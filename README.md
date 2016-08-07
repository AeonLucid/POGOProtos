POGOProtos
===================

[![Build Status](https://travis-ci.org/AeonLucid/POGOProtos.svg?branch=master)](https://travis-ci.org/AeonLucid/POGOProtos)

This repository contains the [ProtoBuf](https://github.com/google/protobuf) `.proto` files needed to decode the PokémonGo RPC.

If you want to know which messages are implemented right now, click [here](https://github.com/AeonLucid/POGOProtos/blob/master/src/POGOProtos/Networking/Requests/RequestType.proto).

# Usage

## Versions

Since this is under such heavy development
we release a new stable version every so often.
If you don't want your depending code to break,
check out Releases.
The current latest version is `v1.0`
but if you don't care about breaking changes,
feel free to use `master`.

## Preparation

Current recommended protoc version: "Protocol Buffers v3.0.0-beta-4".

You can find download links [here](https://github.com/google/protobuf/releases).

### Windows
Be sure to add `protoc` to your environmental path.

### *nix
Ensure that you have the newest version of `protoc` installed.

### OS X
Use `homebrew` to install `protobuf ` with `brew install --devel protobuf`.

## Compilation
There are three ways to compile **POGOProtos**.

### Pretty compilation (Recommended)
Pretty compilation creates output specifically for the target language, 
i.e. respecting naming contentions, etc.
This is an example of how the generated code will be organized:

`python compile_pretty.py cpp`:
 - `POGOProtos/Data/PlayerData.proto` -> `POGOProtos/Data/PlayerData.pb.cpp`

`python compile_pretty.py csharp`:
 - `POGOProtos/Data/PlayerData.proto` -> `POGOProtos/Data/PlayerData.g.cs`
 
`python compile_pretty.py go`:
 - `POGOProtos/Data/*.proto` -> `github.com/aeonlucid/pogoprotos/data`
 - `POGOProtos/Data/PlayerData.proto` -> `github.com/aeonlucid/pogoprotos/data/player_data.pb.go`

`python compile_pretty.py java`:
 - `POGOProtos/Data/*.proto` -> `com/github/aeonlucid/pogoprotos/Data.java`
 
`python compile_pretty.py js`:
 - `POGOProtos/**/*.proto` -> `pogoprotos.js`

`python compile_pretty.py objc`:
 - `POGOProtos/Data/PlayerData.proto` -> `POGOProtos/Data/PlayerData.pbobjc.m`
 
`python compile_pretty.py python`:
 - `POGOProtos/Data/*.proto` -> `pogoprotos/data/__init__.py`
 - `POGOProtos/Data/PlayerData.proto` -> `pogoprotos/data/player_data_pb2.py`

`python compile_pretty.py ruby`:
 - `POGOProtos/Data/*.proto` -> `pogoprotos/data.rb`
 - `POGOProtos/Data/PlayerData.proto` -> `pogoprotos/data/player_data.rb`

#### Command

Run `python compile_pretty.py --help` for help.

### Single file compilation
Single file compilation merges every directory to it's own `.proto` file.
As an example:

 - Networking/Requests/Messages/*.proto
 - Networking/Responses/*.proto

Becomes:

 - POGOProtos.**Networking.Requests.Messages.proto**
 - POGOProtos.**Networking.Responses.proto**

These new files are then compiled by `protoc` and placed in the output directory. This greatly reduces the amount of output files.

#### Command

Run `python compile_single.py` to compile everything to a single file.

#### Flags

 - Add the `-l` or `--language` flag to compile to whatever language you need, the default is C#.
 - Add the `-o` or `--output` flag to set an output directory, the default is `out`.
 - Add the `-d` or `--desc_file` flag to only generate a descriptor file, `POGOProtos.desc` will be written to the specified output directory.

##### Go
 - Add the `--go_import_prefix` to prefix all imports in output go files for vendoring all dependencies
 - Add the `--go_package` to specify the name of the exported go package

### Recursive compilation

Recursive compilation loops through all directories and compiles every `.proto` file it finds to the specified output directory.

#### Command

Run `python compile.py` to recursively compile everything.

#### Flags

 - Add the `-l` or `--language` flag to compile to whatever language you need, the default is C#.
 - Add the `-o` or `--output` flag to set an output directory, the default is `out`.

### Extra information
You can find all available languages here [https://github.com/google/protobuf](https://github.com/google/protobuf).

# Libraries

If you don't want to compile POGOProtos but instead use it directly, check out the following repository.

*More will be added later when most proto files are added.*

| Language         | Source                                                  |
|------------------|---------------------------------------------------------|
| NodeJS           | https://github.com/rastapasta/node-pokemongo-protobuf   |
| NodeJS (pure JS) | https://github.com/cyraxx/node-pogo-protos              |
| .NET             | https://github.com/johnduhart/POGOProtos-dotnet         |
| PHP              | https://github.com/jaspervdm/pogoprotos-php             |
| Go               | https://github.com/pkmngo-odi/pogo-protos               |
| Haskell          | https://github.com/relrod/pokemon-go-protobuf-types     |
| Rust             | https://github.com/rockneurotiko/pokemon-go-protobuf-rs |
