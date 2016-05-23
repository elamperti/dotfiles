# Creating call graphs with Doxygen

To create call graphs from your C++ code, install Doxygen and GraphViz.


## Installing Doxygen
Clone the latest version of Doxygen:

```
git clone https://github.com/doxygen/doxygen.git --depth=1
```

Get the required packages `bison` and `flex`. Once you got them, compile Doxygen:

```
cd doxygen
mkdir build
cd build
cmake -G "Unix Makefiles" ..
make
```

The resulting binary will be in `doxygen/build/bin/doxygen`.


## Installing GraphViz
It should be as simple as `sudo apt-get graphviz`. Make sure `dotty` is in your PATH.


## Creating the call graph
Create a Doxygen configuration file (it doesn't matter where nor with what filename);
`doxygen -g [configfile.name]` may be called to generate a basic configuration file.

After that, make sure the following values are correct in your configuration file:

```
OPTIMIZE_OUTPUT_FOR_C  = YES
EXTRACT_ALL            = YES
EXTRACT_STATIC         = YES
# Set only the dirs you want
INPUT                  = src/ test/
RECURSIVE              = YES
SOURCE_BROWSER         = YES
HAVE_DOT               = YES
CALL_GRAPH             = YES
CALLER_GRAPH           = YES
```

Defining `DOT_NUM_THREADS` is optional but it will improve execution time.

---
Sources:
  * http://www.stack.nl/~dimitri/doxygen/download.html
  * https://github.com/neovim/neovim/wiki/Generate-callgraphs-with-Doxygen
