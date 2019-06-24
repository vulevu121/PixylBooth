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
//                anchors.fill: parent
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    z: 5
    opacity: 0.8
    spacing: pixel(6)
    property real iconSize: pixel(10)



    UpDownButtonVertical {
        id: exposureButton
        min: -15
        max: 15
        value: 0
        scale: 1.2
        Layout.alignment: Qt.AlignHCenter

        onValueChanged: {
            sonyAPI.setExposureCompensation(exposureButton.value)
            toast.show("Camera exposure set to " + exposureButton.value)
        }

        Timer {
            id: getExposureTimer
            interval: 3000
            repeat: false
            running: true

            onTriggered: {
                sonyAPI.getExposureCompensation()
            }

        }

    }

    Button {
        id: undoLastButton
        text: "Undo Last"
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: "qrc:/Images/settings_backup_restore_white_48dp.png"
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
                resetCountdownTimer()
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
        icon.source: "qrc:/Images/cached_white_48dp.png"
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
        id: fullScreenButton
        text: "Full Screen"
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: mainWindow.visibility === Window.FullScreen ? "qrc:/Images/fullscreen_exit_white_48dp.png" : "qrc:/Images/fullscreen_white_48dp.png"
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

    Button {
        text: "Exit"
        flat: false
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        icon.source: "qrc:/Images/cancel_white_48dp.png"
        icon.width: mainButtonsLayout.iconSize
        icon.height: mainButtonsLayout.iconSize
        display: AbstractButton.IconOnly
        highlighted: true
        Material.accent: Material.color(Material.Grey, Material.Shade700)
        onClicked: {
            mainWindow.close()
        }
    }




    ColumnLayout { }

}
