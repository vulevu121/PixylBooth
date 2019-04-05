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
import Qt.labs.settings 1.1
//import ImageItem 1.0

Rectangle {
    id: root
    color: "black"
    width: 640
    height: 480
    
    property alias liveViewImageSource: imageLiveView.source
    
    Settings {
        category: "Capture"
        property alias liveViewImageSource: imageLiveView.source
    }
    
    
//    ImageItem {
//        id: liveImageItem
//        height: parent.height
//        width: parent.width
//    }

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
        id: imageLiveView
        anchors.fill: parent
//        source: "file:///C:/Users/Vu/Documents/Sony-Camera-API/example/LiveView.jpg"
        cache: false
        visible: false

//        onStatusChanged: if (imageLiveView.status == Image.Error) console.log('Error')
    }


//    Timer {
//        interval: 400
//        running: false
//        repeat: true

//        onTriggered: {
//            var oldSource = imageLiveView.source
//            imageLiveView.source = ""
//            imageLiveView.source = "file:///C:/Users/Vu/Documents/Sony-Camera-API/example/LiveView.jpg"
//        }
//    }

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



//    Image {
//        anchors.fill: parent
//        source: "http://192.168.122.1:8080/postview/memory/DCIM/100MSDCF/DSC04453.JPG?size=Scn"
//    }
}






