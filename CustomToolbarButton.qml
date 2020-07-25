import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.1


ToolButton {
//    property alias bg: bg

    display: AbstractButton.TextUnderIcon
//    font.capitalization: Font.MixedCase

    icon.width: font.pixelSize
    icon.height: font.pixelSize
//    flat: true

    text: qsTr("Button")


    background: Rectangle {
        anchors.fill: parent
        id: bg
//        border.width: 2
//        border.color: "#8BC34A"
        color: "#50000000"
        radius: pixel(8)
        clip: true

        Rectangle {
            id: highlightRect
            anchors.centerIn: parent
            anchors.fill: parent
//            width: parent.width
//            height: parent.height
            scale: 0
            color: icon.color
            radius: width/2

            ParallelAnimation {
                id: highlightAnimation
                running: pressed
                alwaysRunToEnd: true

                NumberAnimation {
                    target: highlightRect
                    properties: "scale"
                    from: 0
                    to: 1.5
                    duration: 1000
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: highlightRect
                    properties: "opacity"
                    from: 1.0
                    to: 0
                    duration: 1000
                    easing.type: Easing.OutCubic
                }
            }
        }
    }


//    highlighted: true
//    Material.accent: Material.color(Material.Green, Material.Shade700)
//    checkable: true

}
