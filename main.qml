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
    property real numberPhotos: 3
    property string lastCombinedPhoto
    property bool liveviewStarted: false
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



    // email list
    ListModel {
        id: emailList

    }

    // a list model for storing photo paths
    ListModel {
        id: photoList

    }


    // print class to print photos
    PrintPhotos {
        id: imagePrint
        printerName: settings.printerName
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

    Timer {
        id: loginPopupTimer
        interval: 100
        repeat: false
        running: true
        onTriggered: {
            loginPopup.open()
        }
    }


    Popup {
        id: loginPopup
        modal: true
        closePolicy: Popup.NoAutoClose
        anchors.centerIn: parent
        z: 20

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
            source: swipeview
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

        Component.onCompleted: {
            if (rememberMeCheckBox.checked) {
                usernameField.text = username
//                passwordField.text = password
            }
        }

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
                    console.log("Logging in...")
                    loadingBar.running = true
                    firebase.authenticate(usernameField.text.toString(), passwordField.text.toString())
                }
            }

        }

    }



//    // ==== PUT DEBUG BUTTONS HERE!!! ====
//    DebugButtons {}


    // ==== SWIPEVIEW ====
    SwipeView {
        id: swipeview
        currentIndex: tabBar.currentIndex
        anchors.fill: parent

        Item {
            CaptureView {
                id: captureView
                anchors.fill: parent
            }
        }

        Item {
            Gallery {
                id: gallery
                anchors.fill: parent
                folder: addFilePrefix(settings.printFolder)
            }
        }

        Item {
            SettingGeneral {
                id: settings
                anchors.fill: parent
            }
        }

    }

    //==== VIRTUAL KEYBOARD ====
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






































































