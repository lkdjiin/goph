module client;

import std.string;
import menu.menu;
import menu.item;
import text_file;
import caller;

version(unittest) { import unit_threaded; }
else              { enum ShouldFail; }

struct Client(DocType)
{
    string server;
    ushort port;
    DocType document;

    static DocType fetch(string server, ushort port = 70, string selector = "")
    {
        auto client = Client(server, port);
        client.select(selector);
        return client.document;
    }

    static DocType fetch(Item item)
    {
        return Client.fetch(item.server, item.port, item.selector);
    }

    this(string server, ushort port = 70)
    {
        this.server = server;
        this.port = port;
        this.document = new DocType();
    }

    void select(T = Caller)(string selector = "")
    {
        this.document.title = format("%s:%s%s", this.server, this.port,
                selector).toUpper;
        string result = T(this.server, this.port).call(selector);

        this.document.buildWith(result);
    }
}

@("It sets the title") unittest
{
    auto c = Client!Menu("server.org", 71);
    c.select!MockCaller("/foo");
    c.document.title.should == "SERVER.ORG:71/FOO";
}

@("It sets the port to 70 by default") unittest
{
    auto c = Client!Menu("server.org");
    c.port.should == 70;
}

@("It sets the menu") unittest
{
    auto c = Client!Menu("server.org");
    c.select!MockCaller("/foo");
    c.document.toString.should == "[ 0] D The Gopher Project\n[ 1] F What's New";
}

@("It sets the file") unittest
{
    auto c = Client!TextFile("server.org");
    c.select!MockFileCaller("/foo");
    c.document.toString.should == "foo\nbar\neggs";
}
