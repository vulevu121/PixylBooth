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

    Settings {
        property alias captureTimer: root.captureTimer
        property alias durationPhoto: root.durationPhoto
    }

    CustomPane {
        id: customPane
        title: "General"
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        ColumnLayout {
            id: columnLayout
            anchors.fill: parent
            spacing: 20

            RowLayout {
                id: rowLayout1
                width: 100
                height: 100


                CustomLabel {
                    id: mainLabel
                    Layout.minimumWidth: 200
                    font.pixelSize: 24
                    height: 48
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("Capture Timer")
                    subtitle: qsTr("Time between each photo")
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
                    id: captureTimerEdit
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
                    text: qsTr("Photo Timer")
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
                    id: captureTimerEdit1
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

                Label {
                    id: label
                    text: qsTr("Directory")
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }

                TextField {
                    id: directoryField
                    text: qsTr("")
                    enabled: false
                    font.pointSize: 12
                    Layout.fillWidth: true
                    placeholderText: "Choose a save folder..."
                }


                Button {
                    id: button
                    text: qsTr("...")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.fillWidth: false
                    onClicked: {
                        folderDialog.open()
                    }

                    FolderDialog {
                        id: folderDialog
                        title: "Please select save directory"
                        onAccepted: {
                            directoryField.text = folder
                        }
                    }

                }



            }


            RowLayout {
                id: rowLayout10
                width: 100
                height: 100
            }



        }
    }

}



































/*##^## Designer {
    D{i:3;anchors_x:0;anchors_y:30}
}
 ##^##*/
