module vest.json.tojson;

import std.json      : JSONValue;
import std.array     : array, empty;
import std.algorithm : map, filter;
import std.traits    : isType, isFunction, isArray, isAssociativeArray, isIterable, isPointer, isSomeChar, isSomeString;
import std.conv      : to;
import std.typecons  : isTuple;
import std.meta      : Alias;


// Is field property of T
private
template isProperty(T, string field)
{
    alias fieldValue = Alias!(__traits(getMember, T, field));
    enum  isProperty = !isType!(fieldValue) && !isFunction!(fieldValue) && !is(typeof(fieldValue) == void);
}


// Check if field is accessible
private
enum isAccessible(T, string field) = __traits(compiles, __traits(getMember, T, field));

private
enum isPublic(T, string field) = ("public" == __traits(getProtection, mixin("T." ~ field)) );

// Helper function to retrive all structure properties
private
template _retriveProperties(T, string[] fields)
{
    static if(!fields.length) {
        enum string[] _retriveProperties = [];
    } else {
        static if( isAccessible!(T, fields[0]) && isProperty!(T, fields[0])  ) {
            enum _retriveProperties = [fields[0]] ~ _retriveProperties!(T, fields[1..$]);
        } else {
            enum _retriveProperties = _retriveProperties!(T, fields[1..$]);
        }
    }
}

// All structure properties (not members)
private
enum allProperties(T) = _retriveProperties!(T, [__traits(allMembers, T)]);

// Retrive associative tuple fields
private
string[] expandFieldNames(Names...)( Names names)
{
    static if( Names.length ) {
        return names[0] ~ expandFieldNames(names[1..$]);
    } else {
        return [];
    }
}

// Check if tuple is associative
private
enum isAssocTuple(alias T) = expandFieldNames(T.fieldNames)
    .filter!(x => !x.empty)
    .array
    .length;

// Forward JSONValue directly
auto toJson()(auto ref JSONValue value)
{
    return value;
}

// Convert to json
JSONValue toJson(T)(auto ref T value)
{
    static if( isTuple!T ) {
    // Tuples
        static if(isAssocTuple!T) {
            JSONValue rez;
            static foreach(enum i, enum subfield; value.fieldNames) {
                static if(subfield.empty) {
                    rez["_" ~ i.to!string] = toJson(value[i]);
                } else {
                    rez[subfield] = toJson(value[i]);
                }
            }
            return rez;
        } else {
            JSONValue[] rez;
            foreach(ref v; value.expand) {
                rez ~= [toJson(v)];
            }
            return JSONValue(rez);
        }
    } else static if( isArray!T && !isSomeString!T ) {
    // Arrays
        return JSONValue(value.map!(x => x.toJson()).array);
    } else static if( isAssociativeArray!T ) {
    // AssociativeArrays
        JSONValue rez;
        foreach(subfield, ref v; value) {
            rez[subfield] = toJson(v);
        }
        return rez;
    } else static if( isIterable!T && !isSomeString!T ) {
    // Iterable
        return JSONValue(value.map!(x => x.toJson()).array);
    } else static if( is(T == struct) ) {
    // Structures
        JSONValue rez;
        static foreach(enum field; allProperties!T ) {
            rez[field] = toJson(__traits(getMember, value, field));
        }
        return rez;
    } else static if( isPointer!T ) {
    // Pointers
        return (value is null) ? JSONValue() : toJson(*value);
    } else static if( isSomeChar!T ) {
    // Chars
        return JSONValue([value]);
    } else {
    // Other
        return JSONValue(value);
    }
}

