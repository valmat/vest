module vest.json.utils;

import std.json      : JSONValue, JSONException, JSON_TYPE;
import std.array     : array, empty;
import std.algorithm : map, filter;
//import std.traits    : isType, isFunction, isArray, isAssociativeArray, isIterable, isPointer, isSomeChar, isSomeString;
import std.conv      : to;

// Cast to any numeric
double numeric()(auto ref JSONValue v) {
    switch(v.type) {
        case JSON_TYPE.FLOAT    :
            return v.floating;
        case JSON_TYPE.INTEGER  :
            return v.integer;
        case JSON_TYPE.UINTEGER :
            return v.uinteger;
        default:
            throw new JSONException("JSONValue is a " ~ to!string(v.type) ~ ", not a numeric.");
    }
}

// Check if property exists and is not null
const(JSONValue)* checkNull()(auto ref JSONValue v, string field) pure @safe
{
    const(JSONValue)* ptr =  field in v;
    return (ptr && ptr.type != JSON_TYPE.NULL) ? ptr : null;
}