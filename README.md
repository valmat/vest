# Dlang utils
Here I will keep my tools for the **D** programming language

- [tie](#tie)
- [clicolor](#clicolor)
- [tuplizer](#tuplizer)

## tie

May destructing variables for ranges and tuples

```d
import vest.utils   : tie;
import std.stdio    : writeln;
import std.typecons : tuple;

void main()
{
    // Traversable
    string a, b, c, d, e;
    tie(a,b,c,d,e) = ["foo1","foo2","foo3","foo4","foo5","foo6"];
    writeln([a,b,c,d,e]); //["foo1", "foo2", "foo3", "foo4", "foo5"]

    tie(a,b,c,d,e) = ["bar1","bar2"];
    writeln([a,b,c]); // ["bar1", "bar2", "foo3"]

    size_t i, j, k;
    tie(i,j,k) = [1,2];
    writeln([i,j,k]); // [1, 2, 0]
    assert([i,j,k] == [1, 2, size_t.init]);

    tie(i,j,k) = [50,60,70,80,90];
    writeln([i,j,k]); // [50, 60, 70]
    assert([i,j,k] == [50,60,70]);

    tie(i,j,k) = [-1, 3.14];
    writeln([i,j,k]); //[18446744073709551615, 3, 70]
    assert([i,j,k] == [size_t.max, 3, 70]);

    float pi;
    int l;
    tie(i,pi,l) = [3.14, 3.14, 3.14];
    writeln([i,pi,l]); // [3, 3.14, 3]
    assert(tuple(i,pi,l) == tuple(size_t(3), float(3.14), 3));

    tie(i,pi,l) = [size_t.max, size_t.max, size_t.max];
    writeln([i,pi,l]); [1.84467e+19, 1.84467e+19, -1]
    assert( tuple(i,pi,l) == tuple(size_t.max, float(size_t.max), cast(int) size_t.max ) );

    // Tuples
    int    x;
    string y;
    char   z;
    size_t u,v,w;

    tie(x,y,z) = tuple(1, " hello ", 'a', 777, 3.14);
    writeln(x,y,z); // 1 hello a

    tie(x, y, z) = tuple(15, " world ");
    writeln(x, y, z); // 15 world a
}
```
see [example](exmpls/test_tie.d)

## clicolor

Colorize console output

```d
import vest.utils.clicolors : c = color;
import std.stdio : writeln;
void main()
{
    writeln(
        c.b, c.red,
        "Lorem ipsum dolor sit amet, ",
        c.reset
    );
}
```
see [example](exmpls/test_clicolors.d)

## tuplizer
Tuplize multiple iterators.
It takes iterators and builds on them a new iterator from tuples of aggregated iterators.

```d
import vest.utils    : tuplizer;
import std.stdio     : writeln;
import std.typecons  : tuple, Tuple;
import std.range     : iota;
import std.array     : array;

void main()
{
    auto rf = iota(0.5, 0.0, -0.1); // 0.5, 0.4, 0.3, 0.2, 0.1
    auto ri = iota(50, 101, 10);    // 50,  60,  70,  80,  90,  100
    auto as = ["str1", "str2", "str3"];

    auto rt = tuplizer(ri, rf, as);

    writeln(rt);  // [Tuple!(int, double, string)(50, 0.5, "str1"), Tuple!(int, double, string)(60, 0.4, "str2"), Tuple!(int, double, string)(70, 0.3, "str3")]
    writeln(at.map!"a[2]".array); // ["str1", "str2", "str3"]
    writeln(at.map!"a[0]".array); // [50, 60, 70]
}
```

see [example](exmpls/test_tuplizer.d)

---
[The MIT License](LICENSE)
