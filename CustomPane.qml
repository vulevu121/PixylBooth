import QtQuick 2.0
//import QtQuick.Window 2.2
//import QtQuick.VirtualKeyboard 2.2
//import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
//import QtQuick.Controls.Material 2.12
//import QtQuick.Layouts 1.3
//import Qt.labs.platform 1.1
//import QtQuick.Dialogs 1.3
//import Qt.labs.settings 1.1

Pane {
    id: root
    property string backgroundColor: "#191919"
    property alias title: label.text
    topPadding: titleBar.height

    background: Rectangle {

        radius: 6
        anchors.fill: parent
        color: backgroundColor

        Rectangle {
            id: titleBar
            height: label.height * 1.5

            color: "#555555"
            radius: 6
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#555"
                }

                GradientStop {
                    position: 0.95
                    color: "#333"
                }

                GradientStop {
                    position: 0.96
                    color: backgroundColor
                }

                GradientStop {
                    position: 1
                    color: backgroundColor
                }
            }

            Label {
                id: label
                text: qsTr("")
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 18
                anchors.verticalCenterOffset: 0
                anchors.verticalCenter: parent.verticalCenter
            }

        }

    }


}













































/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
