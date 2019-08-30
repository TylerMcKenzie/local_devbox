package src.js.mergetool.externs;

import js.html.*;

@:native("hljs")
extern class Highlight implements Dynamic
{
    static function highlightBlock(block: Element): String;

    static function initHighlighting(): Void;
}
