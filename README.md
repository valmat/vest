# Dlang utils
Here I will keep my tools for the **D** programming language

- [tie](#tie)
- [cli colors](#clicolor)
- [expand nested ranges](#expandnested)
- [tuplizer](#tuplizer)

## tie

May destructing variables for ranges and tuples

```d
import vest.utils   : tie;
import std.stdio    : writeln;
import std.typecons : tuple;
import std.range    : iota;

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

    tie(i,j,k) = iota(50, 91, 10); // 50,60,70,80,90
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
see [example](exmpls/tie.d)

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
see [example](exmpls/clicolors.d)


## expandNested
Expand nested ranges.


```d
import std.range     : iota;
import std.algorithm : map;
import std.array     : array;
import vest.range    : expandNested, expandRecursively;

void main()
{
  assert(iota(20, 25, 1)
      .map!(x => iota(19, x, 1))
      .expandNested
      .array == [19, 19, 20, 19, 20, 21, 19, 20, 21, 22, 19, 20, 21, 22, 23]);

  assert(iota(1, 6, 1)
      .map!(x => [1,2])
      .expandNested
      .array == [1, 2, 1, 2, 1, 2, 1, 2, 1, 2]);

  assert([
          [1,2],
          [3,4],
          [5,6,7]
      ].expandNested
      .array == [1, 2, 3, 4, 5, 6, 7]);

  assert([
          [],
          [1,2],
          [],
          [],
          [3,4],
          [],
          [5,6,7]
      ].expandNested
      .array == [1, 2, 3, 4, 5, 6, 7]);

  assert([
          [
              [1,2],
              [3,4],
          ],[
              [5,6,7],
              [8,9],
          ],[
              [],
              [10,11,12],
          ]
      ].expandNested.expandNested
      .array == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);

  // Deep nesting
  // expandNested!deep allow apply expandNested multiple times
  assert([
          [
              [1,2],
              [3,4],
          ],[
              [5,6,7],
              [8,9],
          ],[
              [],
              [10,11],
          ]
      ].expandNested!2
      .array == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);

  assert([
          [
              [
                  [1,2],
              ],[
                  [3,4],
              ]
          ]
      ].expandNested!3
      .array == [1, 2, 3, 4]);

  // Expand nesting recursively
  assert([
          [
              [1,2],
              [3,4],
          ],[
              [5,6,7],
              [8,9],
          ],[
              [],
              [],
              [10,11],
          ]
      ].expandRecursively
      .array == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] );

  assert([
          [
              [
                  [1,2],
                  [3,4],
              ],[
                  [5,6,7],
              ]
          ],[
              [
                  [8,9],
              ]
          ]
      ].expandRecursively
      .array == [1, 2, 3, 4, 5, 6, 7, 8, 9] );

  assert([[[[[[[[
          ["hellow"],
          [],
          ["world"],
      ]]]]]]]].expandRecursively
      .array == ["hellow", "world"] );
}
```

see [example](exmpls/expand_nested.d)


## tuplizer
Tuplize multiple iterators.
It takes iterators and builds on them a new iterator from tuples of aggregated iterators.

```d
import vest         : tuplizer;
import std.stdio    : writeln;
import std.typecons : tuple, Tuple;
import std.range    : iota;
import std.array    : array;

void main()
{
    auto rf = iota(0.5, 0.0, -0.1); // 0.5, 0.4, 0.3, 0.2, 0.1
    auto ri = iota(50, 101, 10);    // 50,  60,  70,  80,  90,  100
    auto as = ["str1", "str2", "str3"];

    auto rt = tuplizer(ri, rf, as);

    writeln(rt);  // [Tuple!(int, double, string)(50, 0.5, "str1"), Tuple!(int, double, string)(60, 0.4, "str2"), Tuple!(int, double, string)(70, 0.3, "str3")]
    writeln(rt.map!"a[2]".array); // ["str1", "str2", "str3"]
    writeln(rt.map!"a[0]".array); // [50, 60, 70]
}
```

see [example](exmpls/uplizer.d)

---
[The MIT License](LICENSE)
