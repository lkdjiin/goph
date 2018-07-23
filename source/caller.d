import std.socket;

struct Caller
{
    string server;
    ushort port;

    this(string server, ushort port)
    {
        this.server = server;
        this.port = port;
    }

    string call(string selector)
    {
        auto socket = new TcpSocket(new InternetAddress(this.server, this.port));
        char[1024] buffer;

        socket.send(selector ~ "\r\n");

        string result = "";

        ptrdiff_t amountRead;
        while((amountRead = socket.receive(buffer)) != 0) {
            result = (result ~ buffer[0 .. amountRead]).idup;
        }

        socket.close;

        return result;
    }
}

struct MockCaller
{
    this(string server, ushort port) {}
    string call(string selector)
    {
        return "1The Gopher Project	/Software/Gopher	gopher.quux.org	70\n" ~
            "0What's New	/whatsnew.txt	gopher.quux.org	70	+";
    }
}

struct MockFileCaller
{
    this(string server, ushort port) {}
    string call(string selector)
    {
        return "foo\nbar\neggs";
    }
}
