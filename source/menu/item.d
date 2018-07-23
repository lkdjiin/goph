module menu.item;

import std.conv;
import std.string;

version(unittest) { import unit_threaded; }
else              { enum ShouldFail; }

struct Item
{
    ushort port;
    string server;
    string selector;
    char type;
    string title;
    ulong id;

    this(in string str, in ulong id)
    {
        if (str.length > 0)
        {
            auto fields = str.split("\t");
            if (fields.length >= 4)
            {
                this.port = parse!ushort(fields[3]);
                this.server = fields[2];
                this.selector = fields[1];
                this.type = fields[0][0];
                this.title = fields[0][1 .. $];
                this.id = id;
            }
        }
    }

    bool isValid() const
    {
        if (this.isFile || this.isDirectory || this.isError || this.isComment)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    bool isFile() const
    {
        return this.type == '0';
    }

    bool isDirectory() const
    {
        return this.type == '1';
    }

    bool isError() const
    {
        return this.type == '3';
    }

    bool isComment() const
    {
        return this.type == 'i';
    }

    bool isNull() const
    {
        return this.type == 255;
    }

    bool isIndexable() const
    {
        return isFile || isDirectory;
    }

    string toString() const
    {
        string result;
        switch (this.type)
        {
            case '0':
                result = format("[%2s] %s %s", this.id, "F", this.title);
                break;
            case '1':
                result = format("[%2s] %s %s", this.id, "D", this.title);
                break;
            case '3':
                result = format("**** %s %s", "E", this.title);
                break;
            case 'i':
                result = format("     %s", this.title);
                break;
            default: assert(0);
        }

        return result;
    }
}

@("File type is valid") unittest
{
    Item i = Item("1Archives	/Archives	gopher.quux.org	70	+", 1);
    i.isValid.should == true;

    i = Item("3'/Archives/gutenberg' [...]		error.host	1", 1);
    i.isValid.should == true;

    i = Item("ZArchives	/Archives	gopher.quux.org	70	+", 1);
    i.isValid.should == false;

    i = Item("iWelcome to gopher at quux.org!	fake	(NULL)	0", 1);
    i.isValid.should == true;
}

@("It can be a null object") unittest
{
    Item i = Item();
    i.isNull.should == true;
}

@("It accepts bad strings") unittest
{
    Item i = Item("", 1);
    i.isValid.should == false;
    i = Item("foobar", 1);
    i.isValid.should == false;
}

@("It records the server's port") unittest
{
    Item i = Item("1Archives	/Archives	gopher.quux.org	70	+", 1);
    i.port.should == 70;
    i = Item("1Archives	/Archives	gopher.quux.org	71	+", 1);
    i.port.should == 71;

    i = Item("iWelcome to gopher at quux.org!	fake	(NULL)	0", 1);
    i.port.should == 0;
}

@("It records the server's name") unittest
{
    Item i = Item("1Archives	/Archives	gopher.quux.org	70	+", 1);
    i.server.should == "gopher.quux.org";
}

@("It records the selector") unittest
{
    Item i = Item("1Archives	/Archives	gopher.quux.org	70	+", 1);
    i.selector.should == "/Archives";
}

@("It recognizes a File document") unittest
{
    Item i = Item("0How To Help	/How To Help.txt	gopher.quux.org	70	+", 1);
    i.isFile.should == true;
    i.isDirectory.should == false;
}

@("It recognizes a Directory document") unittest
{
    Item i = Item("1Archives	/Archives	gopher.quux.org	70	+", 1);
    i.isFile.should == false;
    i.isDirectory.should == true;
}

@("It recognizes an Error") unittest
{
    Item i = Item("3'/Archives/gutenberg' [...]		error.host	1", 1);
    i.isFile.should == false;
    i.isDirectory.should == false;
    i.isError.should == true;
}

@("It recognizes a comment") unittest
{
    Item i = Item("iWelcome to gopher at quux.org!	fake	(NULL)	0", 1);
    i.isFile.should == false;
    i.isDirectory.should == false;
    i.isComment.should == true;
}

@("It is indexable") unittest
{
    Item i = Item();
    i.type = '0';
    i.isIndexable.should == true;
    i.type = '1';
    i.isIndexable.should == true;
    i.type = 'i';
    i.isIndexable.should == false;
}

@("It represents itself as a string") unittest
{
    Item i = Item("1Archives	/Archives	gopher.quux.org	70	+", 1);
    i.toString.should == "[ 1] D Archives";

    i = Item("0How To Help	/How To Help.txt	gopher.quux.org	70	+", 23);
    i.toString.should == "[23] F How To Help";

    i = Item("3'/Archives/gutenberg' does not exist		error.host	1", 1);
    i.toString.should == "**** E '/Archives/gutenberg' does not exist";

    i = Item("iWelcome to gopher at quux.org!	fake	(NULL)	0", 1);
    i.toString.should == "     Welcome to gopher at quux.org!";
}


