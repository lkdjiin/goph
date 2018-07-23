module user_choice;

import std.conv;
import std.string;
import std.uni;
import deimos.ncurses;

version(unittest) { import unit_threaded; }
else              { enum ShouldFail; }

class UserChoice
{
    // TODO The logic, interweaved with the GUI, is too hard to test.
    // TODO Moreover it is currently wrong (try to type 1q for example).
    // TODO A state machine instead of this big function should be a good bet.
    string getChoice()
    {
        string prompt = "Your choice: (? for help) ";

        WINDOW* actionWindow = newwin(1, COLS, LINES - 1, 0);
        wattron(actionWindow, COLOR_PAIR(2));

        mvwhline(actionWindow, 0, 0, 1, COLS);
        mvwprintw(actionWindow, 0, 0, toStringz(prompt));

        wrefresh(actionWindow);

        int c;
        char temp;
        string result;
        while ((c = getch()) != 10)
        {
            temp = c.to!char;
            if (temp == 'q' || temp == 'b' || temp == 'n' || temp == 'p'
                    || temp == '?')
            {
                result ~= format("%c", c.to!char);
                break;
            }
            else if (isNumber(c))
            {
                result ~= format("%c", c.to!char);
                mvwprintw(actionWindow, 0, (prompt.length).to!int, toStringz(result));
                wrefresh(actionWindow);
            }
        }

        wattroff(actionWindow, COLOR_PAIR(2));
        delwin(actionWindow);

        return result.strip;
    }
}
