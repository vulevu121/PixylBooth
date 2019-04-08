import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.1
//import QtGraphicalEffects 1.12
import QtMultimedia 5.4
import Process 1.0
import BackEnd 1.0
import LiveViewStream 1.0
//import ImageItem 1.0

Window {
    id: root
    visible: true
    x: 0
    y: 0

    width: 1080
    height: width * 1920 / 1080

//    maximumHeight:
//    minimumWidth: 1080/2
//    minimumHeight: 1920/2
//    maximumWidth: 1080/2
//    maximumHeight: 1920/2

    color: bgColor
    title: qsTr("PixylBooth")

    property real pixelDensity: Screen.pixelDensity
    property string bgColor: "#222"
    property string countDownColor: "#fff"
    property real numberPhotos: 3
    property real currentPhoto: 0
    property string lastPhotoPath: ""


    Settings {
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
        property alias visibility: root.visibility
    }

    Settings {
        category: "Color"
        property alias backgroundColor: root.bgColor
        property alias countDownColor: root.countDownColor
    }

    function toPixels(percentage) {
        return percentage * Math.min(root.width, root.height);
    }

    function playVideo(path) {
        contentLoader.source = "ContentVideo.qml"
        contentLoader.item.mediaSource = path
        contentLoader.item.play()

    }

    function getFileName(path) {
        var pathstring = String(path)
        var pathstringsplit = pathstring.split("/")
        return pathstringsplit[pathstringsplit.length-1]
    }

    function stripFilePrefix(a) {
        if (a.search("C:") >= 0) {
            return a.replace("file:///", "")
        }
        return a.replace("file://", "")
    }

    function addFilePrefix(a) {
        if (a.search("file://") >= 0){
            return(a)
        }

        var filePrefix = ""

        if (a.search("C:") >= 0) {
            filePrefix = "file:///".concat(String(a)).replace("\r", "").replace("\n", "")
        } else {
            filePrefix = "file://".concat(String(a)).replace("\r", "").replace("\n", "")
        }
//        console.log(filePrefix)
        return(filePrefix)
    }

    function setcountDownColor(color) {
        countDownColor = color
    }

    function setBgColor(color) {
        bgColor = color
    }

    function saveCapture() {
//        var processPath = settingAction.pythonPath
//        var arg1 = settingAction.captureAction
//        var arg2 = settingGeneral.saveFolder
//        console.log(processPath)
//        console.log(arg1)
//        console.log(arg2)

//        process.start(processPath, [arg1, arg2])

//        backend.saveFolder = settingGeneral.saveFolder

        backend.actTakePicture()
    }

    BackEnd {
        id: backend
        saveFolder: settingGeneral.saveFolder
        onActTakePictureCompleted: {
            reviewImage.source = addFilePrefix(actTakePictureFilePath)
            console.log(actTakePictureFilePath)

//            var result = String(process.readAllStandardOutput())
//            root.lastPhotoPath = addFilePrefix(result)
//            console.log(root.lastPhotoPath)
//            reviewImage.source = root.lastPhotoPath
            captureView.state = "review"
        }
    }


    Timer {
        id: initialTimer
        interval: 1000
        running: true
        repeat: false

        onTriggered: {
            captureView.state = "start"
            if(settingCamera.liveVideoCountdownSwitch || settingCamera.liveVideoStartSwitch) {
                backend.startLiveview()
                liveView.start()
            }
        }
    }

    Timer {
        id: beforeCaptureTimer
        interval: 6000
        repeat: false

        onTriggered: {
            captureView.state = "liveview"
            root.currentPhoto++
        }
    }

    Timer {
        id: reviewTimer
        interval: 6000
        repeat: false

        onTriggered: {
            if (root.currentPhoto < root.numberPhotos) {
                captureView.state = "beforecapture";
            } else {
                captureView.state = "start"
                root.currentPhoto = 0
            }
        }
    }


    RowLayout {
        anchors.fill: parent
        z: 10

        RowLayout {}

        Button {
            text: "Full Screen"
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            icon.source: root.visibility == Window.FullScreen ? "qrc:/Images/fullscreen_exit_white_48dp.png" : "qrc:/Images/fullscreen_white_48dp.png"
            icon.width: 48
            icon.height: 48
            display: AbstractButton.IconOnly
            background: Rectangle {
                color: "transparent"
            }

            onClicked: {
                if (root.visibility == Window.FullScreen) {
                    root.showNormal();
                }
                else {
                    root.showFullScreen();
                }
            }
        }

        Button {
            text: "Undo"
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            icon.source: "qrc:/Images/refresh_white_48dp.png"
            icon.width: 48
            icon.height: 48
            display: AbstractButton.IconOnly
            background: Rectangle {
                color: "transparent"
            }
        }

        Button {
            text: "Exit"
            flat: true
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            icon.source: "qrc:/Images/cancel_white_48dp.png"
            icon.width: 48
            icon.height: 48
            display: AbstractButton.IconOnly
            background: Rectangle {
                color: "transparent"
            }
            onClicked: {
                root.close()
            }
        }

    }

    SwipeView {
        id: swipeview
        currentIndex: tabBar.currentIndex
        anchors.fill: parent

        Item {
            id: captureView
//            state: "start"

            ColumnLayout {
                id: debugLayout
                z: 10
                visible: true

                Button {
                    text: "Start"
                    onClicked: {
                        captureView.state = "start"
                    }
                }

                Button {
                    text: "BeforeCapture"
                    onClicked: {
                        captureView.state = "beforecapture"
                    }
                }

                Button {
                    text: "Start Liveview"
                    onClicked: {
//                        backend.startLiveview()
//                        liveImageItem.start()
                        liveView.start()
                    }
                }

                Button {
                    text: "Stop Liveview"
                    onClicked: {
                        liveView.stop()
                    }
                }

                Button {
                    text: "Review"
                    onClicked: {
                        captureView.state = "review"
                    }
                }

                Process {
                        id: process
                        onReadyRead: {
                            var result = String(process.readAllStandardOutput())
                            root.lastPhotoPath = addFilePrefix(result)
                            console.log(root.lastPhotoPath)
                            reviewImage.source = root.lastPhotoPath
                            captureView.state = "review"
                        }
                }

                Button {
                    id: captureButton
                    text: "Capture Action"

                    onClicked: {
                        backend.actTakePicture()
//                        saveCapture()
                    }
                }



//                Button {
//                    id: liveviewButton
//                    text: "Live View"

//                    onClicked: {
//                        console.log(root.stripFilePrefix(settingAction.liveviewAction))
//                        process.start("python", [root.stripFilePrefix(settingAction.liveviewAction)])
//                    }
//                }

//                Button {
//                    id: closeLiveview
//                    text: "Stop Live View"
//                    onClicked: {
//                        console.log(process.kill())
//                    }
//                }

//                TextField {
//                        text: backend.userName
//                        placeholderText: qsTr("User name")
//                        onTextChanged: backend.userName = text
//                }

//                TextField {
//                        text: backend.saveFolder
//                }



            }

            states: [
                State {
                    name: "start"
                    PropertyChanges {
                        target: liveView
                        opacity: 1
                        width: root.width * 0.5
                        height: width * 2 / 3
                        y: 60
                        x: (root.width - width)/2
                        visible: settingCamera.liveVideoStartSwitch
                    }
                    PropertyChanges {
                        target: contentLoader
                        opacity: 1
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 0
                    }
                    StateChangeScript {
                        script: {
                            var model = settingVideos.startVideoListModel
                            var randomIdx = Math.round(Math.random(1) * (model.count-1))
                            var randomItem = model.get(randomIdx)
                            playVideo(randomItem.filePath)
                            backend.startRecMode()
                        }
                    }
                },

                State {
                    name: "beforecapture"
                    PropertyChanges {
                        target: liveView
                        opacity: 0
//                        width: 320
//                        height: 240
//                        y: 60
//                        x: (root.width - width)/2
                    }
                    PropertyChanges {
                        target: contentLoader
                        opacity: 1
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 0
                    }
                    StateChangeScript {
                        script: {
                            var model = settingVideos.beforeCaptureVideoListModel
                            var randomIdx = Math.round(Math.random(1) * (model.count-1))
                            var randomItem = model.get(randomIdx)
                            playVideo(randomItem.filePath)

                            beforeCaptureTimer.start()
                        }
                    }
                },

                State {
                    name: "liveview"
                    PropertyChanges {
                        target: liveView
                        opacity: 1
                        width: root.width
                        height: width * 0.75
                        x: (root.width - width) / 2
                        y: 0
                        visible: settingCamera.liveVideoCountdownSwitch
                    }
                    PropertyChanges {
                        target: contentLoader
                        opacity: 0
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 1
                    }
                    StateChangeScript {
                        script: {
                            countdownTimer.visible = true
                            countdownTimer.count = settingGeneral.captureTimer
                            captureTimer.start()
                            reviewImage.source = ""
                        }
                    }
                },

                State {
                    name: "review"
                    PropertyChanges {
                        target: liveView
                        opacity: 0
//                        width: root.width * 0.8
//                        height: width * 0.75
//                        x: (root.width - width) / 2
//                        y: 0
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 0
                    }
                    PropertyChanges {
                        target: contentLoader
                        opacity: 0
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 0
                    }
                    PropertyChanges {
                        target: review
                        opacity: 1
                    }
                    StateChangeScript {
                        script: {
                            reviewTimer.start()
                        }
                    }

                }
            ]

            transitions: Transition {
                NumberAnimation {
                    properties: "opacity,x,y,width,height";
                    duration: 200;
                    easing.type: Easing.InOutQuad;
                }
            }

            LiveViewStream {
                id: liveView
                opacity: 1
                width: root.width * 0.5
                height: width * 2 / 3
                y: 0
                x: root.width - width
                z: 2

            }

//            LiveView {
//                id: liveView
////                width: root.width * 0.8
////                height: width * 0.75
////                x: (root.width - width) / 2
////                y: 50
////                opacity: 0

////                liveViewImageSource: root.addFilePrefix(settingGeneral.liveViewImage)

//                opacity: 1
//                width: root.width * 0.5
//                height: width * 2 / 3
//                y: 0
//                x: root.width - width
//                z: 2
//            }

            Loader {
                id: contentLoader
                anchors.fill: parent
                opacity: 1
            }



            Countdown {
                id: countdownTimer
                anchors.fill: liveView
                textColor: root.countDownColor
                opacity: 0
                z: 5
            }

            Timer {
                id: captureTimer
                running: false
                repeat: true
                interval: 1000

                onTriggered: {
                    console.log(countdownTimer.count)
                    if (countdownTimer.count <= 0) {
                        countdownTimer.count = countdownTimer.timer
                        captureTimer.stop()
                        countdownTimer.visible = false
                        saveCapture()
                    }
                    else {
                        countdownTimer.count--
                    }
                }
            }


            Rectangle {
                id: mouseArea
                width: 400
                height: 400
                color: "transparent"
                border.color: "#ffffff"
                border.width: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (captureView.state == "start") {
                            captureView.state = "beforecapture"
                         }

                    }
                }
            }

            Rectangle {
                id: review
                width: root.width
                height: width * reviewImage.sourceSize.height / reviewImage.sourceSize.width
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0
                color: "transparent"
                Image {
                    id: reviewImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
//                    source: "file:///C:/Users/Vu/Documents/Sony-Camera-API/example/DCIM/DSC04492.JPG"
                }
            }

        }
        Item {
            SettingGeneral {
                id: settingGeneral
                anchors.fill: parent
            }

        }
        Item {
            SettingCamera {
                id: settingCamera
                anchors.fill: parent
            }
        }

        Item {
            SettingAction {
                id: settingAction
                anchors.fill: parent
            }
        }

        Item {
            SettingColor {
                id: settingColors
                anchors.fill: parent

                Component.onCompleted: {
                    countDownColorSelected.connect(root.setcountDownColor)
                    bgColorSelected.connect(root.setBgColor)
                }
            }
        }


        Item {
            SettingVideo {
                id: settingVideos
                anchors.fill: parent
            }
        }

    }


    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: root.height
        width: root.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: root.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    TabBar {
        id: tabBar
        x: 864
        position: TabBar.Footer
        currentIndex: swipeview.currentIndex
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        Material.elevation: 1
        background: Rectangle {
            color: "transparent"
        }


        TabButton {
            text: "Start"
            width: implicitWidth
            icon.source: "qrc:/Images/camera_white_48dp.png"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
        }


        TabButton {
            text: "General"
            width: implicitWidth
            icon.source: "qrc:/Images/settings_white_48dp.png"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
        }


        TabButton {
            text: "Camera"
            width: implicitWidth
            icon.source: "qrc:/Images/camera_alt_white_48dp.png"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
        }

        TabButton {
            text: "Action"
            width: implicitWidth
            icon.source: "qrc:/Images/apps_white_48dp.png"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
        }

        TabButton {
            text: "Color"
            width: implicitWidth
            icon.source: "qrc:/Images/color_lens_white_48dp.png"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
        }


        TabButton {
            text: "Videos"
            width: implicitWidth
            icon.source: "qrc:/Images/video_library_white_48dp.png"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
        }


    }

}






































































