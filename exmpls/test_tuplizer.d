#!/usr/bin/rdmd --shebang=-I../source -I.

import vest.utils    : tuplizer;
import std.stdio     : writeln;
import std.typecons  : tuple, Tuple;
import std.range     : iota;
import std.array     : array;
import std.algorithm : map, equal;

void main()
{
    auto rf = iota(0.5, 0.0, -0.1); // 0.5, 0.4, 0.3, 0.2, 0.1
    auto ri = iota(50, 101, 10);    // 50,  60,  70,  80,  90,  100
    auto as = ["str1", "str2", "str3"];
    
    writeln(rf);
    writeln(ri);
    writeln(as);

    auto rt = tuplizer(ri, rf, as);
    Tuple!(int, double, string)[] at = [
        tuple(50, 0.5, "str1"),
        tuple(60, 0.4, "str2"),
        tuple(70, 0.3, "str3")
    ];

    assert( rt.equal(at));

    writeln(rt);
    writeln(at);
    
    writeln(at.map!"a[2]".array);
    assert(at.map!"a[2]".equal(as));

    writeln(at.map!"a[0]".array, ri.array[0..3]);
    assert(at.map!"a[0]".equal(ri.array[0..3]) );
}