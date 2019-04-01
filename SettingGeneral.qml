import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.1

ColumnLayout {
    id: root
    property alias captureTimer: captureTimerSlider.value
    property alias durationPhoto: displayTimerSlider.value
    property alias saveFolder: saveFolderField.text
    property alias liveViewImage: liveViewImageField.text

    Settings {
        property alias captureTimer: root.captureTimer
        property alias durationPhoto: root.durationPhoto
        property alias saveFolder: saveFolderField.text
        property alias liveViewImage: liveViewImageField.text
    }

    function stripFilePrefix(a) {
        if (a.search('C:') >= 0) {
            return a.replace("file:///", "")
        }
        return a.replace("file://", "")
    }

    CustomPane {
        id: customPane
        title: "General"
        Layout.preferredWidth: root.width * 0.9
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        ColumnLayout {
            id: columnLayout
            anchors.fill: parent
            spacing: 20

            RowLayout {
                width: 100
                height: 100

                CustomLabel {
                    Layout.minimumWidth: 200
                    font.pixelSize: 24
                    height: 48
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("Before Capture Video Time")
                    subtitle: qsTr("Time to display video before capture ")
                }

                Slider {
                    id: beforeCaptureTimerSlider
                    height: 48
                    Layout.fillWidth: true
                    stepSize: 1
                    to: 20
                    value: 5
                }

                Label {
//                    id: captureTimerEdit
                    height: 48
                    text: beforeCaptureTimerSlider.value + " s"
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }
            }

            RowLayout {
                id: rowLayout1
                width: 100
                height: 100


                CustomLabel {
//                    id: mainLabel
                    Layout.minimumWidth: 200
                    font.pixelSize: 24
                    height: 48
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("Capture Countdown")
                    subtitle: qsTr("Time before picture taken")
                }

                Slider {
                    id: captureTimerSlider
                    height: 48
                    Layout.fillWidth: true
                    stepSize: 1
                    to: 20
                    value: 5
                }

                Label {
//                    id: captureTimerEdit
                    height: 48
                    text: captureTimerSlider.value + " s"
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }
            }

            RowLayout {
                id: rowLayout2
                width: 100
                height: 100

                CustomLabel {
                    Layout.minimumWidth: 200
                    font.pixelSize: 24
                    height: 48
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("Review Time")
                    subtitle: qsTr("Duration to display photo")
                }

                Slider {
                    id: displayTimerSlider
                    Layout.fillWidth: true
                    transformOrigin: Item.Left
                    value: 5
                    stepSize: 1
                    to: 20
                }

                Label {
                    height: 48
                    text: displayTimerSlider.value + " s"
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }
            }

            RowLayout {
                id: rowLayout
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                spacing: 20

                CustomLabel {
                    id: label
                    text: qsTr("Save Folder")
                    subtitle: "Location to save photos"
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }

                TextField {
                    id: saveFolderField
                    font.pointSize: 12
                    Layout.fillWidth: true
                    placeholderText: "Choose a save folder..."

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            folderDialog.open()
                        }
                    }

                    FolderDialog {
                        id: folderDialog
                        title: "Please select save directory"
                        onAccepted: {
                            saveFolderField.text = root.stripFilePrefix(String(folder))
//                            console.log(folder)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                spacing: 20

                CustomLabel {
                    text: qsTr("LiveView Image")
                    subtitle: "Location of live view image"
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }

                TextField {
                    id: liveViewImageField
                    font.pointSize: 12
                    Layout.fillWidth: true
                    placeholderText: "Open live view image..."

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            liveViewImageFileDialog.open()
                        }
                    }


                    FileDialog {
                        id: liveViewImageFileDialog
                        title: "Open Live View Image"
                        folder: shortcuts.home
                        onAccepted: {
                            liveViewImageField.text = root.stripFilePrefix(String(fileUrl))
                        }

                        onRejected: {
//                                console.log("Canceled")
                            visible = false
                        }
                        Component.onCompleted: visible = false
                    }

                }
            }

            RowLayout {
            }
        }
    }

}





































/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:3;anchors_x:0;anchors_y:30}
}
 ##^##*/
