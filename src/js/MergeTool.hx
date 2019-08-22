package src.js;

import js.Browser.*;
import js.html.*;
import src.js.mergetool.Service;
import src.js.mergetool.ui.AppView;

class MergeTool
{
    static private var appRootElement: Element = null;

    static private var service: Service = new Service();

    static private var view: AppView = null;

    static public function main()
    {
        // APP
        if (document.getElementById("mergetool") != null) {
            view = new AppView(document.getElementById("mergetool"));
        } else {
            console.error("Missing mergetool app container of id: #mergetool");
        }

        // Get current diff data
        // Service get data
        // return model with data 
        var r = service.createRequest(
            "/mergetool",
            function (data: String) {
                console.log(haxe.Json.parse(data));
            }
        );

        r.request(true);
    }
}
