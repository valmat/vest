// 
// May destructing variables for itarable types and tuples
// 

module vest.utils.tie;

import std.range      : empty, popFront, front;
import std.traits     : isIterable;
import std.typecons   : Tuple, tuple, isTuple;
import std.functional : forward;

auto tie(Args...)(ref Args args) 
{
    static assert(Args.length, "don't call with emprty args");
    return TieInstance!(Args)(args);
}

/// Helper structure to collect pointers to arguments
private struct PointersSeq(size_t level, Arg0)
{
    Arg0* item;

    this(ref Arg0 arg0)
    {
        item = &arg0;
    }
    void set(size_t index)(ref Arg0 arg0)
        if(level == index)
    {
        *item = arg0;
    }
}

private struct PointersSeq(size_t level, Arg0, Args...)
{
    Arg0* item;
    PointersSeq!(level+1, Args) other;

    this(ref Arg0 arg0, ref Args args)
    {
        item = &arg0;
        other = args;
    }

    void set(size_t index)(auto ref Arg0 arg0)
        if(level == index)
    {
        *item = arg0;
    }
    void set(size_t index, T)(auto ref T rhs)
        if(level < index)
    {
        other.set!(index)(rhs);
    }

}
private alias PointersSeq(Arg0, Args...) = PointersSeq!(0, Arg0, Args);

/// Helper template type. Usage on cast in TieInstance::applyTuple
/// Allows to get access to its arguments by index
private template args_indexed_t(size_t index, Arg0, Args...)
{
    static assert(index < Args.length + 1);
    static if(0 == index) {
        alias args_indexed_t = Arg0;
    } else {
        alias args_indexed_t = Args[index-1];
    }
}

/// Helper structure.
/// Due to the overload of assignment operators allows to use expression tie(x, y, ...) = ...
private struct TieInstance(Arg0, Args...)
{
    PointersSeq!(Arg0, Args) items;
    alias args_t(size_t index) = args_indexed_t!(index, Arg0, Args);

    // In the constructor retrive arguments pointers
    this(ref Arg0 arg0, ref Args args)
    {
        items = PointersSeq!(Arg0, Args)(arg0, args);
    }

    // Helper method to iterate at compile time
    private void applyTuple(size_t index, T...)(auto ref Tuple!(T) rhs)
        if(T.length > 0)
    {
        // Cast operator allows extends argument types
        // for example, you can write: 
        // size_t a;
        // tie(a) = tuple(5);
        // because 5 is int, without cast it leads to compile error
        items.set!index( cast(args_t!index) rhs[index] );
        // At the same time iterate over index and tuple arguments
        // (at compile time)
        static if(index < T.length - 1 && index < Args.length) {
            applyTuple!(index+1, T)(forward!rhs);
        }
        static assert(index < T.length);
    }

    // overloading assignment operator (empty Tuple)
    void opAssign(Tuple!() rhs) {}

    // overloading assignment operator
    void opAssign(T...)(auto ref Tuple!(T) rhs)
    {
        applyTuple!(0, T)( forward!rhs );
    }

    // Helper method to iterate at compile time
    private void applyTravers(size_t index, T...)(auto ref T rhs)
        if(isIterable!T && !isTuple!T)
    {
        if(rhs.empty) return;

        items.set!index(cast(args_t!index) rhs.front);
        rhs.popFront();
        static if(index < Args.length) {
            applyTravers!(index+1, T)(forward!rhs);
        }
    }

    // overloading assignment operator for iterable types
    void opAssign(T)(auto ref T rhs)
        if(isIterable!T && !isTuple!T)
    {   
        applyTravers!(0, T)( forward!rhs );
    }
}


// to run tests: dmd -unittest -main  vest/utils/tie.d && ./vest/utils/tie
// or: rdmd -unittest -main  vest/utils/tie
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

    float pi;
    int l;

    tie(i,pi,l) = [3.14, 3.14, 3.14];
    assert(tuple(i,pi,l) == tuple(size_t(3), float(3.14), 3));

    tie(i,pi,l) = [size_t.max, size_t.max, size_t.max];
    assert( tuple(i,pi,l) == tuple(size_t.max, float(size_t.max), cast(int) size_t.max ) );

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