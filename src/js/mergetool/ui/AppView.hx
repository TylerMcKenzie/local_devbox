package src.js.mergetool.ui;

import src.js.mergetool.externs.Highlight;

import js.html.*;
import js.Browser.*;

class AppView
{
    private var root: Element = null;

    private var style: String = '
        table {
            border-collapse: collapse;
        }

        td.hljs {
            padding: 0 5px;
        }

        td pre {
            min-height: 1px;
            padding-left: 5px;
        }

        tr.hljs {
            padding: 0 5px;
        }

        tr td:first-child, 
        tr td:first-child [class*=hljs] {
            width: 25px;
            color: white;
        }

        tr td:nth-child(2) {
            padding: 0 5px;
            width: 10px;
            text-align: center;
            background: #3b414c;
        }
    ';

    public function new(rootElement: Element) {
        this.root = rootElement;
        this.root.insertAdjacentHTML('beforebegin', this.renderStyle().outerHTML);
    }

    public function renderStyle(): Element
    {
        var styleElement = document.createElement("style");
        styleElement.innerHTML = this.style;

        return styleElement;
    }

    public function renderFile(fileData: Dynamic)
    {
        var filename = fileData.filename;

        var fileContent = fileData.fileContent;

        var diffs: Array<Dynamic> = fileData.diffObjects;

        var modifiedLines = new Map<String, Dynamic>();

        for (dObject in diffs) {
            var lineReg = ~/(\d*)(?:$|,)(\d*)/;
            if (lineReg.match(dObject.modifiedLineChanges)) {
                var modifyLine = Std.string(lineReg.matched(1));
                modifiedLines[modifyLine] = dObject.matchedDiff;
            }
        }

        var table = document.createElement("table");

        var tableHead = document.createElement("tr");

        var headLineColumn = document.createElement("th");

        var headChangesColumn = document.createElement("th");

        var headLineContentColumn = document.createElement("th");

        tableHead.appendChild(headLineColumn);
        tableHead.appendChild(headChangesColumn);
        tableHead.appendChild(headLineContentColumn);

        table.appendChild(tableHead);

        var lineNumber = 1;
        var fileContentArray: Array<String> = fileContent.split("\n");

        for (line in fileContentArray) {
            var lineRowElement = document.createElement("tr");

            var lineNumberElement = document.createElement("td");
            lineNumberElement.innerHTML = Std.string(lineNumber) + ".";

            var changesElement = document.createElement("td");
            if (modifiedLines[Std.string(lineNumber)] != null) {
                var modifiedLinesArray:Array<String> = modifiedLines[Std.string(lineNumber)].split("\n");
                var hasRemovedLines = false;
                var hasAddedLines = false;

                for (lineChange in modifiedLinesArray) {
                    if (StringTools.startsWith(lineChange, "-")) {
                        hasRemovedLines = true;
                    } else if (StringTools.startsWith(lineChange, "+")) {
                        hasAddedLines = true;
                    }
                }

                if (hasRemovedLines) {
                    changesElement.innerHTML += "<div style=\"color: red;\">-</div>";
                }

                if (hasAddedLines) {
                    changesElement.innerHTML += "<div style=\"color: lightgreen;\">+</div>";
                }
            }

            var contentElement = document.createElement("td");
            var contentPreElement = document.createElement("pre");
            contentPreElement.innerHTML = "<code class=\"haxe\">" + StringTools.htmlEscape(line) + "</code>";
            
            contentElement.appendChild(contentPreElement);

            // Highlight.highlightBlock(contentElement);

            lineRowElement.appendChild(lineNumberElement);
            lineRowElement.appendChild(changesElement);
            lineRowElement.appendChild(contentElement);

            Highlight.highlightBlock(lineRowElement);

            table.appendChild(lineRowElement);

            lineNumber++;
        }

        root.appendChild(table);
        // Highlight.initHighlighting();
    }
}
