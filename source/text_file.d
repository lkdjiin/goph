module text_file;

import std.array;
import std.regex;
import std.string;
import std.uni;
import document;

version(unittest) { import unit_threaded; }
else              { enum ShouldFail; }

class TextFile : Document
{
    string text;

    override string toString()
    {
        return text;
    }

    void add(in string line)
    {
        this.text = line;
    }

    override void buildWith(in string content)
    {
        this.add(content);
    }

    string take(in int number) const
    {
        auto r = regex(format("(.*\n){%s}", number));
        auto m = matchFirst(text, r);

        return m.empty ? text : m[0];
    }

    string filename() const
    {
        return title
            .toLower
            .replace(":", "_")
            .replace("/", "_")
            .replace(" ", "_");
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


@("It is empty by default") unittest
{
    TextFile f = new TextFile();
    f.toString.should == "";
}

@("It has a title") unittest
{
    TextFile f = new TextFile();
    f.title.should == "";
    f.title = "foobar";
    f.title.should == "foobar";
}

@("It adds a text") unittest
{
    TextFile f = new TextFile();
    f.add("Foo bar.\nEggs.");
    f.toString.should == "Foo bar.\nEggs.";
    f.add("overwrited!");
    f.toString.should == "overwrited!";
}

@("Take the first few lines") unittest
{
    TextFile f = new TextFile();
    f.add("foo\nbar\nbaz\neggs");
    f.take(2).should == "foo\nbar\n";
    f.take(3).should == "foo\nbar\nbaz\n";
    f.take(100).should == "foo\nbar\nbaz\neggs";
}

@("It generates a filename") unittest
{
    TextFile f = new TextFile();
    f.title = "GOPHER.ORG:70/FOO/BAR BAZ.TXT";
    f.filename.should == "gopher.org_70_foo_bar_baz.txt";
}
