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
import PrintPhotos 1.0
import QtGraphicalEffects 1.12

Rectangle {
    id: root
    height: pixel(10)
    width: height * 3
    color: Material.background
    radius: height / 2
    
    property real min: 0
    property real value: 0
    property real max: 99
    
    RoundButton {
        height: parent.height
        width: height
        icon.source: "qrc:/Images/remove_white_48dp.png"
        icon.width: root.height
        icon.height: root.height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        onClicked: {
            root.value = root.value > min ? (root.value - 1) : min
        }
    }
    
    Text {
        id: valueText
        text: parent.value
        height: parent.height
        width: height
        color: Material.foreground
        font.pixelSize: height - pixel(6)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
    
    RoundButton {
        height: parent.height
        width: height
        icon.source: "qrc:/Images/add_white_48dp.png"
        icon.width: root.height
        icon.height: root.height
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        onClicked: {
            root.value = root.value < max ? (root.value + 1) : max
        }
    }
    
    
}
