import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.0
import QtQuick.Dialogs 1.3

Rectangle {
    id: root
    color: "#151515"
    radius: pixel(1)
    property alias playlist: listView.model
    property alias addButton: addButton
    property alias deleteButton: deleteButton
    property alias clearButton: clearButton
    property alias title: label.text
    property real viewHeight: pixel(80)
    property bool hide: true
    property real rowHeight: pixel(4)
    signal saveRequest

    implicitHeight: hide ? topBar.height : viewHeight

    Layout.minimumHeight: topBar.height

    function collapse() {
        hide = true
    }

    function expand() {
        hide = false
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 100
        }
    }

    FileDialog {
        id: fileDialog
        title: "Please choose videos"
        folder: shortcuts.home
        selectMultiple: true
        nameFilters: [ "Video files (*.avi *.mp4)", "All files (*)" ]

        onAccepted: {
            playlist.addItems(fileUrls)
            root.saveRequest()
        }
    }


    Rectangle {
        id: topBar
        height: pixel(10)
        radius: pixel(1)
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left

        MouseArea {
            anchors.fill: parent
            onClicked: {
                hide = !hide
            }
        }

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

        RowLayout {
            anchors.fill: parent

            RowLayout {}

            Button {
                id: addButton
                text: "Add"
                icon.source: "qrc:/icons/add"
                display: AbstractButton.IconOnly
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                implicitWidth: pixel(10)
                implicitHeight: pixel(10)

                onClicked: {
                    fileDialog.open()
                }

            }

            Button {
                id: clearButton
                text: "Clear"
                icon.source: "qrc:/icons/clear-all"
                display: AbstractButton.IconOnly
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                implicitWidth: pixel(10)
                implicitHeight: pixel(10)

                onClicked: {
                    playlist.clear()
                    root.saveRequest()
                }
            }


            Button {
                id: deleteButton
                text: "Remove"
                icon.source: "qrc:/icons/remove"
                display: AbstractButton.IconOnly
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                implicitWidth: pixel(10)
                implicitHeight: pixel(10)
                onClicked: {
                    playlist.removeItem(listView.currentIndex)
                    root.saveRequest()
                }
            }


        }


        Label {
            id: label
            text: "Videos"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: pixel(2)
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
                    source: "qrc:/icons/video"
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
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        clip: true
        color: "#151515"
        radius: pixel(1)

        ListView {
            id: listView
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
//            delegate: fileDelegate
            delegate: ItemDelegate {
                function getFileName() {
                    var path = source.toString()
                    var pathSplit = ""
                    pathSplit = path.split("/")
                    var fileName = pathSplit[pathSplit.length - 1]
                    return fileName
                }
                width: parent.width
                text: getFileName()
                icon.source: "qrc:/icons/video"
                display: AbstractButton.TextBesideIcon
                onClicked: listView.currentIndex = index
            }

            ScrollBar.vertical: ScrollBar {}

            highlight: Rectangle {
                color: Material.color(Material.Cyan, Material.Shade800)
            }

            highlightMoveDuration: 100
        }
    }

    

}





















/*##^## Designer {
    D{i:0;width:600}
}
 ##^##*/
