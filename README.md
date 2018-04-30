# Vest

[![Dub version](https://img.shields.io/dub/v/vest.svg)](https://code.dlang.org/packages/vest/~master)
[![License](https://img.shields.io/dub/l/vest.svg)](https://code.dlang.org/packages/vest/)
[![Build Status](https://travis-ci.org/valmat/vest.svg?branch=master)](https://travis-ci.org/valmat/vest)


Tools for the **D** programming language

- [tie](#tie)
- [cli colors](#clicolor)
- [expand nested ranges](#expandnested)
- [tuplizer](#tuplizer)
- [toJson](#tojson)

## tie

May destructing variables for ranges and tuples

```D
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

```D
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


```D
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

```D
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

## toJson

`toJson` converts structures, tuples, arrays, pointers etc to json recursively.

```D
import std.stdio     : writeln;
import std.algorithm : map;
import std.typecons  : tuple, Tuple;
import std.range     : iota;
import vest.json     : toJson;


static struct SubNest {
    int  s = 5;
    float get_s() const {return s;}
};

struct MyStruct
{
    static int q = 55;
    enum r = 15;

    int i      = 5;
    auto rng1 = iota(0, 3);
    auto rng2 = iota(4, 6).map!( (int v) {return tuple(v, SubNest(5 * v));}  );
    string str = "Hi";
    string[] strs = ["1", "2", "3"];

    static struct Nest {
        int x = 11;
        SubNest[] sns = [SubNest(1), SubNest(2)];
    };
    Nest nest;

    int * ptr1;
    int * ptr2;

    SubNest[string] dic;

    bool flag = true;

    auto tpl1 = tuple(80,"%");
    auto tpl2 = tuple!("x", "y", "z")(2, 3, 4);

    this(string a){}
    ~this(){}
    int get_i() const {return i;}
}


void main()
{
    MyStruct mstr;
    mstr.dic = [
        "one" : SubNest(1),
        "two" : SubNest(2),
    ];
    mstr.ptr2 = &str.i;

    mstr.toJson.toPrettyString.writeln;
}
```
Output equal to:
```json
{
    "dic": {
        "one": {"s": 1},"two": {"s": 2}
    },
    "flag": true,
    "i": 5,
    "nest": {
        "sns": [{"s": 1},{"s": 2}],
        "x": 11
    },
    "ptr1": null,
    "ptr2": 5,
    "q": 55,
    "r": 15,
    "rng1": [0,1,2],
    "rng2": [[4, {"s": 20}], [5, {"s": 25}]],
    "str": "Hi",
    "strs": ["1","2","3"],
    "tpl1": [80,"%"],
    "tpl2": {"x": 2, "y": 3, "z": 4}
}
```


---
[The MIT License](LICENSE)
