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
import QtMultimedia 5.4
import Process 1.0
import SonyAPI 1.0
import SonyLiveview 1.0
import ProcessPhotos 1.0
import PrintPhotos 1.0
import Qt.labs.folderlistmodel 2.0
import QtWebView 1.1
import CSVFile 1.0
//import MoveMouse 1.0


Window {
    id: root
    visible: true
    //    x: Screen.width / 2
    //    y: 0

    width: 1080/2
    height: 1920/2

    minimumWidth: 1080/2
    minimumHeight: 1920/2
    maximumWidth: 1080/2
    maximumHeight: 1920/2

    color: settingGeneral.bgColor
    title: qsTr("PixylBooth")

    property real pixelDensity: Screen.pixelDensity
    property string bgColor: settingGeneral.bgColor
    property string countDownColor: settingGeneral.countDownColor
    property real numberPhotos: 3
    property string lastCombinedPhoto
    property bool liveviewStarted: false
    property string templatePath: settingGeneral.templateImagePath



    Settings {
        property alias x: root.x
        property alias y: root.y
        property alias lastCombinedPhoto: root.lastCombinedPhoto
        //        property alias width: root.width
        //        property alias height: root.height
        //        property alias visibility: root.visibility
    }

    // function to assist in scaling with different resolutions and dpi
    function toPixels(percentage) {
        return percentage * Math.min(root.width, root.height);
    }

    function pixel(pixel) {
        return pixel * 4
    }

    function playVideo(path) {
        videoLoader.source = "ContentVideo.qml"
        videoLoader.item.mediaSource = path
        videoLoader.item.play()
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
            console.log(lastCombinedPhoto)
        }
    }

    function printLastCombinedPhoto() {
        console.log("Printing last combined photo!")
//        imagePrint.printPhoto(lastCombinedPhoto, printCopyCount)
    }

    function stopAllTimers() {
        beforeCaptureTimer.restart()
        reviewTimer.restart()
        endSessionTimer.restart()
        countdownTimer.restart()

        beforeCaptureTimer.stop()
        reviewTimer.stop()
        endSessionTimer.stop()
        countdownTimer.stop()
    }

    function resetCountdownTimer() {
        countdown.visible = false
        countdownTimer.stop()
        countdown.count = settingGeneral.countdownTimer
    }

    function startState() {
        var model = settingGeneral.startVideoListModel
        var randomIdx = Math.round(Math.random(1) * (model.count-1))
        var randomItem = model.get(randomIdx)
        playVideo(randomItem.filePath)

        // clear photo list and timers before capture
        photoList.clear()
        stopAllTimers()
        resetCountdownTimer()

        if (settingGeneral.liveVideoCountdownSwitch) {
            liveView.visible = true
        }

        captureView.state = "start"
    }

    function beforeCaptureState() {
        var model = settingGeneral.beforeCaptureVideoListModel
        var randomIdx = Math.round(Math.random(1) * (model.count-1))
        var randomItem = model.get(randomIdx)
        playVideo(randomItem.filePath)
        beforeCaptureTimer.start()
        captureView.state = "beforecapture"
    }

    function liveviewState() {
        resetCountdownTimer()
        countdown.visible = true
        countdownTimer.start()
        reviewImage.source = ""
        captureView.state = "liveview"
    }

    function reviewState() {
        reviewTimer.start()
        captureView.state = "review"
    }

    function endSessionState() {
        endSessionImage.source = addFilePrefix(lastCombinedPhoto)
        endSessionImage.open()
        endSessionTimer.start()
        captureView.state = "endsession"
    }

    CSVFile {
        id: csvFile
        saveFolder: settingGeneral.emailFolder
    }


