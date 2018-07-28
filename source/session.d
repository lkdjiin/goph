module session;

import std.conv;
import std.stdio;
import std.string;

import user_choice;
import menu.menu;
import menu.item;
import text_file;
import client;
import formatter;
import help;

version(unittest) { import unit_threaded; }
else              { enum ShouldFail; }

struct Session
{
    Menu[] history;
    string server;
    Menu menu;
    TextFile textFile;

    static void start(string server)
    {
        Session session = Session(server);
        session.loop;
    }

    this(string server)
    {
        this.server = server;
    }

    void loop()
    {
        readDirectory(this.server);

        outer: while (true)
        {
            string choice = userChoice;
            switch (choice)
            {
                case "b":
                    backward();
                    break;
                case "q":
                    break outer;
                case "s":
                    save();
                    break;
                case "n":
                    nextPage();
                    break;
                case "p":
                    previousPage();
                    break;
                case "?":
                    help();
                    break;
                default:
                    forward(choice);
                    break;
            }
        }
    }

    void help()
    {
        auto help = new Help();
        history ~= new Menu(); // Fake entry.
        Formatter.display(help);
    }

    void nextPage()
    {
        menu.setCurrentPage(menu.getCurrentPage + 1);
        Formatter.display(menu, history.length);
    }

    void previousPage()
    {
        menu.setCurrentPage(menu.getCurrentPage - 1);
        Formatter.display(menu, history.length);
    }

    void readDirectory(T)(T reference)
    {
        menu = Client!Menu.fetch(reference);
        history ~= menu;
        Formatter.display(menu, history.length);
    }

    void readFile(Item reference)
    {
        TextFile file = Client!TextFile.fetch(reference);
        history ~= new Menu(); // Fake entry.
        Formatter.display(file, history.length);
        textFile = file; // Keep it to save it later if needed.
    }

    void backward()
    {
        if (history.length > 1)
        {
            history.length--;
            menu = history[$ - 1];
            Formatter.display(menu, history.length);
        }
    }

    void forward(string id)
    {
        try
        {
            Item item = menu.getItem(id.parse!int);
            if (item.isDirectory) {
                readDirectory(item);
            }
            else if (item.isFile) {
                readFile(item);
            }
            else {
                assert(0);
            }
        }
        catch(std.conv.ConvException ex)
        {
            Menu m = new Menu();
            m.addItem(format("3Not an action: %s\tX\tX\t0", id));
            history ~= m;
            Formatter.display(m, history.length);
        }
        catch (Exception ex)
        {
            Menu m = new Menu();
            m.addItem(format("3%s\tX\tX\t0", ex.msg));
            history ~= m;
            Formatter.display(m, history.length);
        }
    }

    void save() const
    {
        File f = File(textFile.filename, "w");
        f.write(textFile.text);
        f.close();

        Formatter.displayMessage("File saved.");
    }

    string userChoice()
    {
        auto choice = new UserChoice();
        return choice.getChoice;
    }
}

@("It starts with an empty history") unittest
{
    Session s = Session("server");
    s.history.length.should == 0;
}
