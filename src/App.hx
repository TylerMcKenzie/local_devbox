package src;

import sys.net.Socket;
import sys.net.Host;

class App
{
    public function new()
    {
        // APP Setup
    }

    public function run()
    {
        var host = new Host("0.0.0.0");
        var socket = new Socket();
        socket.bind(host, 3000);
        socket.listen(1);
        trace("Starting server...");

        while( true ) {
            var client: Socket = socket.accept();
            trace("Client connect to server.");
            client.write("Hello you are connected.\n");
            client.write('Your connecting IP is: ${client.peer().host.toString()}\n');
            client.write("Thank you for connecting.\n");
            client.close();
        }
    }
}