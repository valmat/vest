module vest.range.expand_nested;

import std.range      : empty, popFront, front, isInputRange, ElementType;
import std.functional : forward;
import std.traits     : isNarrowString, Unqual;

// Recursive expands nested iterators
auto expandNested(size_t depth = 1, Range)(auto ref Range range)
    if (isInputRange!Range)
{
    static if(depth > 1) {
        return expandNested!(depth - 1)( Expander!Range(forward!range) );
    } else {
        return Expander!Range(forward!range);
    }
}

auto expandRecursively(Range)(auto ref Range range)
    if (isInputRange!Range)
{
    alias nested_t = ElementType!Range;

    static if(isInputRange!nested_t && !isNarrowString!nested_t)
    {
        return expandRecursively( Expander!Range(forward!range) );
    } else {
        return range;
    }
}

private struct Expander(Range)
{
private:
    alias nested_t = Unqual!(typeof(Range.init.front));
    Range range;
    nested_t nested;
public:

    this(Range range)
    {
        this.range = range;
        if(!range.empty) {
            nested = range.front;
        } else {
            // if range is empty initialize nested by default
            nested = typeof(range.front).init;
        }
    }

    @property
    bool empty()
    {
        if(range.empty()) {
            return true;
        }

        // Until as the nested iterator is empty,
        // go to the next non-empty nested iterator
        while(nested.empty) {
            range.popFront();
            if(range.empty()) {
                return true;
            }
            nested = range.front;
        }

        return false;
    }
    
    @property
    auto front() 
    {
        assert(!range.empty);
        assert(!nested.empty);
        return nested.front;
    }

    void popFront()
    {
        nested.popFront();
        if(nested.empty) {
            range.popFront();
            if(!range.empty) {
                nested = range.front;
            }
        }
    }
}


////////////////////////////////////////////////

// cd source 
// rdmd -unittest -main  vest/range/expand_nested

nothrow unittest {
    import std.range     : iota;
    import std.algorithm : map;
    import std.array     : array;

    assert(iota(20, 25, 1)
        .map!(x => iota(21, x, 1))
        .expandNested
        .array == [21, 21, 22, 21, 22, 23]);

    assert(iota(20, 25, 1)
        .map!(x => iota(19, x, 1))
        .expandNested
        .array == [19, 19, 20, 19, 20, 21, 19, 20, 21, 22, 19, 20, 21, 22, 23]);

    assert(iota(20, 25, 1)
        .map!(x => iota(20, x, 1))
        .expandNested
        .array == [20, 20, 21, 20, 21, 22, 20, 21, 22, 23]);

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
            [1,2],
            [],
            [],
            [3,4],
            [],
            [5,6,7]
        ].expandNested
        .array == [1, 2, 3, 4, 5, 6, 7]);

    assert([
            [1,2],
            [],
            [3,4],
            [5,6,7]
        ].expandNested
        .array == [1, 2, 3, 4, 5, 6, 7]);

    assert([
            [],
            [],
            [1,2],
            [],
            [],
            [3,4],
            [],
            [5,6,7],
            []
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
                [],
                [],
                [10,11,12],
            ]
        ].expandNested
        .array == [[1, 2], [3, 4], [5, 6, 7], [8, 9], [], [], [], [10, 11, 12]]);

    assert([
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
        ].expandNested
        .array == [[1, 2], [3, 4], [5, 6, 7], [8, 9], [], [], [], [], [], [], [10, 11, 12]]);

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
                [],
                [10,11,12],
            ]
        ].expandNested.expandNested
        .array == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);

    assert([
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
        ].expandNested.expandNested
        .array == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);


    // Deep nesting
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
                [],
                [10,11],
            ]
        ].expandNested!2
        .array == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);

    assert([
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
        ].expandNested!3
        .array == [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9]);


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
                    [8,9],
                ]
            ],[
                [
                    [10,11],
                    [],
                    [12],
                ]
            ]
        ].expandRecursively
        .array == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] );

    assert([[[[[[[[
            ["hellow"],
            [],
            ["world"],
        ]]]]]]]].expandRecursively
        .array == ["hellow", "world"] );

    {
        const(int)[][] arr = [[], [21], [21, 22], [21, 22, 23]];
        assert(arr.expandNested.array == [21, 21, 22, 21, 22, 23]);
    }{
        const(int[])[] arr = [[], [21], [21, 22], [21, 22, 23]];
        assert(arr.expandNested.array == [21, 21, 22, 21, 22, 23]);
    }
}