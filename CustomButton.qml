import QtQuick 2.0
import QtQuick.Controls.Styles 1.4

ButtonStyle {
    id: buttonStyle
    background: Rectangle {
                implicitWidth: 100
                implicitHeight: 25
                border.width: 2
                border.color: "#999"
                color: "black"
                radius: width / 2
            }
    label: Text {
        id: name
        text: control.text
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: "white"
        font.pixelSize: control.height * 0.8
    }
}
