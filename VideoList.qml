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
    color: "#151515"
    radius: 4
    property alias model: listView.model
    property alias delegate: listView.delegate
    property alias addButton: addButton
    property alias subButton: subButton
    property alias clearButton: clearButton
    property alias title: label.text
    Layout.minimumHeight: 250
    Layout.fillWidth: true
    
   
    Rectangle {
        id: topBar
        height: 32
        radius: 4
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
                color: "#151515"
            }
            
            GradientStop {
                position: 1
                color: "#151515"
            }
            
            
        }
        anchors.top: parent.top
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
        delegate: fileDelegate
        
        Component {
            id: fileDelegate
            Row {
                spacing: 5
    
                Image {
                    id: folderPicture
                    source: "qrc:/Images/file_white_48dp.png"
                    width: 32
                    height: 32
                }
    
                Text {
                    text: fileName
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                    color: "white"
                }
    
                Rectangle {
                    id: wrapper
                    width: 200
                    height: 48
                    visible: false
                }
            }
        }

        highlight: Rectangle {
            color: Material.color(Material.LightBlue)
            radius: 2
//            visible: videoList.showFocusHighlight && listView.count !== 0
        }
        highlightMoveVelocity: 1000
        pressDelay: 100
        focus: true
        
    }
    
    Rectangle {
        id: bottomBar
        height: addButton.height
        radius: 4
        gradient: Gradient {
            GradientStop {
                position: 0
                color: "#151515"
            }
            
            GradientStop {
                position: 0.05
                color: "#151515"
            }
            
            GradientStop {
                position: 0.051
                color: "#333"
            }

            GradientStop {
                position: 1
                color: "#151515"
            }
        }
        anchors.bottom: parent.bottom
        z: 1
        anchors.right: parent.right
        anchors.left: parent.left

        RowLayout {
            anchors.fill: parent
            
            RowLayout {}

            Button {
                id: addButton
                text: qsTr("+")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: 14

            }
            Button {
                id: subButton
                text: qsTr("-")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: 14

            }
            Button {
                id: clearButton
                text: qsTr("Clear")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: 14
            }
            
            Button {
                text: "Up"
                onClicked: {
                    listView.decrementCurrentIndex()
                }
            }
            
            Button {
                text: "Down"
                onClicked: {
                    listView.incrementCurrentIndex()
                }
            }
            
            Button {
                text: "Delete"
                onClicked: {
                    model.remove(0)
                }
            }
            
            RowLayout {}

        }
    }
}





















/*##^## Designer {
    D{i:0;width:600}
}
 ##^##*/