//    Text {
//        text: Screen.pixelDensity
//        color: "white"
//    }

    // Sony API to initialize camera, take picture, etc.
    SonyAPI {
        id: sonyAPI
        saveFolder: settingGeneral.saveFolder
        onActTakePictureCompleted: {
            reviewImage.source = addFilePrefix(actTakePictureFilePath)
            photoList.append({"fileName": getFileName(actTakePictureFilePath), "filePath": actTakePictureFilePath})
            reviewState()
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
        saveFolder: settingGeneral.printFolder
    }

    // print class to print photos
    PrintPhotos {
        id: imagePrint
        printerName: settingGeneral.printerName
    }

//    MoveMouse {
//        id: moveMouse
//    }

//    // moves the mouse to keep screen active
//    Timer {
//        id: moveMouseTimer
//        interval: 15000
//        repeat: true
//        running: true

//        onTriggered: {
//            var min = Screen.height - 10;
//            var max = Screen.height;
//            var x = Screen.width;
//            var y = (Math.random() * (max - min + 1) + min).toFixed();
//            moveMouse.move(x, y);
////            console.log(x,y);
//        }
//    }

//    Timer {
//        id: liveviewCheckTimer
//        running: true
//        interval: 5000
//        repeat: true
//        triggeredOnStart: true

//        onTriggered: {
////            console.log(liveView.isHostConnected())
//            if (!liveView.isHostConnected()) {
//                if (settingGeneral.liveVideoCountdownSwitch || settingGeneral.liveVideoStartSwitch) {
//                    sonyAPI.startRecMode()
//                    sonyAPI.startLiveview()
//                    liveviewStarted = liveView.start()
//                    liveView.visible = settingGeneral.liveVideoStartSwitch
//                }
//            }
//        }
//    }

//    Image {
//        source: "file:///C:/Users/Vu/Pictures/dslrBooth/Templates/Jordan and Allan/blurBg.jpg"
//        height: parent.height
////        width: parent.width * 2
//        anchors.centerIn: parent
//        fillMode: Image.PreserveAspectCrop
//    }



    // timer to initialize to a default state
    Timer {
        id: initialTimer1
        interval: 100
        running: true
        repeat: false

        onTriggered: {
            startState()
        }
    }

    Timer {
        id: initialTimer2
        interval: 1000
        running: false
        repeat: false

        onTriggered: {
            liveView.start()
            liveView.visible = settingGeneral.liveVideoStartSwitch
        }
    }

    // timer for before capture video
    Timer {
        id: beforeCaptureTimer
        interval: settingGeneral.beforeCaptureTimer * 1000
        repeat: false

        onTriggered: {
            liveviewState()
        }
    }

//    // timer for half press shutter
//    Timer {
//        id: halfPressTimer
//        running: false
//        repeat: false
//        interval: (settingGeneral.countdownTimer - 1) * 1000

//        onTriggered: {
//            sonyAPI.actHalfPressShutter()
//            sonyAPI.cancelHallfPressShutter()
//        }
//    }

    // timer for countdown
    Timer {
        id: countdownTimer
        running: false
        repeat: true
        interval: 1000

        onTriggered: {
            console.log(countdown.count)
            if (countdown.count == settingGeneral.countdownTimer - 1) {
                sonyAPI.actHalfPressShutter()
            }

            if (countdown.count == 1) {
                sonyAPI.cancelHalfPressShutter()
            }


            if (countdown.count <= 0) {
                resetCountdownTimer()
                // take a picture at end of countdown
                sonyAPI.actTakePicture()
            }
            else {
                countdown.count--
            }
        }
    }

    // timer to review photo after each capture
    Timer {
        id: reviewTimer
        interval: settingGeneral.reviewTimer * 1000
        repeat: false

        onTriggered: {
            if (photoList.count < root.numberPhotos) {
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
        interval: settingGeneral.endSessionTimer * 1000
        repeat: false

        onTriggered: {
            startState()
        }
    }

    Item {
        anchors.fill: parent
        z: 10
        opacity: 0.8
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
    }




    // ==== PUT DEBUG BUTTONS HERE!!! ====
//    ColumnLayout {
//        id: debugLayout
//        z: 5
//        opacity: 0.5
//        visible: true
//        enabled: visible

//        Button {
//            text: "Start"
//            onClicked: {
//                startState()
//            }
//        }

//        Button {
//            text: "BeforeCapture"
//            onClicked: {
//                beforeCaptureState()
//            }
//        }

//        Button {
//            text: "Review"
//            onClicked: {
//                reviewState()
//            }
//        }

//        Button {
//            text: "EndSession"
//            onClicked: {
//                endSessionState()
////                photoList.append({"fileName": "DSC05695.JPG", "filePath": "C:/Users/Vu/Pictures/PixylBooth/DSC05695.JPG"})
////                photoList.append({"fileName": "DSC05695.JPG", "filePath": "C:/Users/Vu/Pictures/PixylBooth/DSC05695.JPG"})
////                photoList.append({"fileName": "DSC05695.JPG", "filePath": "C:/Users/Vu/Pictures/PixylBooth/DSC05695.JPG"})
//            }
//        }

//    }



    Item {
        id: playPauseItem
        anchors.fill: parent
        z: 10

        Image {
            id: playImage
            source: playPauseButton.checked ? "qrc:/Images/pause_white_48dp.png" : "qrc:/Images/play_arrow_white_48dp.png"
            width: pixel(60)
            height: pixel(60)
            anchors.centerIn: parent
            opacity: 0

            property bool running: playPauseButton.checked
            onRunningChanged: {
                playPauseParallelAnimation.start()
            }

            ParallelAnimation {
                id: playPauseParallelAnimation

                NumberAnimation {
                    target: playImage
                    property: "opacity";
                    from: 1;
                    to: 0;
                    duration: 800;
                    easing.type: Easing.InOutQuad;
                }

                NumberAnimation {
                    target: playImage
                    property: "scale";
                    from: 0;
                    to: 1;
                    duration: 600;
                    easing.type: Easing.InOutQuad;
                }

            }

        }

    }

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
                        opacity: settingGeneral.liveVideoStartSwitch ? 1 : 0
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
                        width: root.width * 0.9
                        height: width * 0.67
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

            // touch to start area
            Rectangle {
                id: touchStartArea
                width: root.width
                height: width
                color: "transparent"
                border.color: "#ffffff"
                border.width: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                z: 4
                visible: captureView.state == 'start'

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        beforeCaptureState()
                    }
                }
            }

            // ==== MAIN BUTTONS ====
            ColumnLayout {
                id: mainButtonsLayout
//                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                z: 5
                opacity: 0.8
                property real iconSize: pixel(10)

                Button {
                    id: playPauseButton
                    text: "Play/Pause"
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    icon.source: checked ? "qrc:/Images/play_circle_filled_white_white_48dp.png" : "qrc:/Images/pause_circle_outline_white_48dp.png"
                    icon.width: mainButtonsLayout.iconSize
                    icon.height: mainButtonsLayout.iconSize
                    display: AbstractButton.IconOnly
                    highlighted: true
                    Material.accent: Material.color(Material.Green, Material.Shade700)
                    checkable: true

                    Behavior on icon.source {
                        ParallelAnimation {
                            id: playPauseButtonParallelAnimation

                            NumberAnimation {
                                target: playPauseButton
                                property: "opacity";
                                from: 0.5;
                                to: 1;
                                duration: 800;
                                easing.type: Easing.InOutQuad;
                            }

                            NumberAnimation {
                                target: playPauseButton
                                property: "scale";
                                from: 0.8;
                                to: 1;
                                duration: 600;
                                easing.type: Easing.InOutQuad;
                            }

                        }

                    }

                    // checked means pause
                    onClicked: {
                        if (captureView.state == "beforecapture")
                            beforeCaptureTimer.running = !playPauseButton.checked
                        if (captureView.state == "liveview")
                            countdownTimer.running = !playPauseButton.checked
                        if (captureView.state == "review")
                            reviewTimer.running = !playPauseButton.checked
                        if (captureView.state == "endsession")
                            endSessionTimer.running = !playPauseButton.checked
                    }
                }

                Button {
                    id: undoLastButton
                    text: "Undo Last"
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    icon.source: "qrc:/Images/settings_backup_restore_white_48dp.png"
                    icon.width: mainButtonsLayout.iconSize
                    icon.height: mainButtonsLayout.iconSize
                    display: AbstractButton.IconOnly
                    highlighted: true
                    Material.accent: Material.color(Material.Orange, Material.Shade700)

                    ParallelAnimation {
                        id: undoLastButtonAnimation
                        NumberAnimation {
                            target: undoLastButton
                            property: "opacity";
                            from: 0.5;
                            to: 1;
                            duration: 800;
                            easing.type: Easing.InOutQuad;
                        }

                        NumberAnimation {
                            target: undoLastButton
                            property: "scale";
                            from: 0.8;
                            to: 1;
                            duration: 600;
                            easing.type: Easing.InOutQuad;
                        }

                    }


                    onClicked: {
                        undoLastButtonAnimation.start()
                        if (captureView.state != "start") {
                            resetCountdownTimer()
                            if (photoList.count > 0) {
                                photoList.remove(photoList.count-1, 1)
                            }
                            beforeCaptureState()
                        }
                    }
                }

                Button {
                    id: undoAllButton
                    text: "Undo All"
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    icon.source: "qrc:/Images/settings_backup_restore_white_48dp_all.png"
                    icon.width: mainButtonsLayout.iconSize
                    icon.height: mainButtonsLayout.iconSize
                    display: AbstractButton.IconOnly
                    highlighted: true
                    Material.accent: Material.color(Material.Cyan, Material.Shade700)

                    ParallelAnimation {
                        id: undoAllButtonAnimation
                        NumberAnimation {
                            target: undoAllButton
                            property: "opacity";
                            from: 0.5;
                            to: 1;
                            duration: 800;
                            easing.type: Easing.InOutQuad;
                        }

                        NumberAnimation {
                            target: undoAllButton
                            property: "scale";
                            from: 0.8;
                            to: 1;
                            duration: 600;
                            easing.type: Easing.InOutQuad;
                        }

                    }

                    onClicked: {
                        undoAllButtonAnimation.start()
                        startState()
                    }
                }

                Button {
                    id: fullScreenButton
                    text: "Full Screen"
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    icon.source: root.visibility == Window.FullScreen ? "qrc:/Images/fullscreen_exit_white_48dp.png" : "qrc:/Images/fullscreen_white_48dp.png"
                    icon.width: mainButtonsLayout.iconSize
                    icon.height: mainButtonsLayout.iconSize
                    display: AbstractButton.IconOnly
                    highlighted: true
                    Material.accent: Material.color(Material.Yellow, Material.Shade700)

                    onClicked: {
                        if (root.visibility == Window.FullScreen) {
                            root.showNormal();
                        }
                        else {
                            root.showFullScreen();
                        }
                    }

                    Behavior on icon.source {
                        ParallelAnimation {
                            NumberAnimation {
                                target: fullScreenButton
                                property: "opacity";
                                from: 0.5;
                                to: 1;
                                duration: 800;
                                easing.type: Easing.InOutQuad;
                            }

                            NumberAnimation {
                                target: fullScreenButton
                                property: "scale";
                                from: 0.5;
                                to: 1;
                                duration: 600;
                                easing.type: Easing.InOutQuad;
                            }

                        }

                    }
                }

                Button {
                    text: "Exit"
                    flat: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    icon.source: "qrc:/Images/cancel_white_48dp.png"
                    icon.width: mainButtonsLayout.iconSize
                    icon.height: mainButtonsLayout.iconSize
                    display: AbstractButton.IconOnly
                    highlighted: true
                    Material.accent: Material.color(Material.Grey, Material.Shade700)
                    onClicked: {
                        root.close()
                    }
                }


                ColumnLayout { }

            }

            // live view from camera
            SonyLiveview {
                id: liveView
                opacity: 0.6

                flipHorizontally: settingGeneral.mirrorLiveVideoSwitch
                height: parent.height
                width: root.width * 1.5

//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.verticalCenter: parent.verticalCenter

//                width: root.width - pixel(10)
//                height: width * 0.75
//                y: pixel(20)
//                x: (root.width - width)/2


            }

            // loader for all videos
            Loader {
                id: videoLoader
                anchors.fill: parent
                opacity: 1
            }

            // countdown display
            Countdown {
                id: countdown
                anchors.fill: liveView
                textColor: root.countDownColor
                opacity: 0
                z: 4
            }



            // review image
            Rectangle {
                id: review
                width: root.width - pixel(10)
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
                    cellWidth: root.width - pixel(40)

                }

                ImagePopup {
                    id: endSessionImage
                    anchors.centerIn: endSession
                    width: root.width * 0.9
                    height: width * 0.67
                }

            }

        // ==== PAGES ====
        }
        Item {
            Gallery {
                id: gallery
                anchors.fill: parent
                folder: addFilePrefix(settingGeneral.printFolder)
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
                id: settingGeneral
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






































































