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

ColumnLayout {
    id: root
    signal playStartVideoSignal
    signal playBeforeCaptureVideoSignal
    signal setStartVideoSignal(string file)
    signal setBeforeCaptureVideoSignal(string file)
    signal setAfterCaptureVideoSignal(string file)

    property alias startVideoListModel: startVideoListModel
    property alias beforeCaptureVideoListModel: beforeCaptureVideoListModel
    property alias afterCaptureVideoListModel: afterCaptureVideoListModel


    property string rootFolder: "file:///Users/Vu/Documents/PixylBooth/Videos"

    function addStartVideo(path) {
        var pathSplit = ""
        pathSplit = path.split("/")
        var fileName = pathSplit[pathSplit.length - 1]

        startVideoListModel.append({ "fileName": fileName, "filePath": path })

//        setStartVideoSignal(path)
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
        }
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
            folder: rootFolder
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(setStartVideoSignal)
                fileSelected.connect(addStartVideo)
            }
        }

        FileBrowser {
            id: beforeCaptureVideoBrowser
            folder: rootFolder
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(setBeforeCaptureVideoSignal)
                fileSelected.connect(addBeforeCaptureVideo)
            }
        }

        FileBrowser {
            id: afterCaptureVideoBrowser
            folder: rootFolder
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(setAfterCaptureVideoSignal)
                fileSelected.connect(addAfterCaptureVideo)
            }
        }
    }

    Pane {
        id: pane
        width: 200
        height: 200
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Material.elevation: 4

        ColumnLayout {
            id: columnLayout1
            width: 100
            height: 100

            RowLayout {
                Button {
                    text: qsTr("Start Video")
                    onClicked: {
                        playStartVideoSignal()
                    }
                }

                Button {
                    text: qsTr("Before Capture Video")
                    onClicked: {
                        playBeforeCaptureVideoSignal()
                    }
                }

                Button {
                    text: qsTr("After Capture Video")
                }
            }

            VideoList {
                id: startVideoList
                title: "Start Videos"
                delegate: fileDelegate
                model: startVideoListModel

                addButton.onClicked: {
                    startVideoBrowser.show()
                    filePopup.open()
                }

            }

            VideoList {
                id: beforeCaptureVideoList
                title: "Before Capture Videos"
                delegate: fileDelegate
                model: beforeCaptureVideoListModel

                addButton.onClicked: {
                    beforeCaptureVideoBrowser.show()
                    filePopup.open()
                }
            }

            VideoList {
                id: afterCaptureVideoCaptureList
                title: "After Capture Videos"
                delegate: fileDelegate
                model: afterCaptureVideoListModel

                addButton.onClicked: {
                    afterCaptureVideoBrowser.show()
                    filePopup.open()
                }
            }

        }
    }
}
