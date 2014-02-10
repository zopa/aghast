function product(n) {
    var p = 1;
    for (count = 1; count <= n; count ++) {
        p = p*count;
    }
    return p;
}

function jsSet(elem, prop, val) {
    elem[prop] = val;
}



function jsmain() {
    console.log('Starting test phase...');
    var result = product(10);
    console.log('The product up to 10 is:' + result);
    var camera = {lens: 'zoom lens', strap: 'black strap'};
    console.log('With Haskell: ' + Haste.prod(10));
    Haste.cameraType(camera, null);
    console.log(camera);
    console.log('Ending test phase.');
}
