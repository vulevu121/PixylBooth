import QtQuick 2.12
import QtQuick.Window 2.2
//import QtQuick.VirtualKeyboard 2.2
//import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
//import QtQuick.Controls.Material 2.12
//import QtQuick.Layouts 1.3
//import Qt.labs.platform 1.1
//import QtQuick.Dialogs 1.3
//import Qt.labs.settings 1.1
//import QtMultimedia 5.4
//import Process 1.0
//import SonyAPI 1.0
//import SonyLiveview 1.0
//import ProcessPhotos 1.0
//import PrintPhotos 1.0
import Qt.labs.folderlistmodel 2.0
//import QtGraphicalEffects 1.0

Rectangle {
    id: root
    color: "transparent"
    property alias folder: folderListModel.folder
    property alias model: view.model
//    property alias cellWidth: pixel(100)
    property bool showFileName: false
    property alias view: view

    function updateView() {
        view.model = []
        view.model = folderListModel
    }

    FolderListModel {
        id: folderListModel
        folder: ""
        nameFilters: ["*.jpg", "*.JPG", "*.png", "*.PNG"]
        showDirs: false
        sortField: FolderListModel.Time
    }

    CanvasPopup {
        id: imagePopup
        width: root.width * 0.98
        y: pixel(2)
        x: (mainWindow.width - width)/2
        saveFolder: settings.saveFolder
    }

    Component {
        id: photoDelegate
        Item {
            width: parent.width
            height: width / photoAspectRatio

            Image {
                id: mainImage
                source: addFilePrefix(filePath)
                anchors {
                    fill: parent
                    margins: pixel(10)
                }
                cache: false
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                sourceSize.width: 600

                BusyIndicator {
                    anchors.centerIn: parent
                    running: mainImage.status == Image.Loading
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        view.currentIndex = index
                        imagePopup.source = addFilePrefix(filePath)
                        imagePopup.open()

                    }
                }
            }

        }
    }
    
//    GridView {
//        id: view

//        anchors {
//            fill: parent
//        }

//        cellWidth: parent.width
//        cellHeight: cellWidth / photoAspectRatio
//        model: folderListModel
//        delegate: photoDelegate

//    }

    ListView {
        id: view
        anchors.fill: parent
        model: folderListModel
        delegate: photoDelegate

        ScrollBar.vertical: ScrollBar {}
    }
}
