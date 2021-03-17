module vest.utils.bitint;

// Bit manipulations


import core.stdc.stdint : uint8_t;
import std.traits       : isArray;
import std.algorithm    : min;

struct BitInt(T = size_t)
{
private:
    T _value = 0;
    enum T one = cast(T) 1;

public:    
    enum uint8_t length = cast(uint8_t)( 8 * T.sizeof );
    alias value this;

    this(S)(S v)
        if(!isArray!S)
    {
        _value = cast(T) v;
    }
    this(uint8_t[] states)
    {
        foreach(size_t i; 0 .. length) {
            set(i, states[i]);
        }
    }    
    BitInt!T opAssign(S)(S rhs)
        if(!isArray!S)
    {
        _value = cast(T) rhs;
        return this;
    }
    BitInt!T opAssign(uint8_t[] states)
    {
        _value = BitInt!T(states)._value;
        return this;
    }

    BitInt!T opOpAssign(string op)(T rhs)
    {
        mixin("_value "~op~"= rhs;");
        return this;
    }
    BitInt!T opOpAssign(string op)(BitInt!T rhs)
    {
        return opOpAssign!op(rhs._value);
    }
    T opOpAssign(string op)(uint8_t[] rhs)
    {
        return opOpAssign!op(BitInt!T(rhs));
    }

    uint8_t get(size_t index) const pure nothrow @safe
    {
        return ( 0 == ( _value & (one << (length - 1 - (index % length))) ) ) ? uint8_t(0) : uint8_t(1);
    }
    uint8_t opIndex(size_t index) const pure nothrow @safe
    {
        return get(index);
    }
    uint8_t[] array() const pure nothrow @safe
    {
        uint8_t[] res;
        res.length = length;
        foreach(uint8_t i; 0..length) {
            res[i] = get(i);
        }
        
        return res;
    }
    T value() const pure nothrow @safe
    {
        return _value;
    } 

    ref BitInt set(size_t index, int state) pure nothrow @safe
    {
        T val = (one << (length - 1 - index % length));
        _value = state ? (_value | val) : (_value & ~cast(size_t)(val));
        return this;
    }
    ref BitInt on(size_t index) pure nothrow @safe
    {
        return set(index, true);
    }
    ref BitInt off(size_t index) pure nothrow @safe
    {
        return set(index, false);
    }
    
    uint8_t opDollar(size_t dim : 0LU)() const pure nothrow @safe
    {
        return length;
    }
    
    bool opIndexAssign(int state, size_t index) nothrow pure @safe
    {
        set(index, state);
        return cast(bool) state;
    }

    uint8_t[] opSlice(size_t i, size_t j) const nothrow pure @safe
    {
        return array()[i .. j];
    }
    uint8_t[] opSlice() const nothrow pure @safe
    {
        return array();
    }    

    uint8_t[] opSliceAssign(uint8_t[] states, size_t i_beg, size_t i_end) nothrow pure @safe
        in(states.length >= i_end - i_beg)
    {
        foreach(size_t i; i_beg .. i_end) {
            set(i, states[i - i_beg]);
        }
        return states;
    }
    uint8_t opSliceAssign(uint8_t state, size_t i_beg, size_t i_end) nothrow pure @safe
    {
        foreach(size_t i; i_beg .. i_end) {
            set(i, state);
        }
        return state;
    }    
    uint8_t opSliceAssign(uint8_t state) nothrow pure @safe
    {
        foreach(size_t i; 0 .. length) {
            set(i, state);
        }
        return state;
    }
    uint8_t[] opSliceAssign(uint8_t[] states) nothrow pure @safe
    {
        auto end = min(length, states.length);
        foreach(size_t i; 0 .. end) {
            set(i, states[i]);
        }
        return states;
    }

