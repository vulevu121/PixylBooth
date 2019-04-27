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

Label {
    id: mainLabel
    text: ""
    property alias subtitle: sub.text
    property alias textColor: mainLabel.color
    property alias subtitleColor: sub.color
    color: Material.foreground

    Label {
        id: sub
        x: 0
        text: ""
        anchors.topMargin: 0
        anchors.top: mainLabel.bottom
        color: Material.primary
        font.pixelSize: mainLabel.font.pixelSize * 0.8
    }

}





/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
