package src.js.mergetool.ui;

import js.html.*;
import js.Browser.*;

class AppView
{
    private var root: Element = null;

    public function new(rootElement: Element) {
        this.root = rootElement;
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
                console.log(lineReg.matched(2));
                modifiedLines[modifyLine] = dObject.matchedDiff;
            }
        }

        console.log(modifiedLines);

        var table = document.createElement("table");

        var tableHead = document.createElement("tr");

        var headLineColumn = document.createElement("th");
        headLineColumn.innerHTML = "Ln";

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
            lineNumberElement.innerHTML = Std.string(lineNumber);

            var changesElement = document.createElement("td");
            if (modifiedLines[Std.string(lineNumber)] != null) {
                changesElement.innerHTML ="<pre>" + modifiedLines[Std.string(lineNumber)] + "</pre>";
            }


            var contentElement = document.createElement("td");
            contentElement.innerHTML = "<pre>" + line + "</pre>";

            lineRowElement.appendChild(lineNumberElement);
            lineRowElement.appendChild(changesElement);
            lineRowElement.appendChild(contentElement);

            table.appendChild(lineRowElement);

            lineNumber++;
        }

        root.appendChild(table);
    }
}
