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

Window {
    id: root
    visible: true
    x: 0
    y: 0
    width: 1080
    height: 1920
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
        if (a.search("file ://") >= 0){
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

//    Timer {
//        id: mainTimer
//        interval: 6000
//        triggeredOnStart: true
//        repeat: true

//        onTriggered: {
//            switch (captureView.state) {
//                case "start":
//                    captureView.state = "beforecapture";
//                    break;
//                case "beforecapture":
//                    captureView.state = "liveview";
//                    root.currentPhoto++
//                    break;
////                case "liveview":
////                    captureView.state = "review";
////                    break;

//                case "review":
//                    if (root.currentPhoto < root.numberPhotos) {
//                        captureView.state = "beforecapture";
//                    } else {
//                        captureView.state = "start"
//                        root.currentPhoto = 0
//                        mainTimer.stop()
//                    }
//                    break;

//            }


//        }
//    }

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
//                mainTimer.stop()
            }
        }
    }




    SwipeView {
        id: swipeview
//        currentIndex: tabBar.currentIndex
        anchors.fill: parent

        Item {
            id: captureView

            ColumnLayout {
                z: 10
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
                    text: "liveview"
                    onClicked: {
                        captureView.state = "liveview"
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
                        width: 160
                        height: 120
                        y: 0
                        x: root.width - width
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
                        opacity: 1
                        width: 160
                        height: 120
                        y: 0
                        x: root.width - width
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
                        width: root.width * 0.8
                        height: width * 0.75
                        x: (root.width - width) / 2
                        y: 0
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
            
            LiveView {
                id: liveView
//                width: root.width * 0.8
//                height: width * 0.75
//                x: (root.width - width) / 2
//                y: 50
//                opacity: 0
                
//                liveViewImageSource: root.addFilePrefix(settingGeneral.liveViewImage)

                opacity: 1
                width: 160
                height: 120
                y: 0
                x: root.width - width
                z: 2
            }

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
                width: root.width * 0.8
                height: width * 1080/1616
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

//    TabBar {
//        id: tabBar
//        x: 864
//        anchors.top: parent.top
//        anchors.horizontalCenter: parent.horizontalCenter
//        currentIndex: swipeview.currentIndex
//        Material.elevation: 1

//        TabButton {
//            text: "liveview"
//            width: implicitWidth
//        }


//        TabButton {
//            text: "General"
//            width: implicitWidth
//        }


//        TabButton {
//            text: "Camera"
//            width: implicitWidth
//        }

//        TabButton {
//            text: "Color"
//            width: implicitWidth
//        }


//        TabButton {
//            text: "Videos"
//            width: implicitWidth
//        }


//    }

}






































































