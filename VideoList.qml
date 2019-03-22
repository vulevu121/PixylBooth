import QtQuick 2.0
//import QtQuick.Window 2.2
//import QtQuick.VirtualKeyboard 2.2
//import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
//import Qt.labs.platform 1.1
//import QtQuick.Dialogs 1.3
import Qt.labs.folderlistmodel 2.0

Rectangle {
    id: videoList
    width: 200
    height: 200
    color: "#000000"
    property alias model: listView.model
    property alias delegate: listView.delegate
    property alias addButton: addButton
    property alias subButton: subButton
    property alias title: label.text
    Layout.minimumHeight: 250
    Layout.fillWidth: true

    Rectangle {
        id: topBar
        height: 32
        anchors.top: parent.top
        color: "#222"
        z: 1
        anchors.right: parent.right
        anchors.left: parent.left

        Label {
            id: label
            text: "Videos"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    ListView {
        id: listView
        anchors.top: topBar.bottom
        anchors.right: parent.right
        anchors.bottom: bottomBar.top
        anchors.left: parent.left
        boundsBehavior: Flickable.DragOverBounds
        Layout.fillWidth: true
        spacing: 5

    }

    Rectangle {
        id: bottomBar
        height: addButton.height
        color: "#222"
        anchors.bottom: parent.bottom
        z: 1
        anchors.right: parent.right
        anchors.left: parent.left

        RowLayout {
            anchors.fill: parent

            Button {
                id: addButton
                text: qsTr("+")
                font.pointSize: 14

            }
            Button {
                id: subButton
                text: qsTr("-")
                font.pointSize: 14

            }
            RowLayout {
            }
        }
    }
}
