import QtQuick 2.0
//import QtQuick.Window 2.2
//import QtQuick.VirtualKeyboard 2.2
//import QtQuick.Controls.Styles 1.4
//import QtQuick.Controls 2.5
//import QtQuick.Controls.Material 2.12
//import QtQuick.Layouts 1.3
//import Qt.labs.platform 1.1
//import QtQuick.Dialogs 1.3
//import Qt.labs.settings 1.1
//import QtGraphicalEffects 1.12
import QtMultimedia 5.4
import QtWebView 1.0

Rectangle {
    id: captureFrame
    color: "black"
    width: 640
    height: 480
    
    
//    WebView {
//        id: webView
//        anchors.fill: parent
//        url: "http://127.0.0.1:5000"
////        onLoadingChanged: {
////            if (loadRequest.errorString)
////                console.error(loadRequest.errorString);
////        }
//    }
    Image {
        id: imageLiveview
        anchors.fill: parent
        source: "file:///home/eelab10/PycharmProjects/Sony-Camera-API/example/image.jpg"
        cache: false
    }
    
    Timer {
        interval: 100
        running: true
        repeat: true
        
        onTriggered: {
//            console.log("updating pic")
//            imageLiveview.update()
            imageLiveview.source = ""
            imageLiveview.source = "file:///home/eelab10/PycharmProjects/Sony-Camera-API/example/image.jpg"
        }
    }

//    Camera {
//        id: camera

//        //                    imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

//        //                    exposure {
//        //                        exposureCompensation: -1.0
//        //                        exposureMode: Camera.ExposurePortrait
//        //                    }

//        //                    flash.mode: Camera.FlashRedEyeReduction

//        imageCapture {
//            onImageCaptured: {
//                photoPreview.source = preview  // Show the preview in an Image

//            }
//        }

//        videoRecorder {
//            resolution: "1280x720"
//            frameRate: 30

//        }
//    }

//    VideoOutput {
//        id: cameraOutput
//        source: camera
//        anchors.fill: parent
//        focus : visible // to receive focus and capture key events when visible
//    }

//    Image {
//        id: photoPreview
//    }
}





/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
