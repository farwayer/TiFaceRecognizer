// load module
var FaceRecognizer = require('by.farwayer.facerecognizer');

function recognize() {
    // now create face detector with default options:
    // accuracy is FaceRecognizer.ACCURACY_HIGH
    // tracking is false
    // minFeatureSize is 0.01
    // (https://developer.apple.com/library/ios/documentation/CoreImage/Reference/CIDetector_Ref/Reference/Reference.html)
    var detector = FaceRecognizer.createDetector();


    // String/Titanium.Blob/Titanium.Filesystem.File
    // var image = "test.jpg";
    // var image = Ti.Filesystem.getFile("image.jpg");
    var image = imageView.image;
    // var image = imageBuffer.toBlob();



    // simple recognize
    // function profile() is for profiling only and not necessary in usual use
    // you can simply do: res = detector.featuresInImage(image);
    var res = null;

    var dt = profile(function() {

        res = detector.featuresInImage(image);

    });

    log("========= Simple recognize: " + res.success + " " + dt + " ms =========");
    var faces = res.faces;
    for (var i = 0; i < faces.length; i++) {
        log("Face " + i + ":");
        var face = faces[i];

        var bounds = face.bounds;
        log("\tbounds: x=" + bounds.x + " y=" + bounds.y + " w=" + bounds.width + " h=" + bounds.height);

        if (face.leftEyePosition) {
            log("\tleftEyePosition: x=" + face.leftEyePosition.x + " y=" + face.leftEyePosition.y);
        }
        if (face.rightEyePosition) {
            log("\trightEyePosition: x=" + face.rightEyePosition.x + " y=" + face.rightEyePosition.y);
        }
        if (face.mouthPosition) {
            log("\tmouthPosition: x=" + face.mouthPosition.x + " y=" + face.mouthPosition.y);
        }
        if (face.faceAngle) {
            log("\tfaceAngle = " + face.faceAngle);
        }

        addView(bounds.x, bounds.y, bounds.width, bounds.height);

        if (face.leftEyePosition) addView(face.leftEyePosition.x-5, face.leftEyePosition.y-5, 10, 10);
        if (face.rightEyePosition) addView(face.rightEyePosition.x-5, face.rightEyePosition.y-5, 10, 10);
        if (face.mouthPosition) addView(face.mouthPosition.x-5, face.mouthPosition.y-5, 10, 10);
    }


    // more advanced recognize
    // you don't need to create new detector
    // can simply do detector.setTracking(true); for tracking
    detector.setTracking(true);
    // detector = FaceRecognizer.createDetector({
    //     tracking: true
    // });

    dt = profile(function() {

        res = detector.featuresInImage(image, {
            recognizeEyeBlink: true,
            recognizeSmile: true
        });

    });

    log("======== Advanced recognize: " + res.success + " " + dt + " ms ========");
    faces = res.faces;
    for (var i = 0; i < faces.length; i++) {
        log("Face " + i + ":");
        var face = faces[i];

        if (face.trackingID) {
            log("\ttrackingID=" + face.trackingID);
        }
        if (face.trackingFrameCount) {
            log("\ttrackingFrameCount=" + face.trackingFrameCount);
        }
        log("\thasSmile=" + face.hasSmile);
        log("\tleftEyeClosed=" + face.leftEyeClosed);
        log("\trightEyeClosed=" + face.rightEyeClosed);
    }



    // rotated or fliped image: set imageOrientation to position of (0,0)
    res = detector.featuresInImage(image, {
        imageOrientation: FaceRecognizer.IMAGE_ORIENTATION_BOTTOM_LEFT
    });



    // async recognize
    var t = new Date().getTime();
    dt = profile(function() {

        detector.featuresInImage(image, null, function(res) {
            var dt = new Date().getTime() - t;
            log("\tresult: " + res.success + " return in " + dt + " ms");
        });

    });
    log("== Async recognize: featuresInImage return in " + dt + " ms ==");
}



var win = Ti.UI.createWindow({
    backgroundColor: 'white'
});
var btn = Ti.UI.createButton({
    top: 280,
    color: 'green',
    title: 'Recognize!'
});
var imageView = Ti.UI.createImageView({
    top: 0,
    width: 320,
    height: 320,
    image: 'test.jpg'
});
btn.addEventListener('click', recognize);
var textArea = Ti.UI.createTextArea({
    editable: false,
    top: 320,
    backgroundColor: '#bbb',
    width: Ti.UI.FILL,
    height: Ti.UI.FILL
});
win.add(imageView);
win.add(btn);
win.add(textArea);
win.open();


function profile(fn) {
    var t = new Date().getTime();
    fn();
    return new Date().getTime() - t;
}

function log(text) {
    textArea.value += text + "\n";
}

function addView(x, y, w, h) {
    var v = Ti.UI.createView({
        left: x,
        bottom: y,
        width: w,
        height: h,
        borderColor: 'green'
    });
    imageView.add(v);
}