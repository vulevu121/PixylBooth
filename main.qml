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

    color: bgColor
    title: qsTr("PixylBooth")

    property real pixelDensity: Screen.pixelDensity
    property string bgColor: "#222"
    property string countDownColor: "#fff"
    property real numberPhotos: 3
    property real printCopyCount: printCopyCountTumbler.currentIndex + 1
    property string lastCombinedPhoto
    property string templatePath: "C:/Users/Vu/Pictures/dslrBooth/Templates/Mia Pham/background.png"



    Settings {
        property alias x: root.x
        property alias y: root.y
        property alias lastCombinedPhoto: root.lastCombinedPhoto
        //        property alias width: root.width
        //        property alias height: root.height
        //        property alias visibility: root.visibility
    }

    Settings {
        category: "Color"
        property alias backgroundColor: root.bgColor
        property alias countDownColor: root.countDownColor
    }

    // function to assist in scaling with different resolutions and dpi
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

    function stripFilePrefix(path) {
        return path.replace("file:///", "").replace("file://", "")
    }

    function addFilePrefix(path) {
        if (path.search("file://") >= 0)
            return path

        var filePrefix = "file://"

        if (path.length > 2 && path[1] === ':')
            filePrefix += "/"

        return filePrefix.concat(path)
    }

    function setcountDownColor(color) {
        countDownColor = color
    }

    function setBgColor(color) {
        bgColor = color
    }

    function saveCapture() {
        sonyAPI.actTakePicture()
    }

    function combinePhotos() {
        // make the template as the first image in the list
        var photos = templatePath.concat(";")

        // iterate and append all the photos to the list string
        var i
        if (photoList.count > 0) {

            for(i = 0 ; i < photoList.count ; i++) {
                photos = photos.concat(photoList.get(i).path)
                if (i < photoList.count-1) {
                    photos = photos.concat(";")
                }
            }

            lastCombinedPhoto = processPhotos.combine(photos)
            endSessionImage.source = addFilePrefix(lastCombinedPhoto)
            console.log(lastCombinedPhoto)
        }
    }

    function printLastCombinedPhoto() {
        imagePrint.printPhotos(lastCombinedPhoto, printCopyCount)
    }

    function stopAllTimers() {
        beforeCaptureTimer.stop()
        reviewTimer.stop()
        endSessionTimer.stop()
        captureTimer.stop()
    }


    Text {
        text: Screen.pixelDensity
        color: "white"
    }

    // Sony API to initialize camera, take picture, etc.
    SonyAPI {
        id: sonyAPI
        saveFolder: settingGeneral.saveFolder
        onActTakePictureCompleted: {
            reviewImage.source = addFilePrefix(actTakePictureFilePath)
            photoList.append({"path": actTakePictureFilePath})
            captureView.state = "review"
        }
    }

    // a list model for storing photo paths
    ListModel {
        id: photoList
    }

    // process the photos into tempalte
    ProcessPhotos {
        id: processPhotos
        saveFolder: settingGeneral.saveFolder.concat("/Prints")
    }

    // print class to print photos
    PrintPhotos {
        id: imagePrint
        printerName: settingGeneral.printerName
    }

    // timer to initialize to a default state
    Timer {
        id: initialTimer
        interval: 100
        running: true
        repeat: false

        onTriggered: {
            captureView.state = "start"
            if(settingGeneral.liveVideoCountdownSwitch || settingGeneral.liveVideoStartSwitch) {
                sonyAPI.startRecMode()
                sonyAPI.startLiveview()
            }
//            initialTimer2.start()
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
            countdownTimer.visible = true
            countdownTimer.count = settingGeneral.captureTimer
            captureTimer.start()
            reviewImage.source = ""
            captureView.state = "liveview"
        }
    }

    // timer to review photo after each capture
    Timer {
        id: reviewTimer
        interval: settingGeneral.reviewTimer * 1000
        repeat: false

        onTriggered: {
            if (photoList.count < root.numberPhotos) {
                captureView.state = "beforecapture"
            } else {
                combinePhotos()
                captureView.state = "endsession"
                endSessionTimer.start()
            }
        }
    }

    // timer for end of session to print and share photos
    Timer {
        id: endSessionTimer
        interval: settingGeneral.endSessionTimer * 1000
        repeat: false

        onTriggered: {
            captureView.state = "start"
        }
    }

    // timer for countdown
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

    // ==== MAIN BUTTONS ====
    ColumnLayout {
        anchors.fill: parent
        z: 5
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
            icon.source: "qrc:/Images/settings_backup_restore_white_48dp.png"
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
            icon.source: "qrc:/Images/settings_backup_restore_white_48dp_all.png"
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

        ColumnLayout { }


    }

    // ==== SWIPEVIEW ====
    SwipeView {
        id: swipeview
        currentIndex: tabBar.currentIndex
        anchors.fill: parent

        Item {
            id: captureView

            // ==== PUT DEBUG BUTTONS HERE!!! ====
            ColumnLayout {
                id: debugLayout
                z: 5
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
                    text: "Review"
                    onClicked: {
                        captureView.state = "review"
                    }
                }

                Button {
                    text: "EndSession"
                    onClicked: {
                        captureView.state = "endsession"
                        endSessionImage.source = addFilePrefix("C:/Users/Vu/Pictures/PixylBooth/Prints/DSC05755_DSC05756_DSC05757.jpg")
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
                        liveView.start()
                    }
                }

                Button {
                    text: "End Stream"
                    onClicked: {
                        liveView.stop()
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
                    id: imagePrintButton
                    text: "Print"

                    onClicked: {
                        imagePrint.printPhotos(lastCombinedPhoto, 1)
                    }
                }
            }


            // ==== STATES ====
            states: [
                State {
                    name: "start"
                    PropertyChanges {
                        target: liveView
                        opacity: settingGeneral.liveVideoStartSwitch
                        scale: 1
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
                            var model = settingGeneral.startVideoListModel
                            var randomIdx = Math.round(Math.random(1) * (model.count-1))
                            var randomItem = model.get(randomIdx)
                            playVideo(randomItem.filePath)

                            // clear photo list and timers before capture
                            photoList.clear()
                            stopAllTimers()
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
                            var model = settingGeneral.beforeCaptureVideoListModel
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
                        visible: settingGeneral.liveVideoCountdownSwitch
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
                    StateChangeScript {
                        script: {

                        }
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

            // live view from camera
            SonyLiveview {
                id: liveView
                opacity: 1

                width: root.width * 0.5
                height: width * 2 / 3
                y: 60
                x: (root.width - width)/2
                z: 2

            }

            // loader for all videos
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



            Rectangle {
                id: mouseArea
                width: 400
                height: 400
                color: "transparent"
                border.color: "#ffffff"
                border.width: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                z: 10

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
                }
            }

            Item {
                id: endSession
                anchors.fill: parent
                opacity: 0
                z: 20

                ColumnLayout {
                    anchors.fill: parent

                    ColumnLayout {
                    }

                    Image {
                        id: endSessionImage
                        width: 400
                        height: 300
                        sourceSize.width: 400
                        sourceSize.height: 300
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        fillMode: Image.PreserveAspectFit
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        Button {
                            text: qsTr("Print")
                            icon.source: "qrc:/Images/print_white_48dp.png"
                            icon.width: 48
                            icon.height: 48
                            display: AbstractButton.IconOnly
                            onClicked: {
                                endSessionPopup.open()
                            }

                        }

                        Button {
                            text: qsTr("Email")
                            icon.source: "qrc:/Images/email_white_48dp.png"
                            icon.width: 48
                            icon.height: 48
                            display: AbstractButton.IconOnly
                            onClicked: {
                                console.log("Email!")
                            }
                        }

                        Button {
                            text: qsTr("SMS")
                            icon.source: "qrc:/Images/sms_white_48dp.png"
                            icon.width: 48
                            icon.height: 48
                            display: AbstractButton.IconOnly
                            onClicked: {
                                console.log("SMS!")
                            }
                        }
                    }
                    ColumnLayout {
                    }
                }

                Popup {
                    id: endSessionPopup
                    width: 100
                    height: 300
                    modal: true
                    anchors.centerIn: parent
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                    ColumnLayout {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 100
                        height: 300

                        ColumnLayout {}

                        Tumbler {
                            id: printCopyCountTumbler
                            Layout.alignment: Qt.AlignCenter

                            font.pointSize: 18
                            model: 5
                            wrap: false

                            background: Item {
                                Rectangle {
                                    width: parent.width
                                    height: parent.height
                                    opacity: 0.1
                                    border.color: "black"
                                    border.width: 1

                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "black" }
                                        GradientStop { position: 0.5; color: "white" }
                                        GradientStop { position: 1.0; color: "black" }
                                    }

                                }

                            }

                            delegate: Text {
                                text: qsTr("%1").arg(modelData + 1)
                                font: printCopyCountTumbler.font
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (printCopyCountTumbler.visibleItemCount / 2)
                            }

                            Rectangle {
                                anchors.horizontalCenter: printCopyCountTumbler.horizontalCenter
                                y: printCopyCountTumbler.height * 0.4
                                width: parent.width * 0.9
                                height: 1
                                color: "white"
                            }

                            Rectangle {
                                anchors.horizontalCenter: printCopyCountTumbler.horizontalCenter
                                y: printCopyCountTumbler.height * 0.6
                                width: parent.width * 0.9
                                height: 1
                                color: "white"
                            }
                        }

                        Button {
                            text: qsTr("OK")
                            Layout.alignment: Qt.AlignCenter
                            onClicked: {
                                printLastCombinedPhoto()
                            }
                        }

                        ColumnLayout {}


                    }

                }


            }

            // ==== PAGES ====
        }
        Item {
            Gallery {
                id: gallery
                anchors.fill: parent
                folder: "file:///C:/Users/Vu/Pictures/PixylBooth/Prints/"
            }
        }
        Item {
            SettingGeneral {
                id: settingGeneral
                anchors.fill: parent
            }
        }

//        Item {
//            SettingCamera {
//                id: settingGeneral
//                anchors.fill: parent
//            }
//        }

//        Item {
//            SettingAction {
//                id: settingAction
//                anchors.fill: parent
//            }
//        }

//        Item {
//            SettingColor {
//                id: settingColors
//                anchors.fill: parent

//                Component.onCompleted: {
//                    countDownColorSelected.connect(root.setcountDownColor)
//                    bgColorSelected.connect(root.setBgColor)
//                }
//            }
//        }

//        Item {
//            SettingPrinter {
//                id: settingGeneral
//                anchors.fill: parent
//            }
//        }

//        Item {
//            SettingVideo {
//                id: settingGeneral
//                anchors.fill: parent
//            }
//        }



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
            color: Material.background
            radius: 10
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
            text: "Play"
            width: implicitWidth
            icon.source: "qrc:/Images/play_circle_filled_white_white_48dp.png"
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


//        TabButton {
//            text: "Camera"
//            width: implicitWidth
//            icon.source: "qrc:/Images/camera_alt_white_48dp.png"
//            icon.width: 24
//            icon.height: 24
//            display: AbstractButton.IconOnly
//        }

//        TabButton {
//            text: "Action"
//            width: implicitWidth
//            icon.source: "qrc:/Images/apps_white_48dp.png"
//            icon.width: 24
//            icon.height: 24
//            display: AbstractButton.IconOnly
//        }

//        TabButton {
//            text: "Color"
//            width: implicitWidth
//            icon.source: "qrc:/Images/color_lens_white_48dp.png"
//            icon.width: 24
//            icon.height: 24
//            display: AbstractButton.IconOnly
//        }

//        TabButton {
//            text: "Printer"
//            width: implicitWidth
//            icon.source: "qrc:/Images/print_white_48dp.png"
//            icon.width: 24
//            icon.height: 24
//            display: AbstractButton.IconOnly
//        }


//        TabButton {
//            text: "Videos"
//            width: implicitWidth
//            icon.source: "qrc:/Images/video_library_white_48dp.png"
//            icon.width: 24
//            icon.height: 24
//            display: AbstractButton.IconOnly
//        }

    }

}






































































