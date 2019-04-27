import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.1
import QtMultimedia 5.4
import Process 1.0
import SonyAPI 1.0
import SonyLiveview 1.0
import ProcessPhotos 1.0
import PrintPhotos 1.0
import Qt.labs.folderlistmodel 2.0


Rectangle {
    id: root
    color: "transparent"
    property alias folder: folderListModel.folder

    FolderListModel {
        id: folderListModel
        folder: ""
        nameFilters: ["*.jpg", "*.JPG", "*.png", "*.PNG"]
        showDirs: false
    }
    Popup {
        id: imagePopup
        anchors.centerIn: parent
        width: root.width * 0.9
        height: width * 0.75
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        modal: true

        Image {
            id: imageView
            anchors.fill: parent
            asynchronous: true
            BusyIndicator {
                anchors.centerIn: parent
                running: imageView.status == Image.Loading
            }
        }
    }
    
    Component {
        id: photoDelegate
        Item {
            width: gridView.cellWidth
            height: gridView.cellHeight
            Column {
                anchors.fill: parent
                
                Image {
                    id: mainImage
                    source: addFilePrefix(filePath)
                    width: parent.width * 0.9
                    height: parent.height * 0.9
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: 600
                    anchors.horizontalCenter: parent.horizontalCenter
                    asynchronous: true
                    
                    BusyIndicator {
                        anchors.centerIn: parent
                        running: mainImage.status == Image.Loading
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            gridView.currentIndex = index
                            imageView.source = addFilePrefix(filePath)
                            imagePopup.open()
                        }
                    }
                }
                Text {
                    text: fileName
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
    
    GridView {
        id: gridView
        width: root.width - toPixels(0.05)
        height: root.height - toPixels(0.10)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        cellWidth: root.width / 2.5
        cellHeight: cellWidth * 0.75
        model: folderListModel
        delegate: photoDelegate
        highlight: Rectangle { color: "gray"; radius: 5 }
        focus: true
        cacheBuffer: 40
    }
}
