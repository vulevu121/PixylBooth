import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.0

Rectangle {
    id: root
    color: "#151515"
    radius: pixel(3)
    property alias model: listView.model
    property alias addButton: addButton
    property alias deleteButton: deleteButton
    property alias clearButton: clearButton
    property alias title: label.text

    property real rowHeight: pixel(4)

    Layout.minimumHeight: pixel(70)


    Rectangle {
        id: topBar
        height: pixel(8)
        radius: pixel(1)
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left

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


        Label {
            id: label
            text: "Videos"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Component {
        id: fileDelegate
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.rowHeight + pixel(4)
            Row {
                anchors.margins: pixel(2)
                anchors.fill: parent
                spacing: pixel(1)

                Image {
                    id: folderPicture
                    source: "qrc:/Images/file_white_48dp.png"
                    width: root.rowHeight
                    height: root.rowHeight
                    anchors.verticalCenter: parent.verticalCenter
                }


                Text {
                    text: getFileName()
                    font.bold: true
                    color: Material.foreground
                    anchors.verticalCenter: parent.verticalCenter

                    function getFileName() {

                        var path = source.toString()
                        var pathSplit = ""
                        pathSplit = path.split("/")
                        var fileName = pathSplit[pathSplit.length - 1]

                        return fileName
                    }
                }

            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex = index
                }
            }

        }

    }

    Rectangle {
        anchors.top: topBar.bottom
        anchors.right: parent.right
        anchors.bottom: bottomBar.top
        anchors.left: parent.left
        clip: true
        color: "#151515"

        ListView {
            id: listView
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            spacing: pixel(2)
            delegate: fileDelegate

            highlight: Rectangle {
                color: Material.accent
            }

            highlightMoveVelocity: 3000
            pressDelay: 100
            focus: true

        }
    }

    
    Rectangle {
        id: bottomBar
        height: addButton.height
        radius: pixel(1)
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

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
                id: clearButton
                text: qsTr("Clear")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pointSize: 14
            }
            

            Button {
                id: deleteButton
                text: "-"
                onClicked: {
                    model.removeItem(listView.currentIndex)
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
