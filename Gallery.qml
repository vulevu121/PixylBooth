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
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    color: "transparent"
    property alias folder: folderListModel.folder
    property alias model: gridView.model
    property alias cellWidth: gridView.cellWidth
    property bool showFileName: false


    FolderListModel {
        id: folderListModel
        folder: ""
        nameFilters: ["*.jpg", "*.JPG", "*.png", "*.PNG"]
        showDirs: false
        sortField: FolderListModel.Name
        sortReversed: true

    }


    Rectangle {
        id: blurRect
        color: "#000000"
        opacity: 0
        anchors.fill: parent
        z: 4

        Behavior on opacity {

            NumberAnimation {
                duration: 200
            }
        }
    }

    ImagePopup {
        id: imagePopup
        anchors.centerIn: parent
        width: root.width * 0.9
        height: width * 0.75

        onClosed: {
            blurRect.opacity = 0
        }

        Overlay.modal: GaussianBlur {
            source: root
            radius: 8
            samples: 16
            deviation: 3
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
                    width: parent.width - pixel(5)
                    height: width * 0.75
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
                            imagePopup.source = addFilePrefix(filePath)
                            imagePopup.open()
                            blurRect.opacity = 0.5
                        }
                    }
                }
                Text {
                    text: fileName
                    color: Material.foreground
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: showFileName
                }
            }
        }
    }
    
    GridView {
        id: gridView
        width: root.width - pixel(5)
        height: root.height - pixel(5)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        cellWidth: (root.width / 2) - pixel(10)
        cellHeight: cellWidth * 0.75 + pixel(3)
        model: folderListModel
        delegate: photoDelegate
//        highlight: Rectangle {
//            color: Material.accent
//            radius: pixel(2)
//        }
        focus: true
        cacheBuffer: 40

    }
}
