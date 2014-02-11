function jsStrSet(elem, prop, val) {
    elem[prop] = val;
}

var jsObjSet = jsStrSet;
var jsNumSet = jsStrSet;

function jsStrArrayPush(arr, str) {
    arr.push(str);
}

var jsObjArrayPush = jsStrArrayPush;

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
