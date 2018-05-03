module vest.utils.clicolors;


struct color {
    @disable this();
    @disable this(this);

    enum string reset   = "\033[0m";    // set all attributes by default
    enum string b       = "\033[1m";    // bold (intense color)
    enum string sb      = "\033[2m";    // (semi-bright) (dark grey regardless of the colour)
    enum string u       = "\033[4m";    // underline
    enum string blink   = "\033[5m";    // flashing (if supported by terminal)
    enum string rev     = "\033[7m";    // reversion (swap the background color, symbols color)
    enum string hidden  = "\033[8m";    // hidden
    enum string norm    = "\033[22m";   // set normal intensity
    enum string uu      = "\033[24m";   // unset underline
    enum string ublink  = "\033[25m";   // unset blink
    enum string urev    = "\033[27m";   // unset reversion


    enum string dflt    = "\033[39m"; // default color
    enum string black   = "\033[30m";
    enum string red     = "\033[31m";
    enum string green   = "\033[32m";
    enum string yellow  = "\033[33m";
    enum string blue    = "\033[34m";
    enum string magenta = "\033[35m";
    enum string cyan    = "\033[36m";
    enum string gray    = "\033[37m";
    alias       grey    = gray;
    enum string white   = "\033[97m";

    // light colors
    struct light {
        enum string red     = "\033[91m";
        enum string green   = "\033[92m";
        enum string yellow  = "\033[93m";
        enum string blue    = "\033[94m";
        enum string magenta = "\033[95m";
        enum string cyan    = "\033[96m";
    };

    struct background {
        enum string black   = "\033[40m";
        enum string red     = "\033[41m";
        enum string green   = "\033[42m";
        enum string yellow  = "\033[43m";
        enum string blue    = "\033[44m";
        enum string magenta = "\033[45m";
        enum string cyan    = "\033[46m";
        enum string grey    = "\033[47m";
    };

    alias bg = background;
};