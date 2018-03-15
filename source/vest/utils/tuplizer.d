//
// Tuplize multiple iterators.
// It takes iterators and builds on them a new iterator from tuples of
// aggregated iterators.
// 

module vest.utils.tuplizer;

import std.range      : empty, popFront, front;
import std.typecons   : Tuple, tuple;
import std.functional : forward;
import std.conv       : to;

auto tuplizer(Ranges...)(auto ref Ranges ranges)
{
    static assert(Ranges.length, "don't call with emprty args");
    return Tuplizer!Ranges(forward!ranges);
}

private struct Tuplizer(Ranges...)
{
private:
    Tuple!(Ranges) _ranges;
public:
    this(Ranges ranges)
    {
        _ranges = tuple(ranges);
    }

    @property
    bool empty() const
    {
        // _ranges[0].empty || _ranges[1].empty ...
        return mixin(_ct_join!(Ranges.length, "empty", " || "));
    }

    @property
    auto front() const
    {
        // tuple(_ranges[0].front, _ranges[1].front, ...)
        return mixin("tuple(" ~ _ct_join!(Ranges.length, "front", ", ") ~ ")");
    }
    
    @property
    auto front() 
    {
        // tuple(_ranges[0].front, _ranges[1].front, ...)
        return mixin("tuple(" ~ _ct_join!(Ranges.length, "front", ", ") ~ ")");
    }

    // Remove the first element
    void popFront()
    {
        // _ranges[0].popFront; _ranges[1].popFront; ...
        mixin(_ct_join!(Ranges.length, "popFront", "; ") ~ ";");
    }

    private template _ct_join(size_t len, string caller, string glue) 
    {
        static assert(len, "len mast be greater than zero");
        static if(0 == len) {
            enum string _ct_join = "";
        } else static if(1 == len) {
            enum string _ct_join = "_ranges[0]." ~ caller;
        } else {
            enum string _ct_join = 
                _ct_join!(len-1, caller, glue)          ~
                glue                                  ~
                "_ranges[" ~ (len-1).to!string ~ "]." ~ 
                caller;
        }
    }

    // just for test
    //pragma(msg, _ct_join!(Ranges.length, "caller()", " ;glue; ") );
    //pragma(msg, _ct_join!(Ranges.length, "front", ", ") );
    //pragma(msg, _ct_join!(Ranges.length, "popFront", "; ") ~ ";" );
}


// to run tests: dmd -unittest -main  vest/utils/tie.d && ./vest/utils/tie
// or: cd source 
// rdmd -unittest -main  vest/utils/tuplizer
unittest {
    import std.typecons  : tuple, Tuple;
    import std.range     : iota;
    import std.array     : array;
    import std.algorithm : map, equal;

    auto rf = iota(0.5, 0.0, -0.1); // 0.5, 0.4, 0.3, 0.2, 0.1
    auto ri = iota(50, 101, 10);    // 50,  60,  70,  80,  90,  100
    auto as = ["str1", "str2", "str3"];
    

    auto rt = tuplizer(ri, rf, as);
    Tuple!(int, double, string)[] at = [
        tuple(50, 0.5, "str1"),
        tuple(60, 0.4, "str2"),
        tuple(70, 0.3, "str3")
    ];

    assert(rt.equal(at));
    assert(rt.map!"a[2]".equal(as));
    assert(rt.map!"a[0]".equal(ri.array[0..3]) );
}
