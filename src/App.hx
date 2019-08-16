package src;

#if js
import haxe.Json;
import js.Node;
import js.node.Fs;
import js.node.Http;
import js.node.Path;
import js.node.ChildProcess.spawn;
import js.npm.Express;
import js.npm.express.*;
#end

#if sys
import sys.net.Socket;
import sys.net.Host;
#end

class App
{
    public function new()
    {
        // APP Setup
    }

    public function run()
    {
        #if sys
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
        #end

        #if js
        trace("Starting server...");
        var app : Express = new Express();
        app.set('port', 3000);
        // app.set('views', Node.__dirname + '/public/views'); // View engine views location
        var VIEWS_PATH = Node.__dirname + '/public/views';

        app.use(BodyParser.json());
        app.use(BodyParser.urlencoded({ extended : true}));
        app.use(new Static(Path.join(Node.__dirname, 'public')));

        app.get('/mergetool', function(request: Request, response: Response) {
            response.sendFile(VIEWS_PATH + "/mergetool.html");
        });

        app.listen(app.get('port'), function() {
            trace('Express server listening on port ' + app.get('port'));
        });
        #end
    }
}

// TODO MOVE THIS SOMEWHERE FOR SOME REFERENCE
// var server = Http.createServer(function(request, response) {
//             // Routing will be gross till I get a better idea what i want
//             //mergetool
//             switch request.url {
//                 case "/mergetool":
//                     switch request.method {
//                         case "POST":
//                         case "GET":
//                             var contentIndex = request.rawHeaders.indexOf("Content-Type");
//                             if (contentIndex > -1) {
//                                 switch (request.rawHeaders[contentIndex + 1]) {
//                                     case "application/json":
//                                         // Todo json stuff here
//                                         var ls = spawn("ls", ["-al"]);
//                                         var jsonData = '';
//                                         ls.stdout.on('data', function(data) {
//                                             jsonData = Json.stringify({msg: data.toString()});
//                                             trace(jsonData);
//                                             response.setHeader("Content-Type", "application/json");
//                                             response.write(jsonData);
//                                             response.end();
//                                         });

//                                         ls.on('close', function(code) {
//                                             trace('ls exit with code: ${code}');
//                                         });

//                                 }
//                             } else {
//                                 // Default is return mergetool view
//                                 Fs.readFile("./src/views/mergetool.html", null, function(error, data) {
//                                     if (error != null) {
//                                         response.writeHead(404);
//                                         response.end();
//                                     } else {
//                                         response.writeHead(200, {
//                                             'Content-type': 'text/html'
//                                         });

//                                         response.write(data);
//                                         response.end();
//                                     }
//                                 });
//                             }

//                         case _:
//                     }
//                 case _:
//             }
//         });