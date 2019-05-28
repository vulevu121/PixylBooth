import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3


Item {
    id: login
    property alias username: usernameField.text
    property alias password: passwordField.text

    Rectangle {
        id: rectangle1
        color: "#000000"
        anchors.fill: parent

        Rectangle {
            id: rectangle
            color: "#303030"
            radius: 30
            anchors.rightMargin: 20
            anchors.leftMargin: 20
            anchors.bottomMargin: 20
            anchors.topMargin: 20
            anchors.fill: parent
            opacity: 1

            GridLayout {
                id: gridLayout
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 2

                Label {
                    text: qsTr("Username")
                    font.pixelSize: usernameField.font.pixelSize
                    color: Material.foreground
                }

                TextField {
                    id: usernameField
                    text: ""
                    Layout.fillWidth: true
                    placeholderText: "enter your email"
                }

                Label {
                    text: qsTr("Password")
                    font.pixelSize: passwordField.font.pixelSize
                    color: Material.foreground
                }

                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    placeholderText: "password"
                    passwordCharacter: "*"

                }

                CheckBox {
                    id: checkBox
                    text: qsTr("Remember")
                }

                Button {
                    id: loginButton
                    text: qsTr("Login")
                    Layout.columnSpan: 1
                    Layout.rowSpan: 1
                }

            }



        }
    }

}







/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:1;anchors_height:200;anchors_width:200}
}
 ##^##*/
