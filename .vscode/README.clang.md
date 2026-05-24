# Configuration on Windows

To make `clangd` work under windows, I had to create `%LOCALAPPDATA%\clangd\config.yaml`:
```yaml
# https://stackoverflow.com/a/78417866/10545609
If:
  PathMatch: .*\.[ch]
CompileFlags:
  Compiler: x86_64-w64-mingw32-gcc
  Add:
    - "-IC:/Users/johlet/Develop/llvm-mingw-ucrt/include"
---
If:
  PathMatch: .*\.[ch]pp
CompileFlags:
  Compiler: x86_64-w64-mingw32-g++
  Add:
    - "-IC:/Users/johlet/Develop/llvm-mingw-ucrt/include/c++/v1"
    - "-IC:/Users/johlet/Develop/llvm-mingw-ucrt/include"
---
If:
  PathMatch: .*\.in
Index:
  Background: Skip
```