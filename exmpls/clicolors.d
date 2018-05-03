#!/usr/bin/rdmd --shebang=-I../source -I.

import vest.utils.clicolors : c = color;
import std.stdio : writeln;

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

    writeln(
        "Lorem ipsum dolor sit amet, ",
        c.red,
        "consectetur adipiscing elit, ",
        "sed do eiusmod tempor incididunt ut ",
        c.green,
        "labore et dolore magna aliqua. ",
        c.yellow,
        "Ut enim ad minim veniam, ",
        c.blue,
        "quis nostrud exercitation ",
        c.magenta,
        "ullamco laboris nisi ut aliquip ex ea ",
        c.yellow,
        "commodo consequat. ",
        c.cyan,
        "Duis aute irure dolor in ",
        c.dflt,
        "reprehenderit in voluptate ",
        c.black,
        "velit esse cillum dolore ",
        c.white,
        "eu fugiat nulla pariatur. ",
        c.light.red,
        "Excepteur sint occaecat ",
        c.light.green,
        "cupidatat ",
        c.light.yellow,
        "non proident, ",
        c.light.blue,
        "sunt in culpa qui ",
        c.light.magenta,
        "officia deserunt ",
        c.light.cyan,
        "mollit anim id est laborum.",
        c.reset
    );

    writeln(
        c.b,
        "Lorem ipsum dolor sit amet, ",
        c.red,
        "consectetur adipiscing elit, ",
        "sed do eiusmod tempor incididunt ut ",
        c.green,
        "labore et dolore magna aliqua. ",
        c.yellow,
        "Ut enim ad minim veniam, ",
        c.blue,
        "quis nostrud exercitation ",
        c.magenta,
        "ullamco laboris nisi ut aliquip ex ea ",
        c.yellow,
        "commodo consequat. ",
        c.cyan,
        "Duis aute irure dolor in ",
        c.dflt,
        "reprehenderit in voluptate ",
        c.black,
        "velit esse cillum dolore ",
        c.white,
        "eu fugiat nulla pariatur. ",
        c.light.red,
        "Excepteur sint occaecat ",
        c.light.green,
        "cupidatat ",
        c.light.yellow,
        "non proident, ",
        c.light.blue,
        "sunt in culpa qui ",
        c.light.magenta,
        "officia deserunt ",
        c.light.cyan,
        "mollit anim id est laborum.",
        c.reset
    );
}