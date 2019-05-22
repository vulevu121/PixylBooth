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
    height: width * 3
    width: pixel(10)
    color: Material.background
    radius: height / 2
    
    property real min: 0
    property real value: min
    property real max: 99

    RoundButton {
        height: width
        width: parent.width
        icon.source: "qrc:/Images/add_white_48dp.png"
        icon.width: root.height
        icon.height: root.height
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        onClicked: {
            root.value = root.value < max ? (root.value + 1) : max
        }
    }


    Text {
        id: valueText
        text: parent.value
        height: width
        width: parent.width
        color: Material.foreground
        font.pixelSize: height - pixel(6)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

    }

    RoundButton {
        height: width
        width: parent.width
        icon.source: "qrc:/Images/remove_white_48dp.png"
        icon.width: root.height
        icon.height: root.height

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter


        onClicked: {
            root.value = root.value > min ? (root.value - 1) : min
        }
    }
    

    
    
}
