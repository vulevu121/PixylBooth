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
//        width: root.width * 0.98
////        height: root.height * 0.95
//        y: pixel(2)
//        x: (mainWindow.width - width)/2

        width: parent.width
        height: parent.height
        anchors.centerIn: Overlay.overlay

        saveFolder: settings.saveFolder


    }

    Component {
        id: photoDelegate
        Item {
            width: root.width
            height: root.height

            Image {
                id: mainImage
                source: addFilePrefix(filePath)

                width: parent.width
                height: parent.height

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
    

    ListView {
        id: view
        anchors.fill: parent
        model: folderListModel
        delegate: photoDelegate

        ScrollBar.vertical: ScrollBar {}
    }
}
