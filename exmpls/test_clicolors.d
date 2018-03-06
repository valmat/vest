#!/usr/bin/rdmd --shebang=-I../source -I.

import vest.utils.clicolors : c = color;
import std.stdio    : writeln;


void main()
{
    
    enum auto tail = c.reset                 ~ 
        "reprehenderit "                     ~
        c.rev                                ~
        "in voluptate"                       ~ 
        c.urev                               ~
        " velit esse cillum dolore "         ~
        c.gray                               ~
        "eu fugiat nulla pariatur. "         ~
        c.magenta                            ~
        "Excepteur sint occaecat cupidatat " ~
        c.green                              ~
        "non proident, sunt in culpa "       ~
        c.yellow                             ~
        "qui officia deserunt mollit "       ~
        c.blue                               ~
        "anim id est laborum"                ~
        c.reset;

    writeln(
        "Lorem ipsum dolor sit amet, ",
        c.b,
        "consectetur adipiscing elit, ",
        c.red,
        "sed do eiusmod tempor incididunt ut ",
        c.u,
        "labore et dolore magna aliqua. ",
        c.rev,
        "Ut enim ad minim veniam, ",
        c.urev, c.blue,
        "quis nostrud exercitation ",
        c.uu,
        "ullamco laboris nisi ut aliquip ex ea ",
        c.bg.yellow,
        "commodo consequat. ",
        c.norm, c.green,
        "Duis aute irure dolor in ",
        tail
    );

}