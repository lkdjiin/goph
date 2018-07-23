import std.stdio;
import session;
import deimos.ncurses;
import std.string;
import std.conv;
import core.stdc.locale;

int main(string[] args)
{
    if (args.length != 2)
    {
        writeln("Usage: gopher server");
        return 1;
    }

    scope (exit)
        endwin();

    scope (failure)
        endwin();

    setlocale(LC_CTYPE,"");
    initscr();

    if (has_colors() == false)
    {
        endwin();
        writeln("Your terminal does not support color... Goodbye");
        return 1;
    }

    noecho();
    cbreak();
    start_color();
    refresh();

    init_pair(1, COLOR_BLACK, 12); // Black on blue.
    init_pair(2, 15, 238); // White on gray.

    Session.start(args[1]);

    endwin();

    return 0;
}
