function jsObjSet(elem, prop, val) {
    elem[prop] = val;
}

var jsStrSet  = jsObjSet;
var jsNumSet  = jsObjSet;
var jsBoolSet = jsObjSet;

function jsObjArrayPush(arr, str) {
    arr.push(str);
}

var jsStrArrayPush  = jsObjArrayPush;
var jsNumArrayPush  = jsObjArrayPush;
var jsBoolArrayPush = jsObjArrayPush;

//foreign import ccall jsNewArray :: IO JSAny
function jsNewArray() {
    var arr = [];
    return arr;
}

//foreign import ccall jsNewObject :: IO JSAny
function jsNewObject() {
    var obj = {};
    return obj;
}

function jsParseJSON(str) {
    var arr = [];
    arr = JSON.parse(str);
    return arr;
}
