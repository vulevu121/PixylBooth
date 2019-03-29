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
import Qt.labs.settings 1.1

ColumnLayout {
    id: root

    property alias startVideoListModel: startVideoListModel
    property alias beforeCaptureVideoListModel: beforeCaptureVideoListModel
    property alias afterCaptureVideoListModel: afterCaptureVideoListModel

//    property string lastFolder: "file:///Users/Vu/Documents/PixylBooth/Videos"
    property string lastFolder: "file:///"

    property string startVideosListModelString: ""
    property string beforeCaptureVideosListModelString: ""
    property string afterCaptureVideosListModelString: ""


    Settings {
        category: "Videos"
        property alias startVideos: root.startVideosListModelString
        property alias beforeCaptureVideos: root.beforeCaptureVideosListModelString
        property alias afterCaptureVideos: root.afterCaptureVideosListModelString
        property alias lastFolder: root.lastFolder
    }

    Component.onCompleted: {
        var i
        if (startVideosListModelString) {
          startVideoListModel.clear()
          var datamodel = JSON.parse(startVideosListModelString)
          for (i = 0; i < datamodel.length; ++i) startVideoListModel.append(datamodel[i])
        }

        if (beforeCaptureVideosListModelString) {
          beforeCaptureVideoListModel.clear()
          var datamodel2 = JSON.parse(beforeCaptureVideosListModelString)
          for (i = 0; i < datamodel2.length; ++i) beforeCaptureVideoListModel.append(datamodel2[i])
        }

        if (afterCaptureVideosListModelString) {
          afterCaptureVideoListModel.clear()
          var datamodel3 = JSON.parse(afterCaptureVideosListModelString)
          for (i = 0; i < datamodel3.length; ++i) afterCaptureVideoListModel.append(datamodel3[i])
        }

    }

    Component.onDestruction: {
        var datamodel = []
        var i
        for (i = 0; i < startVideoListModel.count; ++i) datamodel.push(startVideoListModel.get(i))
        startVideosListModelString = JSON.stringify(datamodel)

        var datamodel2 = []
        for (i = 0; i < beforeCaptureVideoListModel.count; ++i) datamodel2.push(beforeCaptureVideoListModel.get(i))
        beforeCaptureVideosListModelString = JSON.stringify(datamodel2)

        var datamodel3 = []
        for (i = 0; i < afterCaptureVideoListModel.count; ++i) datamodel3.push(afterCaptureVideoListModel.get(i))
        afterCaptureVideosListModelString = JSON.stringify(datamodel3)
    }

    function setLastFolder(folder) {
        lastFolder = folder
    }


    function addStartVideo(path) {
        var pathSplit = ""
        pathSplit = path.split("/")
        var fileName = pathSplit[pathSplit.length - 1]

        startVideoListModel.append({ "fileName": fileName, "filePath": path })
        createStartVideosListModelString()

    }

    function addBeforeCaptureVideo(path) {
        var pathSplit = ""
        pathSplit = path.split("/")
        var fileName = pathSplit[pathSplit.length - 1]

        beforeCaptureVideoListModel.append({ "fileName": fileName, "filePath": path })
    }

    function addAfterCaptureVideo(path) {
        var pathSplit = ""
        pathSplit = path.split("/")
        var fileName = pathSplit[pathSplit.length - 1]

        afterCaptureVideoListModel.append({ "fileName": fileName, "filePath": path })
    }


    ListModel {
        id: startVideoListModel
    }

    ListModel {
        id: beforeCaptureVideoListModel
    }

    ListModel {
        id: afterCaptureVideoListModel
    }



    Popup {
        id: filePopup
        anchors.centerIn: parent
        width: root.width
        height: root.height * 0.5
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnReleaseOutside
        z: 10

        FileBrowser {
            id: startVideoBrowser
            folder: lastFolder
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(addStartVideo)
            }
        }

        FileBrowser {
            id: beforeCaptureVideoBrowser
            folder: lastFolder
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(addBeforeCaptureVideo)
            }
        }

        FileBrowser {
            id: afterCaptureVideoBrowser
            folder: lastFolder
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(addAfterCaptureVideo)
            }
        }
    }

    Pane {
        id: pane
        Layout.minimumWidth: 500
        Layout.preferredWidth: root.width * 0.9
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        background: Rectangle {
            color: "transparent"
        }

        ColumnLayout {
            id: columnLayout1
            anchors.fill: parent

            Button {
                text: "test"
                onClicked: {
                    startVideoListModel.remove(0)
                }
            }

            VideoList {
                id: startVideoList
                Layout.fillWidth: true
                title: "Start Videos"
                //                delegate: fileDelegate
                model: startVideoListModel

                addButton.onClicked: {
                    startVideoBrowser.show()
                    filePopup.open()
                }
                clearButton.onClicked: {
                    startVideoListModel.clear()
                }

            }

            VideoList {
                id: beforeCaptureVideoList
                Layout.fillWidth: true
                title: "Before Capture Videos"
                //                delegate: fileDelegate
                model: beforeCaptureVideoListModel

                addButton.onClicked: {
                    beforeCaptureVideoBrowser.show()
                    filePopup.open()
                }
                clearButton.onClicked: {
                    beforeCaptureVideoListModel.clear()
                }
            }

            VideoList {
                id: afterCaptureVideoCaptureList
                Layout.fillWidth: true
                title: "After Capture Videos"
                //                delegate: fileDelegate
                model: afterCaptureVideoListModel

                addButton.onClicked: {
                    afterCaptureVideoBrowser.show()
                    filePopup.open()
                }
                clearButton.onClicked: {
                    afterCaptureVideoListModel.clear()
                }

            }
            RowLayout {  }

        }
    }
}
