import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
//import QtQuick.Layouts 1.3
//import Qt.labs.platform 1.1
//import QtQuick.Dialogs 1.3
//import Qt.labs.settings 1.1
import QtMultimedia 5.9
//import QtGraphicalEffects 1.0
//import Qt.labs.folderlistmodel 2.0
//import QtWebView 1.1
import ProcessPhotos 1.0
import PrintPhotos 1.0
//import Firebase 1.0
import SonyRemote 1.0

Item {
    id: captureView

//    property alias liveView: liveView
    property alias sonyRemote: sonyRemote
    property alias mediaPlayer: mediaPlayer
    property alias countdown: countdown

    property alias videoLoader: videoLoader
    property alias review: review
    property alias endSession: endSession
    property alias captureToolbar: captureToolbar

    function capturePhoto() {
        sonyRemote.actTakePicture()
        toast.show("Capturing Photo " + (photoList.count+1) + " / " + settings.numberPhotos)
    }

    function startState() {
//        toast.show("Start State")
        console.log("[CaptureView] Start state")
        captureToolbar.playing = false
        sonyRemote.start()
//        sonyAPI.stop()
//        sonyAPI.start()
        playStartVideos()
        // clear photo list and timers before capture
        photoList.clear()
        stopAllTimers()
        resetCountdownTimer()
//        toast.show("Initializing Sony camera")
        captureView.state = "start"
//        liveView.stop()
//        liveView.start()
    }

    function beforeCaptureState() {
//        toast.show("Before Capture State")
        console.log("[CaptureView] Before capture state")
        stopAllTimers()
//        sonyAPI.cancelHalfPressShutter()
        playBeforeCaptureVideos()
        beforeCaptureTimer.restart()
        captureView.state = "beforecapture"
    }

    function liveviewState() {
//        toast.show("Liveview State")
        console.log("[CaptureView] Liveview state")
        resetCountdownTimer()
        countdown.visible = true
        countdownTimer.restart()
        reviewImage.source = ""
        captureView.state = "liveview"
    }

    function afterCaptureState() {
//        toast.show("After Capture State")
        console.log("[CaptureView] After capture state")
        playAfterCaptureVideos()
//        afterCaptureTimer.restart()
        captureView.state = "aftercapture"
    }

    function reviewState() {
//        toast.show("Review State")
        console.log("[CaptureView] Review state")
        reviewTimer.restart()
        captureView.state = "review"
    }

    function endSessionState() {
//        toast.show("End Session State")
        console.log("[CaptureView] End session state")
//        playProcessingVideos()
//        canvasPopup.source = addFilePrefix(lastCombinedPhoto)
//        canvasPopup.open()
//        endSessionTimer.restart()
        captureView.state = "endsession"
//        liveView.stop()
        mediaPlayer.stop()

    }

    function stopAllTimers() {
        beforeCaptureTimer.stop()
        afterCaptureTimer.stop()
        reviewTimer.stop()
        endSessionTimer.stop()
        countdownTimer.stop()
        actTakePictureTimer.stop()
        console.log("[CaptureView] All timers stopped")
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
        console.log("[CaptureView] Playing before capture videos")
    }

    function playAfterCaptureVideos() {
        mediaPlayer.stop()
        mediaPlayer.playlist = settings.afterCaptureVideoPlaylist
        settings.afterCaptureVideoPlaylist.next()
        mediaPlayer.play()
        console.log("[CaptureView] Playing after capture videos")
    }

    function playProcessingVideos() {
        mediaPlayer.stop()
        mediaPlayer.playlist = settings.processingVideosPlaylist
        settings.processingVideosPlaylist.next()
        mediaPlayer.play()
        console.log("[CaptureView] Playing processing videos")
    }

    function combinePhotos() {
        toast.show("Processing photos")
        console.log("[CaptureView] Processing photos")
        if (photoList.count > 0) {
            processPhotos.combine()
//            console.log(lastCombinedPhoto)
        }
    }

    // Sony API to initialize camera, take picture, etc.
//    SonyAPI {
//        id: sonyAPI
//        saveFolder: settings.saveFolder + "/Camera"
//        onActTakePictureCompleted: {
//            actTakePictureTimer.stop()
//            reviewImage.source = addFilePrefix(actTakePictureFilePath)
//            photoList.append({"filePath": actTakePictureFilePath})
//            reviewState()
//        }

//        onExposureSignal: {
//            exposureButton.value = exposure
//        }

//    }

    // process the photos into template
    ProcessPhotos {
        id: processPhotos
        saveFolder: settings.saveFolder + "/Prints"

        templatePath: settings.templateImagePath
        templateFormat: settings.templateFormat

        model: photoList

        onCombineFinished: {
            console.log("[ProcessPhotos]" + outputPath)
            lastCombinedPhoto = outputPath

            canvasPopup.source = addFilePrefix(lastCombinedPhoto)
            canvasPopup.open()
            endSessionTimer.restart()

            if (settings.autoPrint) {
                toast.show("Autoprinting photo!")
                printPhotos.printPhoto(lastCombinedPhoto, settings.autoPrintCopies, false)
            }
            gallery.updateView()


        }
    }

    // timer to initialize to a default state
    Timer {
        id: initialTimer1
        interval: 1000
        running: true
        repeat: false

        onTriggered: {
            startState()
//            captureToolbar.locked = true
        }
    }


    // timer for before capture video
    Timer {
        id: beforeCaptureTimer
        interval: settings.beforeCaptureTimer * 1000
        running: false
        repeat: false

        onTriggered: {
            liveviewState()
        }
    }

    // timer for after capture video
    Timer {
        id: afterCaptureTimer
        running: false
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
            if (captureView.countdown.count == settings.countdownTimer) {
                sonyRemote.actHalfPressShutter()
//                sonyAPI.actHalfPressShutter()
                if (photoList.count+1 == settings.numberPhotos) {
                    toast.show("Last one! Smile!")
                }
                toast.show("Wait for Flash!")
            }

            if (captureView.countdown.count <= 0) {
                capturePhoto()
                afterCaptureState()
                resetCountdownTimer()
//                sonyAPI.actTakePicture()
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
        interval: 10000
        running: false
        repeat: false

        onTriggered: {
            capturePhoto()
        }
    }

    // timer to review photo after each capture
    Timer {
        id: reviewTimer
        interval: settings.reviewTimer * 1000
        running: false
        repeat: false

        onTriggered: {
            if (photoList.count < settings.numberPhotos) {
                beforeCaptureState()
//                afterCaptureState()
            } else {
                combinePhotos()
//                afterCaptureState()
                endSessionState()

            }
        }
    }

    // timer for end of session to print and share photos
    Timer {
        id: endSessionTimer
        running: false
        interval: settings.endSessionTimer * 1000
        repeat: false

        onTriggered: {
            canvasPopup.close()
            startState()
        }
    }

    Row {
        z: 5
        anchors {
            top: parent.top
            right: parent.right
            margins: pixel(2)
        }
        spacing: pixel(2)

        Label {
            id: batteryPercentageLabel
        }

        Label {
            id: evLabel
        }
    }


    UpDownButton {
        id: exposureButton
        min: -15
        max: 15
        value: 0
        height: pixel(12)
        visible: false
        z: 5

        anchors {
            top: parent.top
            right: parent.right
            margins: pixel(2)
        }

        onValueChanged: {
            sonyRemote.setExposureCompensation(exposureButton.value)
//            sonyAPI.setExposureCompensation(exposureButton.value)
//            toast.show("Camera Exposure Set To " + exposureButton.value)
        }

        Timer {
            id: getExposureTimer
            interval: 3000
            repeat: false
            running: true

            onTriggered: {
                sonyRemote.getExposureCompensation()
//                sonyAPI.getExposureCompensation()
            }

        }

    }

//    Timer {
//        id: autorunTimer
//        interval: 60000
//        repeat: true
//        running: autorunTimerSwitch.checked

//        triggeredOnStart: true

//        onTriggered: {
//            captureToolbar.playPauseButton.checked = true
//            captureToolbar.playPauseButton.clicked()
//        }
//    }

//    Switch {
//        id: autorunTimerSwitch
//        z: 3
//    }


    
    // ==== STATES ====
    states: [
        // ==== start state ====
        State {
            name: "start"
            PropertyChanges {
//                target: liveView
                target: sonyRemote
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
//                target: liveView
                target: sonyRemote
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
            name: "aftercapture"
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
                target: videoLoader
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

    CanvasPopup {
        id: canvasPopup
        width: mainWindow.width
        height: mainWindow.height
        anchors.centerIn: Overlay.overlay


        saveFolder: settings.saveFolder
        onClosed: {
            startState()
        }

//        Overlay.modal: GaussianBlur {
//            source: captureView
//            radius: 8
//            samples: 16
//            deviation: 3
//        }
    }
    
    
    CaptureToolbar {
        id: captureToolbar
        opacity: 0.8
        z: 10
//        y: captureView.height/2 - pixel(30)

        anchors {
            fill: parent
//            verticalCenter: parent.verticalCenter
//            right: parent.right
//            left: parent.left
        }

    }
    
        
//     live view from camera
//    SonyLiveview {
//        id: liveView
//        opacity: 0
//        scale: 0.1
//        z:1

//        flipHorizontally: settings.mirrorLiveVideoSwitch

//        width: parent.width
//        height: width / photoAspectRatio
//        anchors.horizontalCenter: parent.horizontalCenter

//    }

    SonyRemote {
        id: sonyRemote
        opacity: 0
        scale: 0.1
        z:1
        width: parent.width
        height: width / photoAspectRatio
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        flipHorizontally: settings.mirrorLiveVideoSwitch

        saveFolder: settings.saveFolder + "/Camera"
        onActTakePictureCompleted: {
            actTakePictureTimer.stop()
            reviewImage.source = addFilePrefix(filePath)
            photoList.append({"filePath": filePath})
            reviewState()
        }

        liveviewRunning: captureView.state == "liveview"

        onExposureSignal: {
            exposureButton.value = exposure
        }

        onBatteryPercentageSignal: {
            batteryPercentageLabel.text = "BAT: " + percent + "%"
        }

        onEvSignal: {
            evLabel.text = "EV: " + ev
        }
    }

    Component.onDestruction: {
//        liveView.stop()
        sonyRemote.stop()
        mediaPlayer.stop()
    }

    
    VideoOutput {
        id: videoLoader
        anchors.fill: parent
        source: mediaPlayer
        fillMode: VideoOutput.PreserveAspectFit
        opacity: 0
        scale: 0.1

    }

    Rectangle {
        id: touchArea
        anchors.fill: videoLoader
        z: 1
        color: "transparent"

        MouseArea {
            anchors.fill: parent

            onClicked: {
//                captureToolbar.playPauseButton.checked = !captureToolbar.playPauseButton.checked;
//                captureToolbar.playPauseButton.clicked()
                captureToolbar.playPause()
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
        anchors.fill: sonyRemote
//        anchors.fill: liveView
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

            Text {
                id: name
                text: qsTr("Do you want to redo?")
            }
        }


    }
    
    // end session
    Item {
        id: endSession
        anchors.fill: parent
        opacity: 0
        scale: 0.1
        
//        Gallery {
//            anchors.fill: parent
//            anchors.leftMargin: pixel(20)
//            model: photoList
//            cellWidth: mainWindow.width - pixel(40)
//        }

//        PhotoCanvas {
//            id: photoCanvas
//            width: parent.width
//            height: width / photoAspectRatio
//            imageSource: addFilePrefix(lastCombinedPhoto)
//        }

    }
    
}
