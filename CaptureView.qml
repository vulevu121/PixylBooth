import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.1
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import Qt.labs.folderlistmodel 2.0
import QtWebView 1.1
import Process 1.0
import SonyAPI 1.0
import SonyLiveview 1.0
import ProcessPhotos 1.0
import PrintPhotos 1.0
import CSVFile 1.0
import Firebase 1.0

Item {
    id: root

    property alias liveView: liveView
    property alias mediaPlayer: mediaPlayer
    property alias countdown: countdown

    property alias videoLoader: videoLoader
    property alias review: review
    property alias endSession: endSession
    property alias captureToolbar: captureToolbar


//    Settings {
//        id: mainSettings
//        property string cameraDeviceId
//    }

//    Settings {
//        id: profileSettings
//        property string templateImagePath
//    }


//    Settings {
//        id: templateSettings
//        category: "Template"
//        property string templateFormat
//        property real numberPhotos
//    }

//    Settings {
//        id: cameraSettings
//        category: "Camera"
//        property string cameraDeviceId
//    }

    function startState() {
        sonyAPI.stop()
        sonyAPI.start()
        playStartVideos()

        // clear photo list and timers before capture
        photoList.clear()
        stopAllTimers()
        resetCountdownTimer()

        toast.show("Initializing Sony camera")

        captureToolbar.playPauseButton.checked = false
        root.state = "start"
//        liveView.stop()
//        liveView.start()

    }

    function beforeCaptureState() {
        stopAllTimers()
        sonyAPI.cancelHalfPressShutter()
        playBeforeCaptureVideos()
        beforeCaptureTimer.restart()
        root.state = "beforecapture"
    }

    function liveviewState() {
        resetCountdownTimer()
        countdown.visible = true
        countdownTimer.restart()
        reviewImage.source = ""
        root.state = "liveview"

    }

    function afterCaptureState() {
        playAfterCaptureVideos()
        afterCaptureTimer.restart()
        root.state = "afterCapture"

    }

    function reviewState() {
        reviewTimer.restart()
        root.state = "review"

    }

    function endSessionState() {
        endSessionPopup.source = addFilePrefix(lastCombinedPhoto)
        endSessionPopup.open()
        endSessionTimer.restart()
        root.state = "endsession"
        liveView.stop()
    }

    function stopAllTimers() {
        beforeCaptureTimer.stop()
        afterCaptureTimer.stop()
        reviewTimer.stop()
        endSessionTimer.stop()
        countdownTimer.stop()
        actTakePictureTimer.stop()
    }

    function resetCountdownTimer() {
        countdown.visible = false
        countdownTimer.stop()
        countdown.count = settings.countdownTimer
    }

    function playStartVideos() {
        mediaPlayer.stop()
        mediaPlayer.playlist = settings.startVideoPlaylist
        settings.startVideoPlaylist.next()
        mediaPlayer.play()
    }

    function playBeforeCaptureVideos() {
        mediaPlayer.stop()
        mediaPlayer.playlist = settings.beforeCaptureVideoPlaylist
        settings.beforeCaptureVideoPlaylist.next()
        mediaPlayer.play()
        console.log('playBeforeCaptureVideos')

    }

    function playAfterCaptureVideos() {
        mediaPlayer.stop()
        mediaPlayer.playlist = settings.afterCaptureVideoPlaylist
        settings.afterCaptureVideoPlaylist.next()
        mediaPlayer.play()
        console.log('playAfterCaptureVideos')
    }

    function combinePhotos() {
        // make the template as the first image in the list
        var photos = ""

        // iterate and append all the photos to the list string
        var i
        if (photoList.count > 0) {

            for(i = 0 ; i < photoList.count ; i++) {
                photos = photos.concat(photoList.get(i).filePath)
                if (i < photoList.count-1) {
                    photos = photos.concat(";")
                }
            }

            lastCombinedPhoto = processPhotos.combine(photos)
//            console.log(lastCombinedPhoto)
        }
    }

    // Sony API to initialize camera, take picture, etc.
    SonyAPI {
        id: sonyAPI
        saveFolder: settings.saveFolder
        onActTakePictureCompleted: {
            actTakePictureTimer.stop()
            reviewImage.source = addFilePrefix(actTakePictureFilePath)
            photoList.append({"fileName": getFileName(actTakePictureFilePath), "filePath": actTakePictureFilePath})
            reviewState()
        }

        onExposureSignal: {
            exposureButton.value = exposure
        }

    }


    // process the photos into template
    ProcessPhotos {
        id: processPhotos
        saveFolder: settings.printFolder

        templatePath: settings.templateImagePath
        templateFormat: settings.templateFormat
    }




    // timer to initialize to a default state
    Timer {
        id: initialTimer1
        interval: 1000
        running: true
        repeat: false

        onTriggered: {
            startState()
        }
    }


    // timer for before capture video
    Timer {
        id: beforeCaptureTimer
        interval: settings.beforeCaptureTimer * 1000
        repeat: false

        onTriggered: {
            liveviewState()
        }
    }

    // timer for after capture video
    Timer {
        id: afterCaptureTimer
        interval: settings.afterCaptureTimer * 1000
        repeat: false

        onTriggered: {
            beforeCaptureState()
        }
    }


    // timer for countdown
    Timer {
        id: countdownTimer
        running: false
        repeat: true
        interval: 1000

        onTriggered: {
            if (captureView.countdown.count == settings.countdownTimer - 1) {
                sonyAPI.actHalfPressShutter()
            }

            if (captureView.countdown.count == 2) {
                sonyAPI.cancelHalfPressShutter()
            }


            if (captureView.countdown.count <= 0) {
                resetCountdownTimer()
                // take a picture at end of countdown
                sonyAPI.actTakePicture()
                toast.show("Capturing photo " + (photoList.count+1))
                actTakePictureTimer.restart()
            }
            else {
                captureView.countdown.count--
            }

        }
    }

    // timeout after capture request is initiated, just in case
    Timer {
        id: actTakePictureTimer
        interval: 5000
        repeat: false

        onTriggered: {
            sonyAPI.actTakePicture()
            toast.show("Capturing photo " + (photoList.count+1))
        }
    }

    // timer to review photo after each capture
    Timer {
        id: reviewTimer
        interval: settings.reviewTimer * 1000
        repeat: false

        onTriggered: {
            if (photoList.count < settings.numberPhotos) {
//                beforeCaptureState()
                afterCaptureState()
            } else {
                combinePhotos()
                endSessionState()

            }
        }
    }



    // timer for end of session to print and share photos
    Timer {
        id: endSessionTimer
        interval: settings.endSessionTimer * 1000
        repeat: false

        onTriggered: {
            endSessionPopup.close()
            startState()

        }
    }




    UpDownButton {
        id: exposureButton
        min: -15
        max: 15
        value: 0
        height: pixel(12)
        z: 5

        anchors {
            top: parent.top
            right: parent.right
            margins: pixel(2)
        }

        onValueChanged: {
            sonyAPI.setExposureCompensation(exposureButton.value)
            toast.show("Camera exposure set to " + exposureButton.value)
        }

        Timer {
            id: getExposureTimer
            interval: 3000
            repeat: false
            running: true

            onTriggered: {
                sonyAPI.getExposureCompensation()
            }

        }

    }

    Timer {
        id: autorunTimer
        interval: 60000
        repeat: true
        running: autorunTimerSwitch.checked

        triggeredOnStart: true

        onTriggered: {
            captureToolbar.playPauseButton.checked = true
            captureToolbar.playPauseButton.clicked()
        }
    }

    Switch {
        id: autorunTimerSwitch
        z: 3
    }

    
    // ==== STATES ====
    states: [
        // ==== start state ====
        State {
            name: "start"
            PropertyChanges {
                target: liveView
                opacity: settings.showLiveVideoOnStartSwitch ? 1 : 0
                scale: 1
            }
            PropertyChanges {
                target: videoLoader
                opacity: 1
                scale: 1
            }
            
        },
        // ==== beforecapture state ====
        State {
            name: "beforecapture"
            PropertyChanges {
                target: videoLoader
                opacity: 1
                scale: 1
            }
        },
        // ==== liveview state ====
        State {
            name: "liveview"
            PropertyChanges {
                target: liveView
                opacity: 1
                scale: 1
                width: mainWindow.width * 0.9
                height: width / photoAspectRatio
                x: 0
                y: pixel(30)
            }
            PropertyChanges {
                target: countdown
                opacity: 0.5
                scale: 1
            }

        },

        // ==== after capture state ====
        State {
            name: "afterCapture"
            PropertyChanges {
                target: videoLoader
                opacity: 1
                scale: 1
            }
        },

        // ==== review state ====
        State {
            name: "review"
            PropertyChanges {
                target: review
                opacity: 1
                scale: 1
            }

        },
        // ==== endsession state ====
        State {
            name: "endsession"
            PropertyChanges {
                target: endSession
                opacity: 1
                scale: 1
            }
        }
        
    ]
    
    transitions: Transition {
        NumberAnimation {
            properties: "opacity,scale,x,y,width,height";
            duration: 200;
            easing.type: Easing.InOutQuad;
        }
    }

    ImagePopup {
        id: endSessionPopup
        anchors.centerIn: parent
        width: mainWindow.width * 0.9
        height: width / photoAspectRatio

        Overlay.modal: GaussianBlur {
            source: captureView
            radius: 8
            samples: 16
            deviation: 3
        }
    }
    
    
//    Button {
//        id: playPauseButton
//        text: "Play/Pause"
//        Layout.alignment: Qt.AlignRight | Qt.AlignTop
//        icon.source: checked ? "qrc:/Images/pause_white_48dp.png" : "qrc:/Images/play_arrow_white_48dp.png"
//        icon.width: pixel(20)
//        icon.height: pixel(20)
//        anchors.centerIn: parent
//        display: AbstractButton.IconOnly
//        highlighted: false
//        flat: false
//        opacity: 0.8
//        background: Rectangle {
//            color: "transparent"
//        }

//        Material.accent: Material.color(Material.Green, Material.Shade700)
//        checkable: true
//        z: 10
//        scale: 3
//        smooth: true

//        Behavior on icon.source {
//            ParallelAnimation {
//                id: playPauseButtonParallelAnimation

//                NumberAnimation {
//                    target: playPauseButton
//                    property: "opacity";
//                    from: 0.1;
//                    to: 0.3;
//                    duration: 800;
//                    easing.type: Easing.InOutQuad;
//                }

//                NumberAnimation {
//                    target: playPauseButton
//                    property: "scale";
//                    from: 2;
//                    to: 3;
//                    duration: 600;
//                    easing.type: Easing.InOutQuad;
//                }
//            }
//        }

//        onClicked: {
//            var playState = playPauseButton.checked

//            if (root.state == "start") {
//                beforeCaptureState()
//            }

//            if (root.state == "beforecapture") {
//                beforeCaptureTimer.running = playState
//            }

//            if (root.state == "liveview") {
//                countdownTimer.running = playState
//            }

//            if (root.state == "review") {
//                reviewTimer.running = playState
//            }

//            if (root.state == "endsession") {
//                endSessionTimer.running = playState
//            }

//        }
//    }
    
    CaptureToolbar {
        id: captureToolbar
        opacity: 0.5
    }
    
        
//     live view from camera
    SonyLiveview {
        id: liveView
        opacity: 0
        scale: 0.1
        z:1

        flipHorizontally: settings.mirrorLiveVideoSwitch

        width: parent.width
        height: width / photoAspectRatio
        anchors.horizontalCenter: parent.horizontalCenter

    }

//    Button {
//        onClicked: {
//            liveView.start()
//            liveView.opacity = 1
//            liveView.scale = 1
//        }
//    }
    
    
    


//    Timer {
//        interval: 3000
//        running: true
//        repeat: false

//        onTriggered: {
//            try {
//                console.log("Initializing Webcamera")
//                liveView.source = "CameraItem.qml"
////                liveView.item.start()
//                if (liveView.status == Loader.Error) {
//                    liveView.source = "CameraDummy.qml"
//                    console.log("CameraDummy")
//                }
//            }
//            catch(err) {
//                console.log(err)
//            }


//        }
//    }

//    WebView {
//        id: liveView
//        opacity: 0
//        scale: 0.1

//        url: "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/test"

//        width: parent.width
//        height: width / photoAspectRatio
//        anchors.horizontalCenter: parent.horizontalCenter

//        anchors {
//            top: parent.top
//            topMargin: pixel(30)
//        }
//    }

//    Loader {
//        id: liveView
//        opacity: 0
//        scale: 0.1

////        source: "CameraItem.qml"

//        width: parent.width
//        height: width / photoAspectRatio
//        anchors.horizontalCenter: parent.horizontalCenter

//        anchors {
//            top: parent.top
//            topMargin: pixel(30)
//        }

//    }

    
//    VideoOutput {
//        id: liveView
//        opacity: 0
//        scale: 0.1

        
//        visible: true
//        width: parent.width
//        height: width / photoAspectRatio
//        anchors.horizontalCenter: parent.horizontalCenter

//        anchors {
//            top: parent.top
//            topMargin: pixel(30)
//        }

////        source: camera

//        Text {
//            text: qsTr("Preview")
//            color: Material.foreground
//            font.pixelSize: pixel(5)
//        }
        
////        Rectangle {
////            anchors.fill: parent
////            border.color: "#808080"
////            border.width: 1
////            color: "transparent"
////        }


////        Button {
////            text: "Stop"
////            onClicked: {
////                camera.stop()

////                liveView.source = camera;

////                liveView.update()

////                camera.start()
////            }
////        }
//    }

//    Camera {
//        id: camera
//        captureMode: Camera.CaptureStillImage
//        deviceId: settings.cameraDeviceId


//    }



//    Webcamera {
//        id: liveview

//        opacity: 0
//        scale: 0.1
//        width: parent.width
//        height: width / photoAspectRatio
//        anchors.horizontalCenter: parent.horizontalCenter
//        anchors.top: parent.top
//        anchors {
//            top: parent.top
//            topMargin: pixel(30)
//        }
//    }

    
    VideoOutput {
        id: videoLoader
        anchors.fill: parent
        source: mediaPlayer
        fillMode: VideoOutput.PreserveAspectFit
        opacity: 0
        scale: 0.1

        MouseArea {
            anchors.fill: parent
            onClicked: {
                captureToolbar.playPauseButton.checked = true
                captureToolbar.playPauseButton.clicked()
            }
        }

    }
    
    MediaPlayer {
        id: mediaPlayer
        autoPlay: true
        volume: 1
        loops: MediaPlayer.Infinite
        playlist: settings.startVideoPlaylist
        
    }
    
    
    // countdown display
    Countdown {
        id: countdown
        anchors.fill: liveView
        textColor: settings.countDownColor
        opacity: 0
        scale: 0.1
        z: 4
    }
    
    
    
    // review image
    Rectangle {
        id: review
        width: mainWindow.width - pixel(10)
        height: width * 0.75
        anchors.top: parent.top
        anchors.topMargin: pixel(20)
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0
        scale: 0.1
        color: "transparent"
        Image {
            id: reviewImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            mirror: settings.mirrorLiveVideoSwitch
        }
    }
    
    // end session
    Item {
        id: endSession
        anchors.fill: parent
        opacity: 0
        scale: 0.1
        
        Gallery {
            anchors.fill: parent
            anchors.leftMargin: pixel(20)
            model: photoList
            cellWidth: mainWindow.width - pixel(40)
        }
    }
    
}
