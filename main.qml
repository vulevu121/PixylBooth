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
//import MoveMouse 1.0


Window {
    id: mainWindow
    visible: true
    //    x: Screen.width / 2
    //    y: 0

    width: 1080/2
    height: 1920/2

    minimumWidth: 1080/2
    minimumHeight: 1920/2
    maximumWidth: 1080/2
    maximumHeight: 1920/2

    color: settings.bgColor
    title: qsTr("PixylBooth")

    property real pixelDensity: Screen.pixelDensity
    property string bgColor: settings.bgColor
    property string countDownColor: settings.countDownColor
    property real numberPhotos: 3
    property string lastCombinedPhoto
    property bool liveviewStarted: false
    property string templatePath: settings.templateImagePath
    property string username: usernameField.text
    property string password: passwordField.text
    property string idToken
    property string refreshToken
    property real photoAspectRatio: 3/2

    Settings {
        id: mainSettings
        property alias x: mainWindow.x
        property alias y: mainWindow.y
        property alias lastCombinedPhoto: mainWindow.lastCombinedPhoto
        property alias username: mainWindow.username
        property alias password: mainWindow.password
        property alias rememberMe: rememberMeCheckBox.checked
        property alias idToken: mainWindow.idToken
        property alias refreshToken: mainWindow.refreshToken
        property alias cameraDeviceId: camera.deviceId
    }

    Settings {
        id: templateSettings
        category: "Template"
        property string jsonString
    }


    // function to assist in scaling with different resolutions and dpi
    function toPixels(percentage) {
        return percentage * Math.min(mainWindow.width, mainWindow.height);
    }

    function pixel(pixel) {
        return pixel * 4
    }


    function getFileName(path) {
        var pathstring = String(path)
        var pathstringsplit = pathstring.split("/")
        return pathstringsplit[pathstringsplit.length-1]
    }

    function stripFilePrefix(path) {
        var newPath = String(path)
        newPath = newPath.replace("file:///", "").replace("file://", "")
        return newPath
    }

    function addFilePrefix(path) {
        if (path.search("file://") >= 0)
            return path

        var filePrefix = "file://"

        if (path.length > 2 && path[1] === ':')
            filePrefix += "/"

        return filePrefix.concat(path)
    }


    function combinePhotos() {
        // make the template as the first image in the list
        var photos = templatePath.concat(";")

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


    function stopAllTimers() {
        beforeCaptureTimer.stop()
        reviewTimer.stop()
        endSessionTimer.stop()
        countdownTimer.stop()
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

    }

    function playAfterCaptureVideos() {
        mediaPlayer.stop()
        mediaPlayer.playlist = settings.afterCaptureVideoPlaylist
        settings.afterCaptureVideoPlaylist.next()
        mediaPlayer.play()
    }

    function startState() {
        playStartVideos()

        // clear photo list and timers before capture
        photoList.clear()
        stopAllTimers()
        resetCountdownTimer()


        sonyAPI.start()
        toast.show("Initializing Sony camera")

        playPauseButton.checked = false
        liveView.visible = settings.showLiveVideoOnStartSwitch
        captureView.state = "start"
    }

    function beforeCaptureState() {
        playBeforeCaptureVideos()
        beforeCaptureTimer.restart()
        captureView.state = "beforecapture"

    }

    function liveviewState() {
        resetCountdownTimer()
        countdown.visible = true
        countdownTimer.restart()
        reviewImage.source = ""
        captureView.state = "liveview"
        liveView.visible = settings.showLiveVideoOnCountdownSwitch
    }

    function reviewState() {
        reviewTimer.restart()
        captureView.state = "review"
    }

    function endSessionState() {
        endSessionPopup.source = addFilePrefix(lastCombinedPhoto)
        endSessionPopup.open()
        endSessionTimer.restart()
        captureView.state = "endsession"
//        liveView.stop()
    }

    Firebase {
        id: firebase

        idToken: mainWindow.idToken
        refreshToken: mainWindow.refreshToken

        onUserAuthenticated: {
            mainWindow.idToken = idToken
            mainWindow.refreshToken = refreshToken
        }

        onUserNotAuthenticated: {
            toast.show(msg)
        }

        onUserInfoReceived: {
            toast.show("Login successful")
            loadingBar.running = false
            loginPopup.close()
        }

    }


    CSVFile {
        id: csvFile
        saveFolder: settings.emailFolder
    }


//    Text {
//        text: Screen.pixelDensity
//        color: "white"
//    }

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

    // email list
    ListModel {
        id: emailList

    }

    // a list model for storing photo paths
    ListModel {
        id: photoList

    }


    // process the photos into tempalte
    ProcessPhotos {
        id: processPhotos
        saveFolder: settings.printFolder

    }

    // print class to print photos
    PrintPhotos {
        id: imagePrint
        printerName: settings.printerName
    }



    // timer to initialize to a default state
    Timer {
        id: initialTimer1
        interval: 100
        running: true
        repeat: false

        onTriggered: {
            startState()
//            liveView.enabled = true
        }
    }

//    Timer {
//        id: initialTimer2
//        interval: 1000
//        running: false
//        repeat: false

//        onTriggered: {
////            liveView.start()
//            liveView.visible = settings.showLiveVideoOnCountdownSwitch
//        }
//    }

    // timer for before capture video
    Timer {
        id: beforeCaptureTimer
        interval: settings.beforeCaptureTimer * 1000
        repeat: false

        onTriggered: {
            liveviewState()
        }
    }


    // timer for countdown
    Timer {
        id: countdownTimer
        running: false
        repeat: true
        interval: 1000

        onTriggered: {
//            console.log(countdown.count)

            if (countdown.count == settings.countdownTimer - 1) {
                sonyAPI.actHalfPressShutter()
            }

            if (countdown.count == 2) {
                sonyAPI.cancelHalfPressShutter()
            }


            if (countdown.count <= 0) {
                resetCountdownTimer()
                // take a picture at end of countdown
                sonyAPI.actTakePicture()
                toast.show("Capturing photo " + (photoList.count+1))
                actTakePictureTimer.restart()
            }
            else {
                countdown.count--
            }

//            toast.show("Counting down..." + countdown.count)
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
            if (photoList.count < mainWindow.numberPhotos) {
                beforeCaptureState()
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

//    Timer {
//        id: repeatTimer
//        interval: 86000
//        repeat: true
//        running: true
//        onTriggered: {
//            playPauseButton.toggle()
//            playPauseButton.clicked()
//        }
//    }

//    Item {
//        anchors.fill: parent
//        z: 10
//        opacity: 0.8
//        Image {
//            anchors.top: parent.top
//            anchors.topMargin: pixel(40)
//            anchors.horizontalCenter: parent.horizontalCenter
//            source: addFilePrefix("C:/Users/Vu/Documents/PixylBooth/Ava/NiceToMeetYou.gif")
//        }

//        BorderImage {
//            id: speechBubble
//            source: addFilePrefix("C:/Users/Vu/Documents/PixylBooth/Ava/SpeechBubble.gif")
//            width: speechText.width + pixel(10); height: speechText.height + pixel(20)
//            border.left: 41; border.top: 12
//            border.right: 15; border.bottom: 33
//            anchors.top: parent.top
//            anchors.topMargin: pixel(40)
//            anchors.horizontalCenterOffset: pixel(20)
//            anchors.horizontalCenter: parent.horizontalCenter

//            Text {
//                id: speechText
//                text: qsTr("Hi, my name is Ava!\nI'm here to help you!")
//                color: "black"
//                font.pixelSize: pixel(5)
//                anchors.centerIn: parent
//                anchors.verticalCenterOffset: -pixel(5)
//            }
//        }
//    }


//    LoginScreen {
//        id: login
//        anchors.fill: parent
//        z: 20
//    }

//    ImagePopup {
//        id: imagePopup
//        anchors.centerIn: root
//        width: root.width * 0.9
//        height: width / photoAspectRatio

//        Overlay.modal: GaussianBlur {
//            source: galleryView
//            radius: 8
//            samples: 16
//            deviation: 3
//        }
//    }

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

    Popup {
        id: loginPopup
        modal: true
        closePolicy: Popup.NoAutoClose
        anchors.centerIn: parent

        background: Rectangle {
            color: Material.background
            opacity: 0.7
            radius: pixel(3)
            clip: true

            Rectangle {
                width: parent.width
                height: 3
                id: barRect
                color: Material.background

                Rectangle {
                    id: movingRect
                    width: 40
                    x: -width
                    height: parent.height
                    color: Material.accent
                }

                PropertyAnimation {
                    id: loadingBar
                    target: movingRect
                    property: "x"
                    from: -movingRect.width
                    to: barRect.width
                    duration: 1000
                    easing.type: Easing.InOutQuad
                    running: false
                    loops: Animation.Infinite
                }
            }
        }


        Overlay.modal: GaussianBlur {
            source: captureView
            radius: 8
            samples: 16
            deviation: 3
        }

//        Component.onCompleted: {
//            if (refreshToken.search("eyJhbGciOiJSUzI1NiIsImtpZCI6IjY2NDNkZDM5") < 0) {
//                loginPopup.open()
//                if (rememberMeCheckBox.checked) {
//                    usernameField.text = username
//                    passwordField.text = password
//                }
//            }
//        }

        GridLayout {
            id: gridLayout
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 2

            Label {
                text: qsTr("Username")
                font.pixelSize: usernameField.font.pixelSize
                color: Material.foreground
            }

            TextField {
                id: usernameField
                text: ""
                Layout.minimumWidth: 200
                selectByMouse: true
//                placeholderText: "Enter your email"
                Keys.onReturnPressed: {
                    loginButton.clicked()
                }

            }

            Label {
                text: qsTr("Password")
                font.pixelSize: passwordField.font.pixelSize
                color: Material.foreground
            }

            TextField {
                id: passwordField
                Layout.minimumWidth: 200
                selectByMouse: true
//                placeholderText: "Enter your password"
                echoMode: TextInput.Password
                Keys.onReturnPressed: {
                    loginButton.clicked()
                }

            }

            CheckBox {
                id: rememberMeCheckBox
                text: qsTr("Remember")
            }

            Button {
                id: loginButton
                text: qsTr("Login")
                onClicked: {
                    loadingBar.running = true
                    firebase.authenticate(usernameField.text.toString(), passwordField.text.toString())
                }
            }

        }

    }



    // ==== PUT DEBUG BUTTONS HERE!!! ====
    DebugButtons {}


    // ==== SWIPEVIEW ====
    SwipeView {
        id: swipeview
        currentIndex: tabBar.currentIndex
        anchors.fill: parent

        Item {
            id: captureView

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
                    }
                    PropertyChanges {
                        target: countdown
                        opacity: 0
                    }
                    PropertyChanges {
                        target: endSession
                        opacity: 0
                    }

                },
                // ==== beforecapture state ====
                State {
                    name: "beforecapture"
                    PropertyChanges {
                        target: liveView
                        opacity: 0
                        scale: 0.1
                    }
                    PropertyChanges {
                        target: videoLoader
                        opacity: 1
                    }
                    PropertyChanges {
                        target: countdown
                        opacity: 0
                    }
                    PropertyChanges {
                        target: endSession
                        opacity: 0
                    }
                },


                // ==== liveview state ====
                State {
                    name: "liveview"
                    PropertyChanges {
                        target: liveView
                        opacity: 1
                        width: mainWindow.width * 0.9
                        height: width / photoAspectRatio
                        x: 0
                        y: pixel(30)
                    }
                    PropertyChanges {
                        target: videoLoader
                        opacity: 0
                    }
                    PropertyChanges {
                        target: countdown
                        opacity: 1
                    }
                    PropertyChanges {
                        target: endSession
                        opacity: 0
                    }
                },
                // ==== review state ====
                State {
                    name: "review"
                    PropertyChanges {
                        target: liveView
                        opacity: 0
                        scale: 0.1

                    }
                    PropertyChanges {
                        target: countdown
                        opacity: 0
                    }
                    PropertyChanges {
                        target: videoLoader
                        opacity: 0
                    }
                    PropertyChanges {
                        target: countdown
                        opacity: 0
                    }
                    PropertyChanges {
                        target: review
                        opacity: 1
                    }
                    PropertyChanges {
                        target: endSession
                        opacity: 0
                    }
                },
                // ==== endsession state ====
                State {
                    name: "endsession"

                    PropertyChanges {
                        target: liveView
                        opacity: 0
                        scale: 0.1
                    }
                    PropertyChanges {
                        target: countdown
                        opacity: 0
                    }
                    PropertyChanges {
                        target: videoLoader
                        opacity: 0
                    }
                    PropertyChanges {
                        target: countdown
                        opacity: 0
                    }
                    PropertyChanges {
                        target: review
                        opacity: 0
                    }

                    PropertyChanges {
                        target: endSession
                        opacity: 1
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


            Button {
                id: playPauseButton
                text: "Play/Pause"
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                icon.source: checked ? "qrc:/Images/pause_white_48dp.png" : "qrc:/Images/play_arrow_white_48dp.png"
                icon.width: pixel(10)
                icon.height: pixel(10)
                anchors.centerIn: parent
                display: AbstractButton.IconOnly
                highlighted: false
                flat: false
                opacity: 0.3
                background: Rectangle {
                    color: "transparent"
                }

                Material.accent: Material.color(Material.Green, Material.Shade700)
                checkable: true
                z: 10
                scale: 3
                smooth: true

                Behavior on icon.source {
                    ParallelAnimation {
                        id: playPauseButtonParallelAnimation

                        NumberAnimation {
                            target: playPauseButton
                            property: "opacity";
                            from: 0.1;
                            to: 0.3;
                            duration: 800;
                            easing.type: Easing.InOutQuad;
                        }

                        NumberAnimation {
                            target: playPauseButton
                            property: "scale";
                            from: 2;
                            to: 3;
                            duration: 600;
                            easing.type: Easing.InOutQuad;
                        }
                    }
                }

                onClicked: {
                    var playState = playPauseButton.checked

                    if (captureView.state == "start") {
//                        liveView.start()
                        beforeCaptureState()
                    }

                    if (captureView.state == "beforecapture") {
                        beforeCaptureTimer.running = playState
                    }

                    if (captureView.state == "liveview") {
                        countdownTimer.running = playState
                    }

                    if (captureView.state == "review") {
                        reviewTimer.running = playState
                    }

                    if (captureView.state == "endsession") {
                        endSessionTimer.running = playState
                    }

                }
            }


            // ==== MAIN BUTTONS ====
            CaptureToolbar {}



            // live view from camera
//            SonyLiveview {
//                id: liveView
//                opacity: 0.6
////                enabled: settings.showLiveVideoOnCountdownSwitch

//                flipHorizontally: settings.mirrorLiveVideoSwitch

//                width: mainWindow.width * 0.9
//                height: width / photoAspectRatio
//                anchors.horizontalCenter: parent.horizontalCenter

//            }

            ListView {
                x: 0
                y: 0
                z: 30
                width: 100
                height: 300


                model: QtMultimedia.availableCameras
                delegate: Text {
                    text: modelData.displayName

                    color: "white"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            camera.deviceId = modelData.deviceId
                            console.log(modelData.deviceId)
                        }
                    }
                }
            }

            Camera {
                id: camera
                captureMode: Camera.CaptureStillImage
                deviceId: mainSettings.cameraDeviceId
            }

            VideoOutput {
                id: liveView

                visible: true
                width: parent.width
                height: width / photoAspectRatio
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                Rectangle {
                    anchors.fill: parent
                    border.color: "white"
                    border.width: 1
                    color: "transparent"
                }

//                source: camera
            }

            VideoOutput {
                id: videoLoader
                anchors.fill: parent
                source: mediaPlayer
                fillMode: VideoOutput.PreserveAspectFit

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
                textColor: mainWindow.countDownColor
                opacity: 0
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


                Gallery {
                    anchors.fill: parent
                    anchors.leftMargin: pixel(20)
                    model: photoList
                    cellWidth: mainWindow.width - pixel(40)
                }

//                Image {
//                    id: endSessionImage
//                }



            }

        // ==== PAGES ====
        }
        Item {
            id: galleryView

            Gallery {
                id: gallery
                anchors.fill: parent
                folder: addFilePrefix(settings.printFolder)
            }
        }
//        Item {
//            WebView {
//                id: webView
//                anchors.fill: parent
//                url: "https://play.famobi.com/1000-blocks"
//                z: 10
//            }
//        }

        Item {
            SettingGeneral {
                id: settings
                anchors.fill: parent
            }
        }


    }

    // ==== VIRTUAL KEYBOARD ====
//    InputPanel {
//        id: inputPanel
//        z: 99
//        x: 0
//        y: root.height
//        width: root.width

//        states: State {
//            name: "visible"
//            when: inputPanel.active
//            PropertyChanges {
//                target: inputPanel
//                y: root.height - inputPanel.height
//            }
//        }
//        transitions: Transition {
//            from: ""
//            to: "visible"
//            reversible: true
//            ParallelAnimation {
//                NumberAnimation {
//                    properties: "y"
//                    duration: 250
//                    easing.type: Easing.InOutQuad
//                }
//            }
//        }
//    }

    ToastManager {
        id: toast
    }


    // ==== TAB BAR STUFF ====
    TabBar {
        id: tabBar
        position: TabBar.Footer
        currentIndex: swipeview.currentIndex
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        Material.elevation: 1
        opacity: 1
        background: Rectangle {
            color: Material.background
            radius: pixel(3)
         }

        property real iconSize: pixel(10)


        TabButton {
            text: "Start"
            width: implicitWidth
            icon.source: "qrc:/Images/camera_white_48dp.png"
            icon.width: tabBar.iconSize
            icon.height: tabBar.iconSize
            display: AbstractButton.IconOnly

        }

        TabButton {
            text: "Play"
            width: implicitWidth
            icon.source: "qrc:/Images/play_circle_filled_white_white_48dp.png"
            icon.width: tabBar.iconSize
            icon.height: tabBar.iconSize
            display: AbstractButton.IconOnly
        }
//        TabButton {
//            text: "Game"
//            width: implicitWidth
//            icon.source: "qrc:/Images/apps_white_48dp.png"
//            icon.width: iconSize
//            icon.height: iconSize
//            display: AbstractButton.IconOnly
//        }

        TabButton {
            text: "General"
            width: implicitWidth
            icon.source: "qrc:/Images/settings_white_48dp.png"
            icon.width: tabBar.iconSize
            icon.height: tabBar.iconSize
            display: AbstractButton.IconOnly
        }


    }

}






































































