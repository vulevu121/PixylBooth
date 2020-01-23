import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.1

Button {
    property alias bg: bg

    background: Rectangle {
        id: bg
        border.width: 2
        border.color: "#8BC34A"
        color: "#80000000"
        radius: pixel(2)

        clip: true

        Rectangle {
            id: highlightRect
            anchors.centerIn: parent
            width: parent.width
            height: width
//            opacity: 0
            scale: 0
            color: bg.border.color
            radius: width/2

            PropertyAnimation {
                running: pressed
                target: highlightRect
                properties: "opacity, scale"
                to: 1.3
//                duration: 300
                easing.type: Easing.OutExpo
            }

            PropertyAnimation {
                running: !pressed
                target: highlightRect
                properties: "opacity, scale"
                to: 0
//                duration: 300
                easing.type: Easing.OutExpo
            }
        }
    }
    display: AbstractButton.TextBesideIcon
    font.capitalization: Font.MixedCase

    icon.width: font.pixelSize
    icon.height: font.pixelSize

//    highlighted: true
//    Material.accent: Material.color(Material.Green, Material.Shade700)
//    checkable: true

}
