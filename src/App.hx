package src;

#if js
import haxe.Json;
import js.Node;
import js.node.events.EventEmitter;
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
    public static var TMP_DIR = "/tmp/WEB_MERGETOOL_TMP";

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

        app.post('/mergetool', function(request: Request, response: Response) {
            // Init event emitter
            var eventEmitter = new EventEmitter();

            eventEmitter.on("process-complete", function(processName, data) {
                switch (processName) {
                    case "get-diff-filenames":
                        eventEmitter.emit("get-file-diffs", data.files);
                }
            });

            // Get all files with conflicts
            var diff_files_process = spawn("git", ["diff", /*"--diff-filter=UU",*/ "--name-only"]);
            var diff_files = [];

            diff_files_process.stdout.on("data", function(data) {
                var diff_files_string = data.toString();

                var diff_files_string_array: Array<String> = diff_files_string.split("\n");

                for (df in diff_files_string_array) if (df.length > 0) {
                    diff_files.push(StringTools.trim(df));
                }
                
                eventEmitter.emit("process-complete", "get-diff-filenames", {files: diff_files});
            });

            diff_files_process.on("close", function(exitCode) {
                if (diff_files.length == 0) {
                    Node.console.log("\nNo files to process. Exiting.");
                    response.json({message: "No files to process."});
                    Node.process.exit();
                }
            });

            // Only on post do we check if the directory exists
            if (!Fs.existsSync(TMP_DIR)) {
                Node.console.log("\nTMP dir not found creating '" + TMP_DIR);
                spawn("mkdir", [TMP_DIR]);
            }

            eventEmitter.on("get-file-diffs", function(files: Array<String>) {
                for (filename in files) {
                    var processing = true;
                    var process = spawn("git", ["diff", "-U0", filename]);
                    
                    process.stdout.on("data", function(buf) {
                        var diff = buf.toString();

                        processing = false;
                    });

                    process.on("close", function() {
                        processing = false;
                    });

                    while (processing) {

                    }

                    Node.console.log("Completed file: %s", filename);
                }

                Node.console.log("Completed files");
            });

            // After geting diff files 
            //  - create tmp dir
            //  - cp file into tmp dir
            //    - this will be the file locations for editing the conflicts
            //  - send list of files and their corresponding diffs
        });

        app.listen(app.get('port'), function() {
            trace('Express server listening on port ' + app.get('port'));
        });

        function exitHandler(exitCode) {
            if (exitCode == 'SIGINT') {
                if (Fs.existsSync(TMP_DIR)) {
                    Node.console.log('\nClearing "${TMP_DIR}"');
                    spawn("rm -rf", [TMP_DIR + "/*"]);
                }
            }

            Node.process.exit();
        }

        //do something when app is closing
        Node.process.on('exit', exitHandler);

        //catches ctrl+c event
        Node.process.on('SIGINT', exitHandler);

        // catches "kill pid" (for example: nodemon restart)
        Node.process.on('SIGUSR1', exitHandler);
        Node.process.on('SIGUSR2', exitHandler);

        //catches uncaught exceptions
        Node.process.on('uncaughtException', exitHandler);
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
