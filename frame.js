function product(n) {
    var p = 1;
    for (count = 1; count <= n; count ++) {
        p = p*count;
    }
    return p;
}

var camera = {lens: 'zoom lens', strap: 'black strap'};

function jsSet(elem, prop, val) {
    elem[prop] = val;
}


function jsmain() {
    console.log('Starting test phase...');
    console.log(camera);
    Haste['cameraType'](camera, 'DSL');
    console.log(camera);
    console.log('Ending test phase.');
}

// jsmain();
