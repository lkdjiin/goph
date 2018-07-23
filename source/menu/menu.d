module menu.menu;

import std.algorithm.iteration;
import std.string;
import menu.item;
import document;
import paginable;

version(unittest) { import unit_threaded; }
else              { enum ShouldFail; }

class Menu : Document, Paginable
{
    int nextID = 0;
    Item[] items;
    uint pageHeight;
    ulong totalPages;
    ulong currentPage = 1;

    override string toString() const
    {
        return this.items.map!(x => x.toString).join("\n");
    }

    void addItem(string str)
    {
        Item i = Item(str, this.nextID);
        if (i.isValid)
        {
            this.items ~= i;
            if (i.isIndexable)
            {
                this.nextID++;
            }
        }
    }

    Item getItem(int id) const
    {
        Item target = Item();
        foreach (i; items)
        {
            if (i.isIndexable && i.id == id)
            {
                target = i;
                break;
            }
        }
        if (target.isNull)
        {
            throw new Exception(format("Not a link: %s", id));
        }
        return target;
    }

    override void buildWith(string content)
    {
        auto lines = content.split("\n");
        foreach (line; lines)
        {
            this.addItem(line);
        }
    }

    ulong setPageHeight(uint lines)
    {
        this.pageHeight = lines;

        ulong numOfLines = count(this.toString, "\n") + 1;
        this.totalPages = numOfLines / this.pageHeight;

        if (numOfLines % this.pageHeight != 0)
        {
            this.totalPages++;
        }

        return this.totalPages;
    }

    ulong getTotalPages() nothrow const
    {
        return this.totalPages;
    }

    ulong getCurrentPage() nothrow const
    {
        return this.currentPage;
    }

    ulong setCurrentPage(ulong page) nothrow
    {
        if (page <= this.totalPages && page > 0)
        {
            this.currentPage = page;
        }
        return this.currentPage;
    }

    string getCurrentPageContent() const
    {
        ulong start = this.pageHeight * (this.currentPage - 1);
        ulong end = start + this.pageHeight;
        if (end > this.items.length) {
            end = this.items.length;
        }
        auto win = this.items[start .. end];

        return win.map!(x => x.toString).join("\n");
    }
}

@("It is empty by default") unittest
{
    Menu m = new Menu();
    m.toString.should == "";
}

@("Its title can be set") unittest
{
    Menu m = new Menu();
    m.title.should == "";
    m.title = "Foobar";
    m.title.should == "Foobar";
}

@("It adds menu items") unittest
{
    Menu m = new Menu();
    m.addItem("1Archives	/Archives	gopher.quux.org	70	+");
    m.addItem("iWelcome	fake	(NULL)	0");
    m.addItem("0How To Help	/How To Help.txt	gopher.quux.org	70	+");

    Item i = m.getItem(0);
    i.toString.should == "[ 0] D Archives";
    i = m.getItem(1);
    i.toString.should == "[ 1] F How To Help";
}

@("#getItem throws an exception") unittest
{
    Menu m = new Menu();
    m.addItem("1Archives	/Archives	gopher.quux.org	70	+");
    m.getItem(123).should.throw_;
}

@("It represents itself as a string") unittest
{
    Menu m = new Menu();
    m.addItem("0How To Help	/How To Help.txt	gopher.quux.org	70	+");
    m.addItem("1Archives	/Archives	gopher.quux.org	70	+");

    m.toString.should == "[ 0] F How To Help\n[ 1] D Archives";
}

@("Ids are bound to some documents only") unittest
{
    Menu m = new Menu();
    m.addItem("iWelcome	fake	(NULL)	0");
    m.addItem("0Help	/How To Help.txt	gopher.quux.org	70	+");
    m.addItem("iEnjoy!	fake	(NULL)	0");
    m.addItem("1Archives	/Archives	gopher.quux.org	70	+");

    m.toString.should == "     Welcome\n" ~
                         "[ 0] F Help\n" ~
                         "     Enjoy!\n" ~
                         "[ 1] D Archives";
}

@("It calculates the number of pages") unittest
{
    Menu m = new Menu();
    m.addItem("iWelcome	fake	(NULL)	0");
    m.addItem("0Help	/How To Help.txt	gopher.quux.org	70	+");
    m.addItem("iEnjoy!	fake	(NULL)	0");
    m.addItem("1Archives	/Archives	gopher.quux.org	70	+");

    m.setPageHeight(2).should == 2;
    m.getTotalPages().should == 2;

    m.setPageHeight(3).should == 2;
    m.getTotalPages().should == 2;

    m.setPageHeight(4).should == 1;
    m.getTotalPages().should == 1;

    m.setPageHeight(100).should == 1;
    m.getTotalPages().should == 1;
}

@("Its current page is 1 by default") unittest
{
    Menu m = new Menu();
    m.getCurrentPage.should == 1;
}

@("It manages the current page") unittest
{
    Menu m = new Menu();
    m.addItem("iWelcome	fake	(NULL)	0");
    m.addItem("0Help	/How To Help.txt	gopher.quux.org	70	+");
    m.addItem("iEnjoy!	fake	(NULL)	0");
    m.addItem("1Archives	/Archives	gopher.quux.org	70	+");
    m.setPageHeight(2).should == 2;

    m.setCurrentPage(2);
    m.getCurrentPage.should == 2;

    m.setCurrentPage(3); // Not possible, there is only 2 pages.
    m.getCurrentPage.should == 2;

    m.setCurrentPage(1);
    m.getCurrentPage.should == 1;

    m.setCurrentPage(0); // Nope, page is 1 based.
    m.getCurrentPage.should == 1;
}

@("It gets the current page content") unittest
{
    Menu m = new Menu();
    m.addItem("iWelcome	fake	(NULL)	0");
    m.addItem("0Help	/How To Help.txt	gopher.quux.org	70	+");
    m.addItem("iEnjoy!	fake	(NULL)	0");
    m.addItem("1Archives	/Archives	gopher.quux.org	70	+");

    m.setPageHeight(2);
    m.getCurrentPageContent.should == "     Welcome\n[ 0] F Help";
    m.setCurrentPage(2);
    m.getCurrentPageContent.should == "     Enjoy!\n[ 1] D Archives";

    m.setPageHeight(3);
    m.setCurrentPage(1);
    m.getCurrentPageContent.should == "     Welcome\n[ 0] F Help\n     Enjoy!";
    m.setCurrentPage(2);
    m.getCurrentPageContent.should == "[ 1] D Archives";
}
