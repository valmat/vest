#!/usr/bin/rdmd --shebang=-I../source -I.

import std.stdio : writefln, writeln, stdout, stderr;

import std.json;
import std.array;// : array;
//import std.string;
import std.algorithm;
import std.meta;
import std.traits;
import std.conv : to;

import std.typecons;
import std.range;

import vest.json;// : toJson;


static struct SubNest {
    float q = 0.01;
    auto r1 = tuple(5);
    auto r2 = tuple!("r2")(55);
    
    float get_q() const
    {
        return q;
    }
private:
    int f = 1;
};

struct MyStruct
{
    int i      = 5;
    float pi   = 3.14;

    auto rng1 = iota(0, 3);
    auto rng2 = [1,2,3].map!( (int v) {return tuple(v, SubNest(0.5 * v));}  );
    //auto rng2 = [1,2,3].map!( (int v) {return SubNest(0.5 * v);}  );
    
    string str = "Hi";

    static int q = 55;
    enum r = 15;

    string[] strs = ["1", "2", "3"];


    static struct Nest {
        int x = 11;
        SubNest[] sns = [SubNest(0.1), SubNest(0.2)];
    };
    Nest nest;

    int * ptr1;
    int * ptr2;

    SubNest[string] dic;

    bool flag = true;
    char  c1 = 'e';
    dchar c2 = 'Ё';
    auto tpl1 = tuple(1,0.5,"%");
    auto tpl2 = tuple!("x", "y", "z")(2, 3, 4);
    Tuple!(int, "id", string, float, SubNest) tpl3 = tuple(2, "3", 4.0, SubNest(0.1));

    this(string a){}

    ~this(){}
    
    int get_i() const
    {
        return i;
    }
    float get_pi() const
    {
        return pi;
    }
    string get_str() const
    {
        return str;
    }
}


void main()
{
    MyStruct str;
    str.dic = [
        "one" : SubNest(1),
        "two" : SubNest(2),
    ];

    str.ptr2 = &str.i;

    str.writeln;
    str.toJson.toPrettyString.writeln;
    str.toJson.writeln;

    str.dic.toJson.toPrettyString.writeln;

}