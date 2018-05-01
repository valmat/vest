module vest.json.utils;

import std.json : JSONValue, JSONException, JSON_TYPE;
import std.conv : to;

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

// cd source
// rdmd -unittest -main  vest/json/utils
unittest {
    //import std.stdio     : writeln;
    import std.algorithm : map;
    import std.json      : parseJSON;
    import std.math      : approxEqual;

    assert([-1, 1, 0.5, -0.5].approxEqual(parseJSON(`[-1,1,0.5,-0.5]`).array.map!(x => x.numeric)));
    assert(parseJSON(`0.5`).numeric.approxEqual(0.5));
    assert(parseJSON(size_t.max.to!string).numeric == size_t.max);

    assert(null != parseJSON(`{"a":5,"b":null}`).checkNull("a"));
    assert(null == parseJSON(`{"a":5,"b":null}`).checkNull("b"));
    assert(null == parseJSON(`{"a":5,"b":null}`).checkNull("c"));
    assert( (*parseJSON(`{"a":5,"b":null}`).checkNull("a")).integer == 5);
}