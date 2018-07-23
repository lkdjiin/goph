module help;

import document;

version(unittest) { import unit_threaded; }
else              { enum ShouldFail; }

class Help : Document
{

    this()
    {
        this.title = "HELP";
    }

    override string toString()
    {
        return "Coming soon…";
    }

    override void buildWith(string content)
    {
    }

    string take(in int number) const
    {
        return
"# Number
Follow this menu hyperlink. Allowed numbers are displayed between [].

# Back (b)
Get back to the previous menu.

# Next page (n)
Go to the next page of the menu. Current page and total pages of the
current menu are displayed in the upper left corner.

# Previous page (p)
Go to the previous page of the menu. Current page and total pages of the
current menu are displayed in the upper left corner.

# Quit (q)
Quit the program and return to the terminal.

# Save text file (s)
Save the current text file. The file is named after its title in the
current working directory.

# Help (?)
Display this help file.";
    }

    ulong getTotalPages() nothrow const
    {
        return 0;
    }

    ulong getCurrentPage() nothrow const
    {
        return 0;
    }
}

@("It has a title") unittest
{
    auto obj = new Help();
    obj.title.should == "HELP";
}
