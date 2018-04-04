#!/usr/bin/rdmd --shebang=-I../source -I. -w -debug

import std.stdio     : writeln;
import std.range     : iota;
import std.algorithm : map;
import std.array     : array;
import vest.range    : getItarable, expandNested;

interface iTest {
    int get() const;
}
class Test1 : iTest
{
    int i;
    this(int i) {this.i = i;}
    int get() const {return i*i;}
}
class Test2 : iTest
{
    int i;
    this(int i) {this.i = i;}
    int get() const {return i*i*i;}
}

void main()
{
    
    [
        [1,2].getItarable,
        iota(10, 16).getItarable,
    ]
    .expandNested.writeln;

    [
        [1.1,2.1].getItarable!float,
        iota(10, 16).getItarable!float,
    ]
    .expandNested.writeln;



    [
        [1,2,3]
            .map!(x => new Test1(x))
            .getItarable,
        [1,2,3]
            .map!(x => new Test1(x))
            .getItarable,
    ]
    .expandNested
    .map!(x => x.get)
    .writeln;


    [
        [1,2,3]
            .map!(x => new Test1(x))
            .getItarable!iTest,
        [1,2,3]
            .map!(x => new Test2(x))
            .getItarable!iTest,
    ]
    .expandNested
    .map!(x => x.get)
    .writeln;

}
