module formatter;

import std.stdio;
import std.string;
import deimos.ncurses;
import text_file;
import menu.menu;
import help;

struct Formatter
{
    static void display(Menu document, in ulong depth)
    {
        document.setPageHeight(LINES - 4);

        WINDOW* mainWindow = newwin(LINES - 4, COLS, 2, 0);

        displayHeader(document, depth);
        mvwprintw(mainWindow, 0, 0, toStringz(document.getCurrentPageContent));

        wrefresh(mainWindow);
        refresh;
        delwin(mainWindow);
    }

    static void display(in TextFile document, in ulong depth)
    {
        WINDOW* mainWindow = newwin(LINES - 4, COLS, 2, 0);
        displayHeader(document, depth);
        mvwprintw(mainWindow, 0, 0, toStringz(document.take(LINES - 4)));
        /* writeln("\n(s to save this document)"); */
        wrefresh(mainWindow);
        refresh;
        delwin(mainWindow);
    }

    static void display(in Help document, in ulong depth = 999)
    {
        WINDOW* mainWindow = newwin(LINES - 4, COLS, 2, 0);
        displayHeader(document, depth);
        mvwprintw(mainWindow, 0, 0, toStringz(document.take(LINES - 4)));
        /* writeln("\n(s to save this document)"); */
        wrefresh(mainWindow);
        refresh;
        delwin(mainWindow);
    }

    static void displayHeader(T)(in T document, in ulong depth)
    {

        string pagination = format("%s/%s", document.getCurrentPage, document.getTotalPages);

        WINDOW* headerWindow = newwin(1, COLS, 0, 0);

        wattron(headerWindow, COLOR_PAIR(1));

        mvwhline(headerWindow, 0, 0, 1, COLS);
        mvwprintw(headerWindow, 0, 0, toStringz(pagination));
        mvwprintw(headerWindow, 0, 7, toStringz(" " ~ document.title ~ " "));

        if (depth < 999)
        {
            mvwprintw(headerWindow, 0, COLS - 10, toStringz(format("DEPTH: %s", depth - 1)));
        }

        wattroff(headerWindow, COLOR_PAIR(1));

        wrefresh(headerWindow);
        delwin(headerWindow);
    }
}