// cd source 
// rdmd -unittest -main  vest/json/tojson
unittest {
    import std.typecons  : tuple, Tuple;
    import std.range     : iota;
    import std.array     : array;
    import std.algorithm : map, equal;
    import std.json      : parseJSON;
    //import std.stdio     : writeln;

    static struct SubNest {
        size_t q = 100;
        auto  r1 = tuple(5, "55");
        auto  r2 = tuple!("r2")(55);
        
        float get_q() const
        {
            return q;
        }
    }

    SubNest sn;
    assert(sn.toJson.toString == `{"q":100,"r1":[5,"55"],"r2":{"r2":55}}`);

    auto dic = [
        "one" : SubNest(1),
        "two" : SubNest(2),
    ];
    assert(dic.toJson.toString == `{"one":{"q":1,"r1":[5,"55"],"r2":{"r2":55}},"two":{"q":2,"r1":[5,"55"],"r2":{"r2":55}}}`);

    auto arr1 = [tuple!("fld1", "fld2")(55, 66), tuple!("fld1", "fld2")(77, 88)];
    assert(arr1.toJson.toString == `[{"fld1":55,"fld2":66},{"fld1":77,"fld2":88}]`);

    auto arr2 = [tuple(11, 22), tuple(33, 44)];
    assert(arr2.toJson.toString == `[[11,22],[33,44]]`);

    int i1 = 15;
    int *pi1 = &i1;
    int *pi2;
    auto arr3 = [pi1, pi2];
    assert(arr3.toJson.toString == `[15,null]`);

    auto tpl1 = tuple(true, 'e', 'Ё', "Hi", iota(0, 3));
    assert(tpl1.toJson.toString == `[true,"e","Ё","Hi",[0,1,2]]`);

    static struct MyStruct
    {
        int i      = 5;
        auto rng1 = iota(0, 3);
        auto rng2 = iota(4, 6).map!( (int v) {return tuple(v, SubNest(5 * v));}  );
        
        string str = "Hi";

        static int q = 55;
        enum r = 15;

        string[] strs = ["1", "2", "3"];

        static struct Nest {
            int x = 11;
            SubNest[] sns = [SubNest(1), SubNest(2)];
        };
        Nest nest;

        int * ptr1;
        int * ptr2;

        SubNest[string] dic;

        bool flag = true;
        char  c1 = 'e';
        dchar c2 = 'Ё';
        auto tpl1 = tuple(10, "%");
        auto tpl2 = tuple!("x", "y", "z")(2, 3, 4);
        Tuple!(int, "id", string, uint, SubNest) tpl3 = tuple(2, "3", 4, SubNest(101));

        this(string a){}

        ~this(){}
        
        int get_i() const
        {
            return i;
        }
        string get_str() const
        {
            return str;
        }
    }

    MyStruct mstr;
    mstr.dic = [
        "first"  : SubNest(1),
        "second" : SubNest(2),
    ];
    mstr.ptr2 = &mstr.i;
    assert(mstr.toJson.toString == `{"c1":"e","c2":"Ё","dic":{"first":{"q":1,"r1":[5,"55"],"r2":{"r2":55}},"second":{"q":2,"r1":[5,"55"],"r2":{"r2":55}}},"flag":true,"i":5,"nest":{"sns":[{"q":1,"r1":[5,"55"],"r2":{"r2":55}},{"q":2,"r1":[5,"55"],"r2":{"r2":55}}],"x":11},"ptr1":null,"ptr2":5,"q":55,"r":15,"rng1":[0,1,2],"rng2":[[4,{"q":20,"r1":[5,"55"],"r2":{"r2":55}}],[5,{"q":25,"r1":[5,"55"],"r2":{"r2":55}}]],"str":"Hi","strs":["1","2","3"],"tpl1":[10,"%"],"tpl2":{"x":2,"y":3,"z":4},"tpl3":{"_1":"3","_2":4,"_3":{"q":101,"r1":[5,"55"],"r2":{"r2":55}},"id":2}}`);

    // Structure has template methods
    static struct HasTpl
    {
        int i      = 5;
        this(string a){}
        ~this(){}
        int get_i() const {return i;}
        int get_itpl()() const {return i;}
        int get_itpl1(T)(T t) const {return i*t;}
    }
    HasTpl htpl;
    assert(htpl.toJson.toString == `{"i":5}`);

    // Forward json directly
    assert(`{"q":100,"r":[1,2]}`.parseJSON.toJson.toString == `{"q":100,"r":[1,2]}`);
}