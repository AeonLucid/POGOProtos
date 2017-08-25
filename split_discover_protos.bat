mode con: cols=200 lines=60
Powershell.exe -File split_discover_protos.ps1 -SourceFolder "%cd%\src\POGOProtos" -ProtoIndexFile "%cd%\proto_index.txt" -ProtoTypeFile "%cd%\proto_types.txt" -ProtoImportFile "%cd%\proto_import.txt"  > output.txt
pause