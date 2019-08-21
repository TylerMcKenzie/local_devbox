package src.js.mergetool;

import haxe.Http;
import js.Browser.*;

import src.js.mergetool.Model;

class Service
{
    private var model: Model = new Model();

    public function new()
    {
        console.log("SERVICE");
    }

    public function createRequest(url: String, ?successFn: Null<String -> Void>, ?errorFn: Null<String -> Void>, ?statusFn: Null<Int -> Void>): Http
    {
        var request = new Http(url);
        
        #if js
        request.async = true;
        #end

        if (successFn != null) request.onData = successFn;
        if (errorFn != null) request.onError = errorFn;
        if (statusFn != null) request.onStatus = statusFn;

        return request;
    }
}
