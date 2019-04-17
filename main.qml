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
import QtMultimedia 5.4
import Process 1.0
import SonyAPI 1.0
import SonyLiveview 1.0
import PrintPhotos 1.0

Window {
    id: root
    visible: true
    x: Screen.width / 2
    y: 0

    width: 1080/2
    height: 1920/2

    minimumWidth: 1080/2
    minimumHeight: 1920/2
    maximumWidth: 1080/2
    maximumHeight: 1920/2

    color: bgColor
    title: qsTr("PixylBooth")

    property real pixelDensity: Screen.pixelDensity
    property string bgColor: "#222"
    property string countDownColor: "#fff"
    property real numberPhotos: 3
//    property real currentPhoto: 0
    property string lastPhotoPath: ""

    property string photoPaths: "C:/Users/Vu/Pictures/dslrBooth/Templates/Mia Pham/background.png;C:/Users/Vu/Pictures/DSC05103.JPG;C:/Users/Vu/Pictures/DSC05104.JPG;C:/Users/Vu/Pictures/DSC05105.JPG"
    property string templatePath: "C:/Users/Vu/Pictures/dslrBooth/Templates/Mia Pham/background.png"

    Settings {
//        property alias x: root.x
//        property alias y: root.y
//        property alias width: root.width
//        property alias height: root.height
//        property alias visibility: root.visibility
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
        videoLoader.source = "ContentVideo.qml"
        videoLoader.item.mediaSource = path
        videoLoader.item.play()

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
//        sonyAPI.saveFolder = settingGeneral.saveFolder
        sonyAPI.actTakePicture()
    }

    SonyAPI {
        id: sonyAPI
        saveFolder: settingGeneral.saveFolder
        onActTakePictureCompleted: {
//            currentPhoto += 1
            reviewImage.source = addFilePrefix(actTakePictureFilePath)
            photoList.append({"path": actTakePictureFilePath})
            captureView.state = "review"
        }
    }

    ListModel {
        id: photoList

        ListElement {
            photoNum: 1
            path: "C:/Users/Vu/Pictures/DSC05584.JPG"
        }

        ListElement {
            photoNum: 2
            path: "C:/Users/Vu/Pictures/DSC05585.JPG"
        }

        ListElement {
            photoNum: 3
            path: "C:/Users/Vu/Pictures/DSC05586.JPG"
        }
    }

    PrintPhotos {
        id: imageprint
    }


    Timer {
        id: initialTimer
        interval: 1000
        running: true
        repeat: false

        onTriggered: {
            captureView.state = "start"
            if(settingCamera.liveVideoCountdownSwitch || settingCamera.liveVideoStartSwitch) {
                sonyAPI.startRecMode()
                sonyAPI.startLiveview()
                liveView.start()
            }
        }
    }

    Timer {
        id: beforeCaptureTimer
        interval: settingGeneral.beforeCaptureTimer * 1000
        repeat: false

        onTriggered: {
            captureView.state = "liveview"

        }
    }

    Timer {
        id: reviewTimer
        interval: settingGeneral.reviewTimer * 1000
        repeat: false

        onTriggered: {
            if (photoList.count < root.numberPhotos) {
                captureView.state = "beforecapture";
            } else {
                captureView.state = "endsession"
                endSessionTimer.start()
            }
        }
    }

    Timer {
        id: endSessionTimer
        interval: settingGeneral.endSessionTimer * 1000
        repeat: false

        onTriggered: {
            captureView.state = "start"
        }
    }


    ColumnLayout {
        anchors.fill: parent
        z: 10
        opacity: 0.5

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
            text: "Undo 1"
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            icon.source: "qrc:/Images/refresh_white_48dp_1.png"
            icon.width: 48
            icon.height: 48
            display: AbstractButton.IconOnly
            background: Rectangle {
                color: "transparent"
            }

            onClicked: {
                captureTimer.stop()
//                countdownTimer.visible = false
                countdownTimer.count = settingGeneral.captureTimer
                if (photoList.count > 0) {
                    photoList.remove(photoList.count-1, 1)
                }

                captureView.state = "beforeCapture"

            }
        }

        Button {
            text: "Undo All"
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
            icon.source: "qrc:/Images/refresh_white_48dp_all.png"
            icon.width: 48
            icon.height: 48
            display: AbstractButton.IconOnly
            background: Rectangle {
                color: "transparent"
            }

            onClicked: {
                captureView.state = "start"
            }
        }

        ColumnLayout {}

    }

    SwipeView {
        id: swipeview
        currentIndex: tabBar.currentIndex
        anchors.fill: parent

        Item {
            id: captureView

            // ==== PUT DEBUG BUTTONS HERE!!! ====
            ColumnLayout {
                id: debugLayout
                z: 10
                opacity: 0.5
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
                    text: "StartRecMode"
                    onClicked: {
                        sonyAPI.startRecMode()
                    }
                }

                Button {
                    text: "StartLiveview"
                    onClicked: {
                        sonyAPI.startLiveview()
                    }
                }

                Button {
                    text: "Open Stream"
                    onClicked: {
//                        sonyAPI.startLiveview()
//                        liveImageItem.start()
                        liveView.start()
                    }
                }

                Button {
                    text: "End Stream"
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

//                Process {
//                        id: process
//                        onReadyRead: {
//                            var result = String(process.readAllStandardOutput())
//                            root.lastPhotoPath = addFilePrefix(result)
//                            console.log(root.lastPhotoPath)
//                            reviewImage.source = root.lastPhotoPath
//                            captureView.state = "review"
//                        }
//                }

                Button {
                    id: captureButton
                    text: "Capture Action"

                    onClicked: {
                        sonyAPI.actTakePicture()
                    }
                }

                Button {
                    id: imageprintButton
                    text: "Print"

                    onClicked: {
                        // make the template as the first image in the list
                        var photos = templatePath.concat(";")

                        // iterate and append all the photos to the list
                        var i
                        for(i = 0 ; i < photoList.count ; i++) {
                            photos = photos.concat(photoList.get(i).path)
                            if (i < photoList.count-1) {
                                photos = photos.concat(";")
                            }
                        }

//                        console.log(photos)

                        imageprint.printPhotos(photos, settingPrinter.printerName, settingGeneral.saveFolder, 1)
                    }
                }

            }


            // ==== STATES ====
            states: [
                State {
                    name: "start"
                    PropertyChanges {
                        target: liveView
                        opacity: settingCamera.liveVideoStartSwitch
                        scale: 1

//                        visible: settingCamera.liveVideoStartSwitch
                    }
                    PropertyChanges {
                        target: videoLoader
                        opacity: 1
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 0
                    }
                    PropertyChanges {
                        target: endSession
                        opacity: 0
                    }
                    StateChangeScript {
                        script: {
                            var model = settingVideos.startVideoListModel
                            var randomIdx = Math.round(Math.random(1) * (model.count-1))
                            var randomItem = model.get(randomIdx)
                            playVideo(randomItem.filePath)

                            photoList.clear()
                            captureTimer.stop()
                            countdownTimer.visible = false
                            countdownTimer.count = settingGeneral.captureTimer
                        }
                    }
                },

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
                        target: countdownTimer
                        opacity: 0
                    }
                    PropertyChanges {
                        target: endSession
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
                        target: videoLoader
                        opacity: 0
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 1
                    }
                    PropertyChanges {
                        target: endSession
                        opacity: 0
                    }
                    StateChangeScript {
                        script: {
                            countdownTimer.visible = true
                            countdownTimer.count = settingGeneral.captureTimer
                            captureTimer.start()
                            reviewImage.source = ""

//                            if (currentPhoto == 0) {
//                                photoList.clear()
//                            }


                        }
                    }
                },

                State {
                    name: "review"
                    PropertyChanges {
                        target: liveView
                        opacity: 0
                        scale: 0.1
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 0
                    }
                    PropertyChanges {
                        target: videoLoader
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
                    PropertyChanges {
                        target: endSession
                        opacity: 0
                    }
                    StateChangeScript {
                        script: {
                            reviewTimer.start()
                        }
                    }
                },

                State {
                    name: "endsession"

                    PropertyChanges {
                        target: liveView
                        opacity: 0
                        scale: 0.1
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 0
                    }
                    PropertyChanges {
                        target: videoLoader
                        opacity: 0
                    }
                    PropertyChanges {
                        target: countdownTimer
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

            SonyLiveview {
                id: liveView
                opacity: 1

                width: root.width * 0.5
                height: width * 2 / 3
                y: 60
                x: (root.width - width)/2
                z: 2

            }

            Loader {
                id: videoLoader
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

            Rectangle {
                id: endSession
                anchors.fill: parent

                color: "#222"

                Text {
                    id: name
                    text: qsTr("End of Session")
                    font.pointSize: 36
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                }
            }

        // ==== PAGES ====
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
            SettingPrinter {
                id: settingPrinter
                anchors.fill: parent
            }
        }

        Item {
            SettingVideo {
                id: settingVideos
                anchors.fill: parent
            }
        }



    }

    // ==== VIRTUAL KEYBOARD ====
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

    // ==== TAB BAR STUFF ====
    TabBar {
        id: tabBar
        x: 864
        position: TabBar.Footer
        currentIndex: swipeview.currentIndex
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        Material.elevation: 1
        opacity: 0.5
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
            text: "Printer"
            width: implicitWidth
            icon.source: "qrc:/Images/print_white_48dp.png"
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






































































