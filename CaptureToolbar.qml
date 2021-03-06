import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.1

Rectangle {
    id: captureRect
    color: "transparent"

    property real iconSize: pixel(32)
    property real fontSize: pixel(60)
    property real pointSize: 30
    property alias lockButton: lockButton
    property real iconSpacing: pixel(10)
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
            margins: pixel(25)
        }

        scale: captureView.state in {"review": 0} ? 1 : 0
        visible: scale > 0.1 ? true : false


        Behavior on scale {
            NumberAnimation {
                duration: 400
                easing.type: captureView.state in {"review": 0} ? Easing.OutQuad :  Easing.OutElastic
            }
        }

        CustomToolbarButton {
            id: playPauseButton
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: playing ? qsTr("Pause") : qsTr("Resume")
            font.pointSize: captureRect.pointSize
            icon.source: playing ? "qrc:/icons/pause" : "qrc:/icons/play"

            icon.color: "#8BC34A"
//            bg.border.color: "#8BC34A"
//            bg.border.width: 2
//            bg.radius: 4
//            bg.color: "#20FFFFFF"

            onClicked: {
                playPause()
            }
        }

        CustomToolbarButton {
            id: undoLastButton
            text: qsTr("Retake")
            Layout.fillHeight: true
            Layout.fillWidth: true

            icon.color: "#FF9800"
//            bg.border.color: "#FF9800"
//            bg.border.width: 2
//            bg.radius: 4
//            bg.color: "#20FFFFFF"

//            font.pixelSize: captureRect.fontSize
            font.pointSize: captureRect.pointSize

            icon.source: "qrc:/icons/restore"
//            display: captureView.state in {"review": 0, "aftercapture": 1} ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly

            onClicked: {
                if (captureView.state != "start") {
                    if (photoList.count > 0) {
                        photoList.remove(photoList.count-1, 1)
                    }
                    beforeCaptureState()
                }
            }
        }

        CustomToolbarButton {
            id: restartButton
            Layout.fillHeight: true
            Layout.fillWidth: true

            icon.color: "#00BCD4"
//            bg.border.color: "#00BCD4"
//            bg.border.width: 2
//            bg.radius: 4
//            bg.color: "#20FFFFFF"
//            font.pixelSize: captureRect.fontSize
            font.pointSize: captureRect.pointSize
            text: qsTr("Restart")
            icon.source: "qrc:/icons/replay"

            onClicked: {
                restart()
            }
        }
    }


    // Capture toolbar
    Row {
        spacing: captureRect.iconSpacing
//        y: parent.height/2 - height/2
        anchors {
            top: parent.top
//            left: parent.left
//            right: parent.right
            horizontalCenter: parent.horizontalCenter
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

        CustomToolbarButton {
            id: playPauseButton2
            text: playing ? "Pause" : "Resume"
//            width: captureRect.iconSize
//            height: captureRect.iconSize
            icon.source: playing ? "qrc:/svg/pause-solid" : "qrc:/svg/play-solid"
            icon.width: captureRect.iconSize
            icon.height: captureRect.iconSize
//            display: AbstractButton.IconOnly
            checkable: true

            icon.color: "#8BC34A"
//            bg.border.color: "#8BC34A"

            onClicked: {
                playPause()
            }
        }

        CustomToolbarButton {
            id: restartButton2
            text: "Restart"
//            width: captureRect.iconSize
//            height: captureRect.iconSize
            icon.source: "qrc:/svg/undo-solid"
            icon.width: captureRect.iconSize
            icon.height: captureRect.iconSize
//            display: AbstractButton.IconOnly

            icon.color: "#00BCD4"
//            bg.border.color: "#00BCD4"

            onClicked: {
                restart()
            }
        }

        CustomToolbarButton {
            id: fullScreenButton
            text: mainWindow.visibility === Window.FullScreen ? "Window" : "Full"
            visible: !locked
//            width: captureRect.iconSize
//            height: captureRect.iconSize
            icon.source: mainWindow.visibility === Window.FullScreen ? "qrc:/svg/compress-solid" : "qrc:/svg/expand-solid"
            icon.width: captureRect.iconSize
            icon.height: captureRect.iconSize
//            display: AbstractButton.IconOnly

            icon.color: "#FFC107"
//            bg.border.color: "#FFC107"


            onClicked: {
                if (mainWindow.visibility === Window.FullScreen) {
                    mainWindow.showNormal();
                }
                else {
                    mainWindow.showFullScreen();
                }
            }
        }

        CustomToolbarButton {
            id: exitButton
            text: "Exit"
            visible: !locked
//            width: captureRect.iconSize
//            height: captureRect.iconSize
            icon.source: "qrc:/svg/times-solid"
            icon.width: captureRect.iconSize
            icon.height: captureRect.iconSize
//            display: AbstractButton.IconOnly

            icon.color: "#9E9E9E"
//            bg.border.color: "#9E9E9E"

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
            }
        }

        CustomToolbarButton {
            id: lockButton
            text: locked ? "Unlock" : "Lock"
//            width: captureRect.iconSize
//            height: captureRect.iconSize
            icon.source: locked ? "qrc:/svg/lock-solid":  "qrc:/svg/unlock-solid"
            icon.width: captureRect.iconSize
            icon.height: captureRect.iconSize
//            display: AbstractButton.IconOnly

            icon.color: "#607D8B"
//            bg.border.color: "#607D8B"

            onClicked: {
                if (locked) {
                    if (settings.lockPin.length > 0) {
                        lockPinPopup.open()
                        return
                    }
                    locked = false
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
