#!/usr/bin/rdmd --shebang=-I../source -I.

import std.stdio     : writeln;
import std.algorithm : map;
import std.json      : parseJSON;
import std.array     : array;
import vest.json     : checkNull, numeric;

void main()
{

    auto js = parseJSON(`[-1,1,0.5,-0.5]`);
    js.toPrettyString.writeln;

    js.array.map!(x => x.numeric).array.writeln;

    parseJSON(`0.5`).numeric.writeln;
    
    parseJSON(`{"a":5,"b":null}`).checkNull("a").writeln;
    parseJSON(`{"a":5,"b":null}`).checkNull("b").writeln;
    parseJSON(`{"a":5,"b":null}`).checkNull("c").writeln;
    writeln(*parseJSON(`{"a":5,"b":null}`).checkNull("a"));
}
