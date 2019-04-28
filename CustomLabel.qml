import QtQuick 2.0
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
    id: root
    color: "transparent"
    property alias text: mainLabel.text
    property alias subtitle: sub.text
    property alias textColor: mainLabel.color
    property alias subtitleColor: sub.color

    Column {
//        spacing: pixel(1)
        anchors.fill: parent

        Text {
            id: mainLabel
            width: root.width
            text: ""
            color: Material.foreground
            fontSizeMode: Text.VerticalFit
            font.pixelSize: root.height
            height: root.height * 0.8
        }
        Text {
            id: sub
            width: root.width
            text: ""
            color: Material.accent
            fontSizeMode: Text.VerticalFit
            font.pixelSize: root.height
            height: root.height * 0.2
        }
    }


}






/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
