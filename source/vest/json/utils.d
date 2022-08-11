module vest.json.utils;

import std.json : JSONValue, JSONException, JSONType;
import std.conv : to;

// Cast to any numeric
double numeric()(auto ref const(JSONValue) v) {
    switch(v.type) {
        case JSONType.float_    :
            return v.floating;
        case JSONType.integer  :
            return v.integer;
        case JSONType.uinteger :
            return v.uinteger;
        default:
            throw new JSONException("JSONValue is a " ~ to!string(v.type) ~ ", not a numeric.");
    }
}

// Check if property exists and is not null
const(JSONValue)* checkNull()(auto ref const(JSONValue) v, string field) pure @safe
{
    const(JSONValue)* ptr =  field in v;
    return (ptr && ptr.type != JSONType.null_) ? ptr : null;
}

// cd source
// rdmd -unittest -main  vest/json/utils
unittest {
    //import std.stdio     : writeln;
    import std.algorithm : map;
    import std.json      : parseJSON;
    import std.math      : isClose;

    assert([-1, 1, 0.5, -0.5].isClose(parseJSON(`[-1,1,0.5,-0.5]`).array.map!(x => x.numeric), 1e-05, 1e-05));
    assert(parseJSON(`0.5`).numeric.isClose(0.5, 1e-05, 1e-05));
    assert(parseJSON(size_t.max.to!string).numeric == size_t.max);

    assert(null != parseJSON(`{"a":5,"b":null}`).checkNull("a"));
    assert(null == parseJSON(`{"a":5,"b":null}`).checkNull("b"));
    assert(null == parseJSON(`{"a":5,"b":null}`).checkNull("c"));
    assert( (*parseJSON(`{"a":5,"b":null}`).checkNull("a")).integer == 5);
}