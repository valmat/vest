module vest.json.tojson;

import std.json      : JSONValue;
import std.array     : array, empty;
import std.algorithm : map, filter;
import std.traits    : isType, isFunction, isArray, isAssociativeArray, isIterable, isPointer, isSomeChar, isSomeString;
import std.conv      : to;
import std.typecons  : isTuple;


// Is field property of T
private
enum isProperty(T, string field) = !isType!(__traits(getMember, T, field)) && !isFunction!(__traits(getMember, T, field));

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