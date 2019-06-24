import QtQuick 2.0
import Qt.labs.folderlistmodel 2.0
import QtGraphicalEffects 1.12
import QtMultimedia 5.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12

Rectangle {
    id: root
    color: "transparent"

    property alias folder: folderListModel.folder

    property int itemHeight: Math.min(parent.width, parent.height) / 15
    property int buttonHeight: Math.min(parent.width, parent.height) / 12
    property Playlist playlist

    signal fileSelected(string file)
    signal browserClosed()

    function selectFile(file) {
        if (file !== "") {
            folder = loader.item.folders.folder
            fileBrowser.fileSelected(file)
            playlist.addItem(file)
        }
        loader.sourceComponent = undefined
        browserClosed()
    }

    FolderListModel {
        id: folderListModel
        folder: folder
        nameFilters: [ "*.mp4", "*.avi" ]
        showDirsFirst: true
    }

    Component {
        id: folderDelegate

        Rectangle {
            id: wrapper
            function launch() {
                var path = "file://";
                if (filePath.length > 2 && filePath[1] === ':') // Windows drive logic, see QUrl::fromLocalFile()
                    path += '/';
                path += filePath;
                if (folderListModel.isFolder(index))
                    down(path);
                else
                    fileBrowser.selectFile(path)
            }
            width: root.width
            height: folderImage.height
            color: "transparent"


            Item {
                id: folderImage
                width: itemHeight
                height: itemHeight
                Image {
                    id: folderPicture

                    source: folderListModel.isFolder(index) ? "qrc:/Images/folder_white_48dp.png" : "qrc:/Images/file_white_48dp.png"
                    width: itemHeight * 0.9
                    height: itemHeight * 0.9
                    anchors.left: parent.left
                    anchors.margins: 5
                }


            }

            Text {
                id: nameText
                anchors.fill: parent;
                verticalAlignment: Text.AlignVCenter
                text: fileName
                anchors.leftMargin: itemHeight + 10
                color: Material.foreground
                elide: Text.ElideRight

            }

            MouseArea {
                id: mouseRegion
                anchors.fill: parent
                onClicked: {
                    folderView.currentIndex = index;

                    if (folderListModel.isFolder(index)) {
                        folderListModel.folder = folderListModel.get(index, "fileURL")
                    }
                    else {
                        var file = folderListModel.get(index, "fileURL")
                        fileSelected(file)
                        playlist.addItem(file)
                    }
                }
            }


        }
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            width: parent.width
            height: buttonHeight
            spacing: pixel(2)

            Button {
                text: "Back"

                icon.source: "qrc:/Images/back_white_48dp.png"

                onClicked: {
                    folderListModel.folder = folderListModel.parentFolder
                }
            }

            Rectangle {
                height: itemHeight
                color: "#000000"
                Layout.fillHeight: false
                Layout.preferredHeight: itemHeight
                Layout.fillWidth: true
                clip: true
                radius: pixel(1)


                Text {
                    text: stripFilePrefix()
                    color: Material.foreground
                    anchors.fill: parent
                    anchors.margins: pixel(3)
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter

                    font.pointSize: 14

                    function stripFilePrefix() {
                        var newPath = folderListModel.folder.toString()
                        newPath = newPath.replace("file://", "")
                        return newPath
                    }
                }
            }


            Button {
                text: "Close"
                icon.source: "qrc:/Images/close_white_48dp.png"

                onClicked: {
                    browserClosed()
                }
            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            color: "transparent"

            ListView {
                id: folderView
                anchors.fill: parent
                model: folderListModel
                boundsBehavior: Flickable.StopAtBounds
                delegate: folderDelegate


                highlight: Rectangle {
                    color: Material.accent
                    width: folderView.width
                }
                highlightMoveVelocity: 3000
                pressDelay: 100
                focus: true

            }
        }


    }



}