    size_t opSliceOpAssign(string s : "&")(size_t state, size_t i_beg, size_t i_end) nothrow pure @safe
    {
        auto rhs = BitInt!T(state);
        foreach(size_t i; i_beg .. i_end) {
            set(i, get(i) & rhs[$ - i_end + i]);
        }

        return state;
    }
    size_t opSliceOpAssign(string s : "|")(size_t state, size_t i_beg, size_t i_end) nothrow pure @safe
    {
        auto rhs = BitInt!T(state);
        foreach(size_t i; i_beg .. i_end) {
            set(i, get(i) | rhs[$ - i_end + i]);
        }

        return state;
    }

    T opSliceOpAssign(string s : "|")(T state) nothrow pure @safe
    {
        _value |= BitInt!T(state)._value;
        return _value;
    }
    T opSliceOpAssign(string s : "&")(T state) nothrow pure @safe
    {
        _value &= BitInt!T(state)._value;
        return _value;
    }

    T opSliceOpAssign(string s : "|")(uint8_t[] states) nothrow pure @safe
    {
        auto end = min(length, states.length);
        foreach(size_t i; 0..end) {
            set(i, get(i) | states[i]);
        }
        return _value;
    }
    T opSliceOpAssign(string s : "&")(uint8_t[] states) nothrow pure @safe
    {
        auto end = min(length, states.length);
        foreach(size_t i; 0..end) {
            set(i, get(i) & states[i]);
        }
        return _value;
    }
    
    uint8_t[] opSliceOpAssign(string s : "|")(uint8_t[] states, size_t i_beg, size_t i_end) nothrow pure @safe
    {
        foreach(size_t i; i_beg .. i_end) {
            set(i, get(i) | states[i-i_beg]);
        }
        return states;
    }
    uint8_t[] opSliceOpAssign(string s : "&")(uint8_t[] states, size_t i_beg, size_t i_end) nothrow pure @safe
    {
        foreach(size_t i; i_beg .. i_end) {
            set(i, get(i) & states[i-i_beg]);
        }
        return states;
    }

    T opAssign(string s : "|")(T state) nothrow pure @safe
    {
        _value |= state;
        return state;
    }
    T opAssign(string s : "&")(T state) nothrow pure @safe
    {
        _value &= state;
        return state;
    }
    
    bool opEquals(S)(in BitInt!S rhs) const
    {
        return _value == rhs._value;
    }
    bool opEquals(T rhs) const
    {
        return _value == rhs;
    }
    bool opEquals(uint8_t[] states) const
    {
        return _value == BitInt!T(states)._value;
    }
}



