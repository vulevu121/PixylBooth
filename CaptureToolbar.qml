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

ColumnLayout {
    id: mainButtonsLayout

    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    z: 5
    opacity: 0.8
    spacing: pixel(6)
    property real iconSize: pixel(16)
    property alias playPauseButton: playPauseButton
    property alias lockButton: lockButton

//    property alias exposureButton: exposureButton


//    UpDownButton {
//        id: exposureButton
//        min: -15
//        max: 15
//        value: 0
//        height: pixel(12)

//        Layout.alignment: Qt.AlignTop

//        onValueChanged: {
//            sonyAPI.setExposureCompensation(exposureButton.value)
//            toast.show("Camera exposure set to " + exposureButton.value)
//        }

//        Timer {
//            id: getExposureTimer
//            interval: 3000
//            repeat: false
//            running: true

//            onTriggered: {
//                sonyAPI.getExposureCompensation()
//            }

//        }

//    }

    Button {
        id: undoLastButton
        text: "Undo Last"
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: "qrc:/icon/undo_one"
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
        icon.source: "qrc:/icon/refresh"
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
        id: playPauseButton
        text: "Play/Pause"
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: checked ? "qrc:/icon/pause" : "qrc:/icon/play"
        icon.width: mainButtonsLayout.iconSize
        icon.height: mainButtonsLayout.iconSize
        display: AbstractButton.IconOnly
        highlighted: true
        Material.accent: Material.color(Material.Green, Material.Shade700)
        checkable: true

        onClicked: {

            playPauseButtonAnimation.start()
            var playState = playPauseButton.checked

            if (root.state === "start") {
                liveView.start()
                beforeCaptureState()
            }

            if (root.state === "beforecapture") {
                beforeCaptureTimer.running = playState
            }

            if (root.state === "liveview") {
                countdownTimer.running = playState
            }

            if (root.state === "review") {
                reviewTimer.running = playState
            }

            if (root.state === "endsession") {
                endSessionTimer.running = playState
            }

        }

        ParallelAnimation {
            id: playPauseButtonAnimation
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


    Button {
        id: fullScreenButton
        text: "Full Screen"
        visible: lockButton.checked
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: mainWindow.visibility === Window.FullScreen ? "qrc:/icon/fullscreen_exit" : "qrc:/icon/fullscreen"
        icon.width: mainButtonsLayout.iconSize
        icon.height: mainButtonsLayout.iconSize
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

//    Button {
//        text: "Exit"
//        flat: false
//        Layout.alignment: Qt.AlignRight | Qt.AlignTop
//        icon.source: "qrc:/Images/cancel_white_48dp.png"
//        icon.width: mainButtonsLayout.iconSize
//        icon.height: mainButtonsLayout.iconSize
//        display: AbstractButton.IconOnly
//        highlighted: true
//        Material.accent: Material.color(Material.Grey, Material.Shade700)
//        onClicked: {
//            mainWindow.close()
//        }
//    }

    Button {
        id: lockButton
        text: "Lock"
        flat: false
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: checked ? "qrc:/icon/unlock" : "qrc:/icon/lock"
        icon.width: mainButtonsLayout.iconSize
        icon.height: mainButtonsLayout.iconSize
        display: AbstractButton.IconOnly
        highlighted: true
        Material.accent: Material.color(Material.Grey, Material.Shade700)
        checkable: true
    }

    ColumnLayout { }

}
