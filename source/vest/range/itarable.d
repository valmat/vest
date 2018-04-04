module vest.range.itarable;

import std.functional : forward;
import std.range : ElementType, front, empty, popFront;


interface iItarable(ElType)
{
    @property 
    ElType front();

    @property
    bool empty();

    void popFront();
}

class Itarable(Range, ElType = ElementType!Range) : iItarable!ElType
{
private:
    Range r;
public:
    this()(auto ref Range r) {
        this.r = forward!r;
    }

    @property final
    ElType front()     {return r.front;}
    
    @property final
    bool empty()       {return r.empty;}
    
    void popFront()    {return r.popFront;}
}

iItarable!(ElementType!Range) getItarable(Range)(Range r) {
    return new Itarable!(Range, ElementType!Range)(forward!r);
}
iItarable!(ElType) getItarable(ElType, Range)(Range r) {
    return new Itarable!(Range, ElType)(forward!r);
}


////////////////////////////////////////////////

// cd source 
// rdmd -unittest -main  vest/range/itarable

unittest {
    //import std.stdio     : writeln;
    import std.range     : iota;
    import std.algorithm : map;
    //import std.array     : array;
    import std.math      : approxEqual;
    import std.algorithm.comparison : equal;

    import vest.range    : expandNested;


    assert(iota(20, 25, 1)
        .map!(x => iota(21, x, 1))
        .expandNested
        .equal([21, 21, 22, 21, 22, 23]));

    assert([
            [1,2].getItarable,
            iota(10, 16).getItarable,
        ]
        .expandNested
        .equal([1, 2, 10, 11, 12, 13, 14, 15]));

    assert([
            [1.1,2.1].getItarable!float,
            iota(10, 16).getItarable!float,
        ]
        .expandNested
        .approxEqual([1.1, 2.1, 10.0, 11.0, 12.0, 13.0, 14.0, 15]));


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

    assert([
            [1,2,3]
                .map!(x => new Test1(x))
                .getItarable,
            [1,2,3]
                .map!(x => new Test1(x))
                .getItarable,
        ]
        .expandNested
        .map!(x => x.get)
        .equal([1, 4, 9, 1, 4, 9]));
    
    assert([
            [1,2,3]
                .map!(x => new Test1(x))
                .getItarable!iTest,
            [1,2,3]
                .map!(x => new Test2(x))
                .getItarable!iTest,
        ]
        .expandNested
        .map!(x => x.get)
        .equal([1, 4, 9, 1, 8, 27]));
}