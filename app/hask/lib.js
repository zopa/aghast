// foreign import ccall jsStrSet :: JSAny -> JSString -> JSString -> IO () 
function jsStrSet(elem, prop, val) {
    elem[prop] = val;
}

//foreign import ccall jsObjSet :: JSAny -> JSString -> JSAny -> IO ()
var jsObjSet = jsStrSet;

//foreign import ccall jsStrArrayPush :: JSAny -> JSString -> IO ()
function jsStrArrayPush(arr, str) {
    arr.push(str);
}

// foreign import ccall jsObjArrayPush :: JSAny -> JSAny -> IO () 
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
