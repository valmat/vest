#!/usr/bin/rdmd --shebang=-I../source -I. -w -debug

import std.stdio     : writeln;
import std.range     : iota;
import std.algorithm : map;
import std.array     : array;
import vest.range    : expandNested, expandRecursively;

void main()
{
    iota(20, 25, 1)
        .map!(x => iota(21, x, 1))
        .expandNested()
        .writeln;

    iota(20, 25, 1)
        .map!(x => iota(19, x, 1))
        .expandNested
        .writeln;

    iota(20, 25, 1)
        .map!(x => iota(20, x, 1))
        .expandNested
        .writeln;

    iota(1, 6, 1)
        .map!(x => [1,2])
        .expandNested
        .writeln;

    [
        [1,2],
        [3,4],
        [5,6,7]
    ].expandNested.writeln;

    [
        [1,2],
        [],
        [],
        [3,4],
        [],
        [5,6,7]
    ].expandNested.writeln;

    [
        [1,2],
        [],
        [3,4],
        [5,6,7]
    ].expandNested.writeln;

    [
        [],
        [],
        [1,2],
        [],
        [],
        [3,4],
        [],
        [5,6,7],
        []
    ].expandNested.writeln;


    [
        [
            [1,2],
            [3,4],
        ],[
            [5,6,7],
            [8,9],
        ],[
            [],
            [],
            [],
            [10,11,12],
        ]
    ].expandNested.writeln;

    [
        [
            [1,2],
            [3,4],
        ],[
            [5,6,7],
            [8,9],
        ],[
            (int[]).init,
            [],
        ],[
        ],[
            [],
        ],[
            [],
            [],
            [],
            [10,11,12],
        ]
    ].expandNested.writeln;


    [
        [
            [1,2],
            [3,4],
        ],[
            [5,6,7],
            [8,9],
        ],[
            [],
            [],
            [],
            [10,11,12],
        ]
    ].expandNested.expandNested.writeln;

    [
        [],
        [
            [1,2],
            [3,4],
        ],[
            [5,6,7],
            [8,9],
        ],[
            (int[]).init,
            [],
        ],[
        ],[
            [],
        ],[
            [],
            [],
            [],
            [10,11,12],
            [],
        ],
        [],
    ].expandNested.expandNested.writeln;


    // Deep nesting
    [
        [
            [1,2],
            [3,4],
        ],[
            [5,6,7],
            [8,9],
        ],[
            [],
            [],
            [],
            [10,11],
        ]
    ].expandNested!2.writeln;

    [
        [
            [
                [1,2],
                [3,4],
            ],[
                [5,6,7],
                [8,9],
            ]
        ],[
            [
                [1,2],
                [3,4],
            ],[
                [5,6,7],
                [8,9],
            ]
        ]
    ].expandNested!3.writeln;

    

    // Yes you can concat strings. If you like ;)
    [
        ["hel"],
        ["low wor"],
        ["ld"],
    ].expandNested!2.writeln;

    
    // Expand nesting recursively
    [
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
    ].expandRecursively.writeln;

    [
        [
            [
                [1,2],
                [3,4],
            ],[
                [5,6,7],
                [8,9],
            ]
        ],[
            [
                [10,11],
                [],
                [12],
            ]
        ]
    ].expandRecursively.writeln;

    [[[[[[[[
        ["hellow"],
        [],
        ["world"],
    ]]]]]]]].expandRecursively.writeln;

}
