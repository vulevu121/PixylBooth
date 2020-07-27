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
//    property int thumbnailWidth: root.width


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

//        width: parent.width
//        height: parent.height
//        anchors.centerIn: Overlay.overlay
//        parent: parent
        parentWidth: parent.width
        parentHeight: parent.height

        anchors.centerIn: parent

        saveFolder: settings.saveFolder


    }



    Component {
        id: photoDelegate
        Item {
//            width: root.width
//            height: settings.print6x4Split ? root.height : root.width / photoAspectRatio
            width: view.cellWidth
            height: view.cellHeight

            Behavior on width {
                id: behavior
//                property Item moveTarget: targetProperty.object

                NumberAnimation {
                    duration: 200
                }


//                ParallelAnimation {
//                    NumberAnimation {
//                        target: behavior.moveTarget
//                        properties: "x,y"
//                        duration: 200
//                    }
//                    NumberAnimation {
//                        target: behavior.moveTarget
//                        properties: "opacity"
//                        from: 0
//                        to: 1
//                        duration: 200
//                    }

//                }


            }

            Image {
                id: mainImage
                source: addFilePrefix(filePath)

                anchors.fill: parent
                anchors.margins: pixel(4)

                cache: false
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                sourceSize.width: 1280


//                BusyIndicator {
//                    anchors.centerIn: parent
//                    running: mainImage.status == Image.Loading
//                }

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

    GridView {
        id: view
        anchors.fill: parent
        model: folderListModel
        delegate: photoDelegate

        cellWidth: parent.width
        cellHeight: settings.portraitModeSwitch ? cellWidth / photoAspectRatio : cellWidth * photoAspectRatio

        ScrollBar.vertical: ScrollBar {}

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 1000
            }
        }

//        populate: Transition {
//            NumberAnimation {
//                properties: "x,y"
//                duration: 1000
//            }
//        }

//        remove: Transition {
//            NumberAnimation {
//                properties: "x,y"
//                duration: 1000
//            }
//        }

//        move: Transition {
//            NumberAnimation {
//                properties: "x,y"
//                duration: 1000
//            }
//        }
    }


    TabBar {
        id: galleryTabBar
        position: TabBar.Footer
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        z: 5
        background: Rectangle {
            color: "#000000"
            opacity: 0.8
        }

        property real iconSize: pixel(32)

        TabButton {
            text: "Large"
            width: implicitWidth
            icon.source: "qrc:/svg/stop-solid"
            icon.width: galleryTabBar.iconSize
            icon.height: galleryTabBar.iconSize
            display: AbstractButton.TextUnderIcon

            onClicked: {
                view.cellWidth = root.width
//                thumbnailWidth = root.width
            }
        }

        TabButton {
            text: "Small"
            width: implicitWidth
            icon.source: "qrc:/svg/th-large-solid"
            icon.width: galleryTabBar.iconSize
            icon.height: galleryTabBar.iconSize
            display: AbstractButton.TextUnderIcon

            onClicked: {
                view.cellWidth = root.width / 2
//                thumbnailWidth = root.width / 2
            }
        }
    }
}
