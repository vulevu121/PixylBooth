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
//import QtWebView 1.1
//import Process 1.0
//import SonyAPI 1.0
//import SonyLiveview 1.0
import ProcessPhotos 1.0
import PrintPhotos 1.0
//import CSVFile 1.0
//import Firebase 1.0
//import MoveMouse 1.0
import QtQuick.VirtualKeyboard 2.13
import QtQuick.VirtualKeyboard.Styles 2.13
import QtQuick.VirtualKeyboard.Settings 2.13
//import QRGenerator 1.0

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
    property string lastCombinedPhoto
    property bool liveviewStarted: false
//    property string username: usernameField.text
//    property string password: passwordField.text
    property string idToken
    property string refreshToken
    property real photoAspectRatio: 3/2


    Settings {
        id: mainSettings
        property alias x: mainWindow.x
        property alias y: mainWindow.y
//        property alias lastCombinedPhoto: mainWindow.lastCombinedPhoto
//        property alias username: mainWindow.username
//        property alias password: mainWindow.password
//        property alias rememberMe: rememberMeCheckBox.checked
        property alias idToken: mainWindow.idToken
        property alias refreshToken: mainWindow.refreshToken
        property alias visibility: mainWindow.visibility
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

    function getQrImage() {
        qrImage.source = "https://api.qrserver.com/v1/create-qr-code/?margin=5&size=150x150&data=" + settings.albumUrl
    }

//    Process {
//        id: process
//    }

//    Firebase {
//        id: firebase

//        idToken: mainWindow.idToken
//        refreshToken: mainWindow.refreshToken

//        onUserAuthenticated: {
//            mainWindow.idToken = idToken
//            mainWindow.refreshToken = refreshToken
//        }

//        onUserNotAuthenticated: {
//            toast.show(msg)
//        }

//        onUserInfoReceived: {
//            toast.show("Login successful")
//            loadingBar.running = false
//            loginPopup.close()


//        }

//    }

//    CSVFile {
//        id: csvFile
//        saveFolder: settings.saveFolder
//    }




    // a list model for storing photo paths
    ListModel {
        id: photoList

    }

    // print class to print photos
    PrintPhotos {
        id: printPhotos
        printerName: settings.printerName
        paperName: settings.paperName
    }


    Timer {
        id: initialTimer2
        interval: 2000
        running: true
        repeat: false

        onTriggered: {
            getQrImage()
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

//    Timer {
//        id: loginPopupTimer
//        interval: 100
//        repeat: false
//        running: true
//        onTriggered: {
//            loginPopup.open()
//        }
//    }


//    Popup {
//        id: loginPopup
//        modal: true
//        closePolicy: Popup.NoAutoClose
//        anchors.centerIn: parent
//        z: 20

//        background: Rectangle {
//            color: Material.background
//            opacity: 0.7
//            radius: pixel(3)
//            clip: true

//            Rectangle {
//                width: parent.width
//                height: 3
//                id: barRect
//                color: Material.background

//                Rectangle {
//                    id: movingRect
//                    width: 40
//                    x: -width
//                    height: parent.height
//                    color: Material.accent
//                }

//                PropertyAnimation {
//                    id: loadingBar
//                    target: movingRect
//                    property: "x"
//                    from: -movingRect.width
//                    to: barRect.width
//                    duration: 1000
//                    easing.type: Easing.InOutQuad
//                    running: false
//                    loops: Animation.Infinite
//                }
//            }
//        }


//        Overlay.modal: GaussianBlur {
//            source: swipeview
//            radius: 8
//            samples: 16
//            deviation: 3
//        }

////        Component.onCompleted: {
////            if (refreshToken.search("eyJhbGciOiJSUzI1NiIsImtpZCI6IjY2NDNkZDM5") < 0) {
////                loginPopup.open()
////                if (rememberMeCheckBox.checked) {
////                    usernameField.text = username
////                    passwordField.text = password
////                }
////            }
////        }

//        Component.onCompleted: {
//            if (rememberMeCheckBox.checked) {
//                usernameField.text = username
////                passwordField.text = password
//            }
//        }

//        GridLayout {
//            id: gridLayout
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.horizontalCenter: parent.horizontalCenter
//            columns: 2

//            Label {
//                text: qsTr("Username")
//                font.pixelSize: usernameField.font.pixelSize
//                color: Material.foreground
//            }

//            TextField {
//                id: usernameField
//                text: ""
//                Layout.minimumWidth: 200
//                selectByMouse: true
////                placeholderText: "Enter your email"
//                Keys.onReturnPressed: {
//                    loginButton.clicked()
//                }

//            }

//            Label {
//                text: qsTr("Password")
//                font.pixelSize: passwordField.font.pixelSize
//                color: Material.foreground
//            }

//            TextField {
//                id: passwordField
//                Layout.minimumWidth: 200
//                selectByMouse: true
////                placeholderText: "Enter your password"
//                echoMode: TextInput.Password
//                Keys.onReturnPressed: {
//                    loginButton.clicked()
//                }

//            }

//            CheckBox {
//                id: rememberMeCheckBox
//                text: qsTr("Remember")
//            }

//            Button {
//                id: loginButton
//                text: qsTr("Login")
//                onClicked: {
//                    console.log("Logging in...")
//                    loadingBar.running = true
//                    firebase.authenticate(usernameField.text.toString(), passwordField.text.toString())
//                }
//            }

//        }

//    }



//    // ==== PUT DEBUG BUTTONS HERE!!! ====
//    DebugButtons {
//        visible: true
//    }

//    QRGenerator {
//        id: qrGenerator

//        onReceivedQrCode: {
//            console.log(imgPath)
//            qrImage.source = addFilePrefix(imgPath)
//        }
//    }

    Image {
        id: qrImage
        source: ""
        x: pixel(5)
        y: pixel(5)
        width: pixel(30)
        height: pixel(30)
        fillMode: Image.PreserveAspectFit
        z: 1
        visible: scale > 0.1 ? true : false
        scale: swipeview.currentIndex in [0, 1] ? 1 : 0
//        PinchArea {
//            id: imagePinchArea
//            anchors.fill: parent
//            pinch.target: qrImage
////            pinch.minimumRotation: -360
////            pinch.maximumRotation: 360
//            pinch.minimumScale: 1
//            pinch.maximumScale: 4
//            pinch.dragAxis: Pinch.XAndYAxis
//        }

        MouseArea {
            id: imageMouseArea
            anchors.fill: parent
            hoverEnabled: true
            drag.target: qrImage
            visible: qrImage.visible
        }




        Behavior on scale {
            NumberAnimation{
                duration: 400
                easing.type: Easing.OutQuad
            }
        }

//        anchors {
//            left: parent.left
//            top: parent.top
//            margins: pixel(5)
//        }
    }

    // ==== SWIPEVIEW ====
    SwipeView {
        id: swipeview
        currentIndex: 1
        anchors.fill: parent
        interactive: !captureView.captureToolbar.locked


        onCurrentIndexChanged: {
            if (swipeview.currentIndex == 1) {
                if (captureView.mediaPlayer.playbackState == MediaPlayer.PausedState) {
                    captureView.mediaPlayer.play()
                }
            }
            else {
                if (captureView.mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                    captureView.mediaPlayer.pause()
                }
            }
        }

        Item {
            Gallery {
                id: gallery
                anchors.fill: parent
                folder: addFilePrefix(settings.saveFolder + "/Prints")
            }
        }

        Item {
            CaptureView {
                id: captureView
                anchors.fill: parent
            }
        }

        Item {
            SettingGeneral {
                id: settings
                anchors.fill: parent
            }
        }

    }



    Component {
        id: toastDelegate

        Button {
            id: button
            text: msg
            width: parent.width
            font.pixelSize: pixel(10)
            font.capitalization: Font.MixedCase
//            icon.width: height
//            icon.height: height
//            icon.source: "qrc:/icon/capture"
//            display: Button.TextBesideIcon

            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            Timer {
                id: buttonTimer
                interval: toast.showTime
                repeat: false
                running: true
                onTriggered: {
//                    console.log("Removing " + index)
                    toastList.remove(index)
                }
            }


            NumberAnimation {
                target: button
                running: true
                loops: 1
                properties: "opacity, scale"
                from: 0.5
                to: 1.0
                duration: 100
                easing.type: Easing.OutQuad
            }

        }
    }

    // toast
    ListView {
        id: toast
        z: 9
        model: toastList
        delegate: toastDelegate
        width: pixel(140)
        height: pixel(100)

        opacity: toastList.count > 0 ? 1 : 0

        visible: opacity > 0.1

        ListModel {
            id: toastList
        }

        Behavior on opacity {
            NumberAnimation {duration: 1000}
        }


        property real iconSize: pixel(10)
        property int showTime: 3000

        function show(msg) {
            toastList.append({"msg": msg})
        }

        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: pixel(100)
            horizontalCenter: parent.horizontalCenter
        }

        populate: Transition {
            NumberAnimation {
                properties: "x, y"
                duration: 400
                easing.type: Easing.OutQuad
            }
        }

//        add: Transition {
//            PropertyAnimation {
//                properties: "opacity, scale"
//                from: 0.8
//                to: 1.1
//                duration: 200
//                easing.type: Easing.OutQuad
//            }

//        }

        addDisplaced: Transition {
            NumberAnimation {
                properties: "x, y"
                duration: 400
                easing.type: Easing.OutQuad
            }
        }

        remove: Transition {
            NumberAnimation {
                properties: "opacity"
                from: 1
                to: 0
                duration: 400
                easing.type: Easing.OutQuad
            }
        }

        removeDisplaced: Transition {
            NumberAnimation {
                properties: "x, y"
                duration: 400
                easing.type: Easing.OutQuad
            }
        }

        move: Transition {
            NumberAnimation {
                properties: "x, y"
                duration: 400
                easing.type: Easing.OutQuad
            }
        }




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
        z: 5
        background: Rectangle {
            color: Material.background
            radius: pixel(3)
         }

        property real iconSize: pixel(10)

        TabButton {
            text: "Gallery"
            width: implicitWidth
            icon.source: "qrc:/icon/photo_library"
            icon.width: tabBar.iconSize
            icon.height: tabBar.iconSize
            display: AbstractButton.IconOnly

            onClicked: {
                swipeview.currentIndex = 0
            }
        }

        TabButton {
            text: "Capture"
            width: implicitWidth
            icon.source: "qrc:/icon/capture"
            icon.width: tabBar.iconSize
            icon.height: tabBar.iconSize
            display: AbstractButton.IconOnly

            onClicked: {
                swipeview.currentIndex = 1

            }
        }
        TabButton {
            text: "Settings"
            width: implicitWidth
            enabled: captureView.captureToolbar.locked? false : true
            icon.source: "qrc:/icon/settings"
            icon.width: tabBar.iconSize
            icon.height: tabBar.iconSize
            display: AbstractButton.IconOnly

            onClicked: {
                swipeview.currentIndex = 2
            }
        }
    }

}






































