nothrow unittest{
    import core.stdc.stdint;

    {
        size_t y = BitInt!size_t(5);
        assert(5 == y);
    }
    {
        BitInt!uint8_t x = 5;

        assert(x[$ - 3] == x.get(x.length -3));
        assert(x[$ - 4] == x.get(x.length -4));
        assert(1 == x[$ - 1 - 2]);
        assert(0 == x[$ - 1 - 3]);
        assert(x.array == [0, 0, 0, 0, 0, 1, 0, 1]);
        assert(x.array == x[]);
    }
    {
        assert([0, 0, 0, 0, 0, 0, 0, 1] == BitInt!uint8_t(1).array);
        assert([0, 0, 0, 0, 0, 0, 1, 0] == BitInt!uint8_t(2).array);
        assert([0, 0, 0, 0, 0, 0, 1, 1] == BitInt!uint8_t(3).array);
        assert([0, 0, 0, 0, 0, 1, 0, 0] == BitInt!uint8_t(4).array);
        assert([0, 0, 0, 0, 0, 1, 0, 1] == BitInt!uint8_t(5).array);
        assert([0, 0, 0, 0, 0, 1, 1, 0] == BitInt!uint8_t(6).array);
        assert([0, 0, 0, 0, 0, 1, 1, 1] == BitInt!uint8_t(7).array);
        assert([0, 0, 0, 0, 1, 0, 0, 0] == BitInt!uint8_t(8).array);
        assert([0, 0, 0, 0, 1, 0, 0, 1] == BitInt!uint8_t(9).array);
        assert([0, 0, 0, 0, 1, 0, 1, 0] == BitInt!uint8_t(10).array);
        assert([0, 0, 0, 0, 1, 0, 1, 1] == BitInt!uint8_t(11).array);
        assert([0, 0, 0, 0, 1, 1, 0, 0] == BitInt!uint8_t(12).array);
        assert([0, 0, 0, 1, 0, 0, 0, 0] == BitInt!uint8_t(16).array);
        assert([0, 0, 0, 1, 1, 0, 0, 1] == BitInt!uint8_t(25).array);

        assert(BitInt!uint16_t(25)[$-8..$] == BitInt!uint8_t(25).array);
    }
    {
        BitInt!uint8_t x = 5;

        x = BitInt!size_t(133);
        assert([1, 0, 0, 0, 0, 1, 0, 1] == x.array);
        assert(133 == x);
    }
    {
        BitInt!uint8_t x;
        x[] = [1, 0, 1, 0, 1, 1, 0, 1];

        assert([1, 0, 1, 0, 1, 1, 0, 1] == x[]);
        assert(173 == x);

        x.set(1, 1);
        x[2] = 0;
        x[$ - 2] = 1;
        assert([1, 1, 0, 0, 1, 1, 1, 1] == x.array);
        assert(207 == x);
    }
    {
        BitInt!uint8_t x = [0, 1, 0, 1, 0, 1, 0, 1];

        x[$ - 3..$] = 1;
        x[0 .. 3]    = 0;
        assert([0, 0, 0, 1, 0, 1, 1, 1] == x);
        assert(23  == x);
        assert([0, 1, 0, 1, 0, 1, 0, 1] != x);
        assert(85 != x);
    }
    {
        BitInt!uint8_t x = [0, 1, 0, 1, 0, 1, 0, 1];

        x[2 .. $ - 3] = [ 1, 1, 1];
        assert([0, 1, 1, 1, 1, 1, 0, 1] == x);
        assert(125 == x);
        
        x[3..5] = [0, 0];
        assert([0, 1, 1, 0, 0, 1, 0, 1] == x);
        assert(101 == x);

        x[] = 0;
        assert([0, 0, 0, 0, 0, 0, 0, 0] == x);
        assert(0 == x);

        x[] = 1;
        assert([1, 1, 1, 1, 1, 1, 1, 1] == x);
        assert(255 == x);
    }
    {
        BitInt!size_t x = 255;
        BitInt!uint8_t  y = x;
        assert(x.value == y.value);
    }
    {
        BitInt!uint8_t x = 255;
        BitInt!size_t  y = x;
        assert(x.value == y.value);
    }
    {
        BitInt!uint16_t x = 0;
        BitInt!uint8_t  y = 255;

        x[1..5] = y[3..$];
        assert([0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] == x);

        x = y;
        assert([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1] == x);
    }
    {
        BitInt!uint16_t x = 0;
        BitInt!uint8_t  y = 255;

        x[] = y[];
        assert([1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0] == x);
    }
    {
        BitInt!uint16_t x = 0;
        
        x[1..5] = 1;
        x[2]    = 0;
        x[$-2..$] = 1;

        assert([0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1] == x);
    }
    {
        BitInt!uint16_t x = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1];
        x[0..$] &= 255;
        assert([0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1] == x);
    }
    {
        BitInt!uint16_t x = uint16_t.max;
        x[0..$] &= 255;
        assert([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1] == x);
    }
    {
        BitInt!uint16_t x = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1];
        x[0..$] |= 255;
        assert([0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1] == x);
    }
    {
        BitInt!uint16_t x = 0;
        x[0..$] |= 255;
        assert([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1] == x);
        assert(255 == x);
    }
    {
        BitInt!uint16_t x = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1];
        x[] &= 255;
        assert([0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1] == x);
    }
    {
        BitInt!uint16_t x = uint16_t.max;
        x[] &= 255;
        assert([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1] == x);
    }
    {
        BitInt!uint16_t x = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1];
        x[] |= 255;
        assert([0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1] == x);
    }
    {
        BitInt!uint16_t x = 0;
        x[] |= 255;
        assert([0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1] == x);
        assert(255 == x);
    }
    {
        BitInt!uint8_t x = 0;

        x[0..2]  = 255;
        assert(192 == x);
        assert([1, 1, 0, 0, 0, 0, 0, 0] == x);
        
        x[2..4] |= 255;
        assert(240 == x);
        assert([1, 1, 1, 1, 0, 0, 0, 0] == x);

        x[1..3] &= 0;
        assert(144 == x);
        assert([1, 0, 0, 1, 0, 0, 0, 0] == x);

        x[] |= 7;
        assert(151 == x);
        assert([1, 0, 0, 1, 0, 1, 1, 1] == x);

        x[] &= 127;
        assert([0, 0, 0, 1, 0, 1, 1, 1] == x);
    }
    {
        BitInt!uint8_t x = 0;
        x[0..5]  |= [1, 0, 1, 0, 1, 0, 1, 0];
        assert([1, 0, 1, 0, 1, 0, 0, 0] == x);

        x[4..$]  |= BitInt!uint8_t(uint8_t.max)[];
        assert([1, 0, 1, 0, 1, 1, 1, 1] == x);
    }
    {
        BitInt!uint8_t x = size_t.max;
        x[0..5]  &= [1, 0, 1, 0, 1, 0, 1, 0];
        assert([1, 0, 1, 0, 1, 1, 1, 1] == x);

        x[$-2..$]  &= 0;
        assert([1, 0, 1, 0, 1, 1, 0, 0] == x);
    }
    {
        BitInt!uint8_t x = size_t.max;
        x[0..5]  &= [1, 0, 1, 0, 1, 0, 1, 0];
        assert([1, 0, 1, 0, 1, 1, 1, 1] == x);

        x[$-2..$]  &= 0;
        assert([1, 0, 1, 0, 1, 1, 0, 0] == x);
    }
    {
        BitInt!uint8_t x = size_t.max;
        x[] &= 7;
        assert(7 == x);
        x = 0;
        x[] |= 7;
        assert(7 == x);
    }
    {
        BitInt!uint8_t x = size_t.max;

        x &= 7;
        assert(7 == x);
        x = 0;
        x |= 7;
        assert(7 == x);

        x += 55;
        assert(62 == x);

        x -= 14;
        assert(48 == x);

        x = [1,0,1,0,1,0,1,0,1];
        x |= 227;
        assert(235 == x);
    }
    {
        BitInt!uint8_t x = 0;

        x |= [1, 0, 0, 1, 0, 1, 1, 1];
        assert(151 == x);
        
        x = 0;
        x |= BitInt!uint8_t([1, 0, 0, 1, 0, 1, 1, 1]);
        assert(151 == x);

        x = 0;
        x |= 151;
        assert(151 == x);
    }
    {
        BitInt!uint8_t x = 0;
        x += [1, 0, 0, 1, 0, 1, 1, 1];
        assert(151 == x);
        
        x = 0;
        x += BitInt!uint8_t([1, 0, 0, 1, 0, 1, 1, 1]);
        assert(151 == x);

        x = 0;
        x += 151;
        assert(151 == x);
    }
    {
        BitInt!uint8_t x = 0;
        x[] |= 151;
        assert(151 == x);
    }
    {
        BitInt!uint8_t x = 0;
        x[] |= BitInt!uint8_t([1, 0, 0, 1, 0, 1, 1, 1]);
        assert(151 == x);
    }
    {
        BitInt!uint8_t x = 0;
        x[] |= [1, 0, 0, 1, 0, 1, 1, 1];
        assert(151 == x);
        x = uint8_t.max;
        x[] &= [1, 0, 0, 1, 0, 1, 1, 1];
        assert(151 == x);
    }
    {
        BitInt!uint8_t x = 0;

        x[] |= [1, 0, 1, 1, 1];
        assert([1, 0, 1, 1, 1, 0, 0, 0] == x);


        x[] &= BitInt!uint32_t(uint32_t.max)[];
        assert([1, 0, 1, 1, 1, 0, 0, 0] == x);
    }
}