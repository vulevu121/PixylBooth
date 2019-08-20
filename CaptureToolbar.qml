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
    id: mainButtonsLayout
    width: iconSize
    height: iconSize*6 + iconSpacing*5
    color: "transparent"
//    spacing: pixel(6)
    property real iconSize: pixel(16)
    property alias playPauseButton: playPauseButton
    property alias lockButton: lockButton
    property int numberButtons: 6
    property real iconSpacing: pixel(2)

//    RowLayout {}

    Button {
        id: undoLastButton
        x: 0
        y: 0
        text: "Undo Last"
//        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: "qrc:/icon/undo_one"
        icon.width: mainButtonsLayout.iconSize
        icon.height: mainButtonsLayout.iconSize
        display: AbstractButton.IconOnly
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
        id: undoAllButton
        x: 0
        y: undoLastButton.y + iconSize + iconSpacing
        text: "Undo All"
//        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: "qrc:/icon/refresh"
        icon.width: mainButtonsLayout.iconSize
        icon.height: mainButtonsLayout.iconSize
        display: AbstractButton.IconOnly
        highlighted: true
        Material.accent: Material.color(Material.Cyan, Material.Shade700)

        onClicked: {
//            undoAllButtonAnimation.start()
            startState()
        }
    }

    Button {
        id: playPauseButton
        x: 0
        y: undoAllButton.y + iconSize + iconSpacing
        text: "Play/Pause"
//        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: checked ? "qrc:/icon/pause" : "qrc:/icon/play"
        icon.width: mainButtonsLayout.iconSize
        icon.height: mainButtonsLayout.iconSize
        display: AbstractButton.IconOnly
        highlighted: true
        Material.accent: Material.color(Material.Green, Material.Shade700)
        checkable: true

        onClicked: {

//            playPauseButtonAnimation.start()
            var playState = playPauseButton.checked

            if (root.state == "start") {
                liveView.start()
                beforeCaptureState()
            }

            if (root.state == "beforecapture") {
                beforeCaptureTimer.running = playState
            }

            if (root.state == "liveview") {
                countdownTimer.running = playState
            }

            if (root.state == "aftercapture") {
                afterCaptureTimer.running = playState
            }

            if (root.state == "review") {
                reviewTimer.running = playState
            }

            if (root.state == "endsession") {
                endSessionTimer.running = playState
            }

        }

    }


    Button {
        id: fullScreenButton
        x: lockButton.checked ? 0 : iconSize * 2
        y: playPauseButton.y + iconSize + iconSpacing
        text: "Full Screen"
//        Layout.alignment: Qt.AlignRight
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

        Behavior on x {
            NumberAnimation {
                duration: 200
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 200
            }
        }

    }

    Button {
        id: exitButton
        text: "Exit"
        flat: false
        x: lockButton.checked ? 0 : iconSize * 2
        y: fullScreenButton.y + iconSize + iconSpacing
//        Layout.alignment: Qt.AlignRight
        icon.source: "qrc:/icon/close"
        icon.width: mainButtonsLayout.iconSize
        icon.height: mainButtonsLayout.iconSize
        display: AbstractButton.IconOnly
        highlighted: true
        Material.accent: Material.color(Material.Grey, Material.Shade700)

        Behavior on x {
            NumberAnimation {
                duration: 200
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 200
            }
        }

        onClicked: {
            mainWindow.close()
        }
    }

    Button {
        id: lockButton
        x: 0
        y: checked? exitButton.y + iconSize + iconSpacing : playPauseButton.y + iconSize + iconSpacing
        text: "Lock"
        flat: false
        checked: true
//        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: checked ? "qrc:/icon/unlock" : "qrc:/icon/lock"
        icon.width: mainButtonsLayout.iconSize
        icon.height: mainButtonsLayout.iconSize
        display: AbstractButton.IconOnly
        highlighted: true
        Material.accent: Material.color(Material.Grey, Material.Shade700)
        checkable: true

        Behavior on x {
            NumberAnimation {
                duration: 200
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 200
            }
        }
    }

//    RowLayout {}

}
