import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3

ColumnLayout {
    id: root
    signal playStartVideoSignal()
    signal playBeforeCaptureVideoSignal()
    signal setStartVideoSignal(string file)
    signal setBeforeCaptureVideoSignal(string file)

    function setTextField1(path) {
        textField.text = path
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
            folder: qsTr("file:///c:/Users/Vu/Documents/PixylBooth/Videos")
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(setStartVideoSignal)
                fileSelected.connect(setTextField1)
            }
        }

        FileBrowser {
            id: beforeCaptureVideoBrowser
            folder: qsTr("file:///c:/Users/Vu/Documents/PixylBooth/Videos")
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(setBeforeCaptureVideoSignal)
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
                id: rowLayout
                width: 100
                height: 100

                Label {
                    id: label
                    text: qsTr("Start Video")
                }

                TextField {
                    id: textField
                    text: qsTr("")
                    placeholderText: "Choose a start video"
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Button {
                    text: qsTr("Play Start Video")
                    onClicked: {
                        playStartVideoSignal()
                    }
                }

                Button {
                    text: qsTr("Play Before Capture Video")
                    onClicked: {
                        playBeforeCaptureVideoSignal()
                    }
                }

                Button {
                    text: "Choose Start Video"
                    onClicked: {
                        startVideoBrowser.show()
                        filePopup.open()
                    }
                }

                Button {
                    text: "Choose Before Capture Video"
                    onClicked: {
                        beforeCaptureVideoBrowser.show()
                        filePopup.open()
                    }

                }
            }
        }
    }
}
