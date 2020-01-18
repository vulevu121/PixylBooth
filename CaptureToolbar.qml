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

Rectangle {
    id: captureRect
    color: "transparent"

    property real iconSize: pixel(24)
    property real fontSize: pixel(10)
//    property alias playPauseButton: playPauseButton
    property alias lockButton: lockButton
//    property int numberButtons: 6
    property real iconSpacing: pixel(2)
    property bool playing: false
    property bool locked: false

    function playPause() {
        playing = !playing

        if (captureView.state == "start") {
//                liveView.start()
            sonyRemote.start()
            beforeCaptureState()
            console.log("[PlayPauseButton] Goto before capture")
        }

        if (captureView.state == "beforecapture") {
            beforeCaptureTimer.running = playing
            console.log("[PlayPauseButton] beforeCaptureTimer", playing)
        }

        if (captureView.state == "liveview") {
            countdownTimer.running = playing
            console.log("[PlayPauseButton] countdownTimer", playing)
        }

        if (captureView.state == "aftercapture") {
            afterCaptureTimer.running = playing
            console.log("[PlayPauseButton] afterCaptureTimer", playing)
        }

        if (captureView.state == "review") {
            reviewTimer.running = playing
            console.log("[PlayPauseButton] reviewTimer", playing)
        }

        if (captureView.state == "endsession") {
            endSessionTimer.running = playing
            console.log("[PlayPauseButton] endSessionTimer", playing)
        }
    }

    function restart() {
        playing = false
        photoList.clear()
        startState()
    }

    // Popup user buttons
    ColumnLayout {
        id: userColumn

        opacity: 0.8
        anchors {
            left: parent.left
            right: parent.right
            top: parent.verticalCenter
            bottom: parent.bottom
            margins: pixel(10)
        }

        scale: captureView.state in {"review": 0} ? 1 : 0
        visible: scale > 0.1 ? true : false

//        anchors {
//            horizontalCenter: parent.horizontalCenter
//            verticalCenter: parent.verticalCenter
//            verticalCenterOffset: pixel(80)
//        }

        Behavior on scale {
            NumberAnimation {
                duration: 400
                easing.type: captureView.state in {"review": 0} ? Easing.OutQuad :  Easing.OutElastic
            }
        }


        Button {
            id: playPauseButton
            text: playing ? qsTr("Pause") : qsTr("Resume")
            Layout.fillHeight: true
            Layout.fillWidth: true

//            anchors {
//                left: parent.left
//                right: parent.right
//            }
            font.capitalization: Font.MixedCase
            font.pixelSize: captureRect.fontSize
            icon.source: playing ? "qrc:/icon/pause" : "qrc:/icon/play"
//            icon.width: implicitHeight
//            icon.height: implicitHeight
            display: AbstractButton.TextBesideIcon
            highlighted: true
            Material.accent: Material.color(Material.Green, Material.Shade700)
            checkable: true

            onClicked: {
                playPause()
            }
        }

        Button {
            id: undoLastButton
            Layout.fillHeight: true
            Layout.fillWidth: true
//            anchors {
//                left: parent.left
//                right: parent.right
//            }
            font.pixelSize: captureRect.fontSize
            font.capitalization: Font.MixedCase
            text: qsTr("Redo Last Photo")
            icon.source: "qrc:/icon/undo_one"
//            icon.width: height
//            icon.height: height
            display: captureView.state in {"review": 0, "aftercapture": 1} ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly
            highlighted: true
            Material.accent: Material.color(Material.Orange, Material.Shade700)

            onClicked: {
    //            undoLastButtonAnimation.start()
                if (captureView.state != "start") {
                    if (photoList.count > 0) {
                        photoList.remove(photoList.count-1, 1)
                    }
                    beforeCaptureState()
                }
            }

        }

        Button {
            id: restartButton
            Layout.fillHeight: true
            Layout.fillWidth: true
//            anchors {
//                left: parent.left
//                right: parent.right
//            }
            font.pixelSize: captureRect.fontSize
            font.capitalization: Font.MixedCase
            text: qsTr("Restart")
            icon.source: "qrc:/icon/replay"
//            icon.width: height
//            icon.height: height

            display: AbstractButton.TextBesideIcon
            highlighted: true
            Material.accent: Material.color(Material.Cyan, Material.Shade700)

            onClicked: {
    //            restartButtonAnimation.start()
                restart()
            }
        }
    }




    // Capture toolbar
    Column {
        y: parent.height/2 - height/2
        anchors {
//            fill: parent
//            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }

        move: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 400
                easing.type: Easing.OutQuart
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuart
            }
        }


        Button {
            id: playPauseButton2
            text: playing ? "Pause" : "Resume"
            width: captureRect.iconSize
            height: captureRect.iconSize
            icon.source: playing ? "qrc:/icon/pause" : "qrc:/icon/play"
            icon.width: height
            icon.height: height
            display: AbstractButton.IconOnly
            highlighted: true
            Material.accent: Material.color(Material.Green, Material.Shade700)
            checkable: true

            onClicked: {
                playPause()
            }
        }

        Button {
            id: restartButton2
            text: "Restart from beginning?"
            width: captureRect.iconSize
            height: captureRect.iconSize
            icon.source: "qrc:/icon/replay"
            icon.width: height
            icon.height: height
            display: AbstractButton.IconOnly
            highlighted: true
            Material.accent: Material.color(Material.Cyan, Material.Shade700)

            onClicked: {
                restart()
            }
        }

        Button {
            id: fullScreenButton
            text: "Full Screen"
            width: captureRect.iconSize
            visible: !locked
            height: captureRect.iconSize
            icon.source: mainWindow.visibility === Window.FullScreen ? "qrc:/icon/fullscreen_exit" : "qrc:/icon/fullscreen"
            icon.width: height
            icon.height: height
            display: AbstractButton.IconOnly
            highlighted: true
            Material.accent: Material.color(Material.Yellow, Material.Shade700)

            onClicked: {
                if (mainWindow.visibility === Window.FullScreen) {
                    mainWindow.showNormal();
                }
                else {
                    mainWindow.showFullScreen();
                }
            }
        }

        Button {
            id: exitButton
            text: "Exit"
            flat: false
            visible: !locked
            width: captureRect.iconSize
            height: captureRect.iconSize
            icon.source: "qrc:/icon/close"
            icon.width: height
            icon.height: height
            display: AbstractButton.IconOnly
            highlighted: true
            Material.accent: Material.color(Material.Grey, Material.Shade700)

            MessageDialog {
                id: confirmExitDialog
                title: "Quit"
                text: "Do you want to exit?"
                standardButtons: StandardButton.Yes | StandardButton.No
                onAccepted: {
                    Qt.quit()
                }
            }

            onClicked: {
                confirmExitDialog.open()
    //            mainWindow.close()
            }
        }

        Button {
            id: lockButton
            text: locked ? "Unlock" : "Lock"
            flat: false
            width: captureRect.iconSize
            height: captureRect.iconSize
            icon.source: locked ? "qrc:/icon/unlock":  "qrc:/icon/lock"
            icon.width: height
            icon.height: height
            display: AbstractButton.IconOnly
            highlighted: true
            Material.accent: Material.color(Material.Grey, Material.Shade700)

            onClicked: {
                if (locked) {
                    if (settings.lockPin.length > 0) {
                        lockPinPopup.open()
                        return
                    }
                    locked = false
//                    lockPinPopup.open()

                }
                else {
                    locked = true
                }

            }
        }

    }

    Popup {
        id: lockPinPopup
        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.NoAutoClose

        onOpened: {
            lockPinTextFieldEntry.forceActiveFocus()
        }

        Column {
            TextField {
                id: lockPinTextFieldEntry
                width: mainWindow.width * 0.9
                placeholderText: "Enter a PIN"
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhDigitsOnly
                focus: true
                horizontalAlignment: TextInput.AlignHCenter

                function checkPin() {
                    if (lockPinTextFieldEntry.text == settings.lockPin) {
                        captureToolbar.locked = false
                        lockPinPopup.close()
                        lockPinTextFieldEntry.clear()

                        return true
                    }
                    return false
                }

                onTextChanged: {
                    checkPin()
                }


            }

            InputPanel {
                id: keypadEntry
                visible: true
                anchors {
                    left: parent.left
                    right: parent.right
                }

            }
        }


    }

}
