#!/usr/bin/rdmd --shebang=-I../source -I.

import vest.utils   : tie;
import std.stdio    : writeln;
import std.typecons : tuple;

void main()
{
    // Traversable
    string a, b, c, d, e;
    tie(a,b,c,d,e) = ["foo1","foo2","foo3","foo4","foo5","foo6"];
    writeln([a,b,c,d,e]);

    tie(a,b,c,d,e) = ["bar1","bar2"];
    writeln([a,b,c]);

    tie(a,b,c);
    writeln([a,b,c]);

    tie(c,c,c,d,e) = ["hru1","hru2"];
    writeln([a,b,c,d,e]);

    size_t i, j, k;

    tie(i,j,k) = [1,2];
    writeln([i,j,k]);
    assert([i,j,k] == [1, 2, size_t.init]);

    tie(i,j,k) = [50,60,70,80,90];
    writeln([i,j,k]);
    assert([i,j,k] == [50,60,70]);

    tie(i,j,k) = [-1,3.14];
    writeln([i,j,k]);
    assert([i,j,k] == [size_t.max, 3, 70]);

    float pi;
    int l;

    tie(i,pi,l) = [3.14, 3.14, 3.14];
    writeln([i,pi,l]);
    assert(tuple(i,pi,l) == tuple(size_t(3), float(3.14), 3));

    tie(i,pi,l) = [size_t.max, size_t.max, size_t.max];
    writeln([i,pi,l]);
    assert( tuple(i,pi,l) == tuple(size_t.max, float(size_t.max), cast(int) size_t.max ) );
    
    // Tuples
    int    x;
    string y;
    char   z;
    size_t u,v,w;

    tie(x,y,z) = tuple(1, " hello ", 'a', 777, 3.14);
    writeln(x,y,z);
    
    tie(x,y,z) = tuple();
    writeln(x,y,z);
    

    tie(x, y, z) = tuple(15, " world ");
    writeln(x, y, z);

    tie(x, y, z);
    writeln(x, y, z);
    
    //tie() = tuple(15, " hello "); // <--- don't call with emprty args
    
    tie(x) = tuple(48);
    writeln(x);

    tie(x) = tuple();
    writeln(x);

    tie(x,y,z,u) = tuple(-5, " hi ", 'b', 48, 49, 50, 777, 3.14);
    writeln(x,y,z, [u,v,w]);
    
    tie(u,v,w,y) = tuple(15,16,17);
    writeln(x,y,z, [u,v,w]);

    tie(v,v,v,y,x,z) = tuple(25,26,27);
    writeln(x,y,z, [u,v,w]);

    tie(v,u) = tuple(u,v);
    writeln([u,v]);
}