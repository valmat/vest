// 
// May destructing variables for itarable types and tuples
// 

module vest.utils.tie;

import std.range      : empty, popFront, front;
import std.traits     : isIterable;
import std.typecons   : Tuple, tuple, isTuple;
import std.functional : forward;
import std.meta       : staticMap;

auto tie(Args...)(ref Args args) 
{
    static assert(Args.length, "don't call with emprty args");
    return TieInstance!(Args)(args);
}

private alias ptr_t(T) = T*;

/// Helper structure to collect pointers to arguments
private struct PointersSeq(Args...)
{
    alias arg_ptrs_t(T...) = Tuple!(staticMap!(ptr_t, T));
    arg_ptrs_t!(Args) items;
    
    this(ref Args args)
    {
        foreach(index, Arg; Args) {
            items[index] = &args[index];
        }
    }
    void set(size_t index, T)(auto ref T rhs)
    {
        static assert(index < Args.length);
        *items[index] = cast(Args[index]) rhs;
    }
}

/// Helper structure.
/// Due to the overload of assignment operators allows to use expression tie(x, y, ...) = ...
private struct TieInstance(Args...)
{
    PointersSeq!(Args) items;

    // In the constructor retrive arguments pointers
    this(ref Args args)
    {
        items = PointersSeq!(Args)(args);
    }

    // overloading assignment operator (empty Tuple)
    void opAssign(Tuple!() rhs) {}

    // overloading assignment operator
    void opAssign(Types...)(auto ref Tuple!(Types) rhs)
    {
        foreach(index, T; Types) {
            static if(index < Args.length) {
                items.set!index( rhs[index] );
            }
        }
    }

    // Helper method to iterate at compile time
    pragma(inline, true)
    private void applyTravers(size_t index, T)(auto ref T rhs)
        if(isIterable!T && !isTuple!T)
    {
        if(rhs.empty) return;

        items.set!index(rhs.front);
        
        rhs.popFront();
        static if(index < Args.length-1) {
            applyTravers!(index+1, T)(forward!rhs);
        }
        static assert(index < Args.length);
    }

    // overloading assignment operator for iterable types
    void opAssign(T)(auto ref T rhs)
        if(isIterable!T && !isTuple!T)
    {   
        applyTravers!(0, T)( forward!rhs );
    }
}



// to run tests: dmd -unittest -main  vest/utils/tie.d && ./vest/utils/tie
// or: cd source 
// rdmd -unittest -main  vest/utils/tie
nothrow unittest {
    
    // Traversable
    string a, b, c, d, e;
    tie(a,b,c,d,e) = ["foo1","foo2","foo3","foo4","foo5"];
    assert([a,b,c,d,e] == ["foo1","foo2","foo3","foo4","foo5"]);

    tie(a,b,c) = ["bar1","bar2"];
    assert([a,b,c] == ["bar1", "bar2", "foo3"]);

    tie(a,b,c);
    assert([a,b,c] == ["bar1", "bar2", "foo3"]);

    tie(c,c,c,d,e) = ["hru1","hru2"];
    assert([a,b,c,d,e] == ["bar1","bar2","hru2","foo4","foo5"]);

    size_t i, j, k;

    tie(i,j,k) = [1,2];
    assert([i,j,k] == [1, 2, size_t.init]);

    tie(i,j,k) = [50,60,70,80,90];
    assert([i,j,k] == [50,60,70]);

    tie(i,j,k) = [-1,3.14];
    assert([i,j,k] == [size_t.max, 3, 70]);

    double pi;
    int l;

    tie(i,pi,l) = [3.14, 3.14, 3.14];
    assert(tuple(i,pi,l) == tuple(size_t(3), double(3.14), 3));

    tie(i,pi,l) = [size_t.max, size_t.max, size_t.max];
    assert( tuple(i,pi,l) == tuple(size_t.max, double(size_t.max), cast(int) size_t.max ) );

    // Tuples
    int    x;
    string y;
    char   z;
    size_t u,v,w;

    tie(x,y,z) = tuple(26, " hello ", 'a', 777, 3.14);
    assert(x == 26);
    assert(y == " hello ");
    assert(z == 'a');
    
    tie(x,y,z) = tuple();
    assert(x == 26);
    assert(y == " hello ");
    assert(z == 'a');

    tie(x, y, z) = tuple(15, " world ");
    assert(x == 15);
    assert(y == " world ");
    assert(z == 'a');


    tie(x, y, z);
    assert(x == 15);
    assert(y == " world ");
    assert(z == 'a');

    tie(x, y, z) = tuple();
    assert(x == 15);
    assert(y == " world ");
    assert(z == 'a');

    tie(x) = tuple(50);
    assert(x == 50);

    //tie() = tuple(15, " hello "); <-- don't call with emprty args

    tie(x,y,z,u,v,w) = tuple(-5, " hi ", 'b', 48, 49, 50, 777, 3.14);
    assert(tuple(x,y,z, [u,v,w]) == tuple(-5, " hi ", 'b', [48, 49, 50]));

    tie(u,v,w,y) = tuple(15,16,17);
    assert([u,v,w] == [15,16,17]);


    tie(v,v,v,y,x,z) = tuple(25,26,27);
    assert([u,v,w] == [15,27,17]);

    tie(v,u) = tuple(u,v);
    assert([u,v] == [27,15]);
}

unittest {
    import std.range : iota;
    size_t i, j, k, l, m;
    tie(i,j,k) = iota(50, 91, 10);
    assert([i,j,k] == [50,60,70]);

    struct TestItrbl
    {
        int a = 0;
        @property bool empty() {return a >= 10;}
        @property int front()  {return a;}
        void popFront() {++a;}
    }

    tie(i,j,k,l,m) = TestItrbl();
    assert([i,j,k,l,m] == [0,1,2,3,4]);

}