Generating Test Vectors
===

To generate the test vector testmult.txt, the programs [TestFloat](http://www.jhauser.us/arithmetic/TestFloat.html) and
[SoftFloat](http://www.jhauser.us/arithmetic/SoftFloat.html) were used. TestFloat/SoftFloat is considered the gold
standard for testing IEEE 754 floating point compatibility.

# How
Once you have TestFloat-3d and SoftFloat-3d, and have compiled both, simply use the executable `testfloat_gen` to
generate the vectors. For example, `testmult.txt` was generated like so:

```
./testfloat_gen f16_mul > testmult.txt
```

The output file format is officially described [here](http://www.jhauser.us/arithmetic/TestFloat-3/doc/testfloat_gen.html),
but to sum up the files look like this:

```
87FF E850 344F 01
 A    B    Y  FLAGS
```

For the flag bits:
    - bit 0 is the *inexact* flag
    - bit 1 is the *underflow* flag
    - bit 2 is the *overflow* flag
    - bit 3 is the *infinity* flag
    - bit 4 is the *nvalid* (i.e. NaN) flag

Note, in the test vector [testmult.txt](testmult.txt), the spaces have been replaced with underscores so
that the file can be read using `$readmemh` in SystemVerilog. Also, a leading hex value (0 or 1) has been added to
to represent the `clk_en` signal.