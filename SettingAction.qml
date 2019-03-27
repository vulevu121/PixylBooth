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
//import QtGraphicalEffects 1.12
import QtMultimedia 5.4

ColumnLayout {
    id: root
    property alias captureAction: captureActionField.text
    property alias liveviewAction: liveViewField.text

    Settings {
        category: "Action"
        property alias captureAction: captureActionField.text
        property alias liveviewAction: liveViewField.text
    }

    CustomPane {
        id: cameraActions
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        title: "Camera Action"

        ColumnLayout {
            RowLayout {
                spacing: 10
                CustomLabel {
                    text: "Capture Action"
                    subtitle: "Executable for capture action"
                }
                TextField {
                    id: captureActionField
                    placeholderText: "Select python script or executable"
                    Layout.minimumWidth: 200

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            fileDialog.visible = true
                        }

                        FileDialog {
                            id: fileDialog
                            title: "Please choose a file"
                            folder: shortcuts.home
                            onAccepted: {
                                captureActionField.text = String(fileUrl)
                            }

                            onRejected: {
//                                console.log("Canceled")
                                visible = false
                            }
                            Component.onCompleted: visible = false
                        }

                    }

                }

            }

            RowLayout {
                spacing: 10
                CustomLabel {
                    text: "Live View Action"
                    subtitle: "Script to start live view"
                }
                TextField {
                    id: liveViewField
                    placeholderText: "Select python script or executable"
                    Layout.minimumWidth: 200

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            lvFileDialog.visible = true
                        }

                        FileDialog {
                            id: lvFileDialog
                            title: "Please choose a file"
                            folder: shortcuts.home
                            onAccepted: {
                                liveViewField.text = String(fileUrl)
                            }

                            onRejected: {
//                                console.log("Canceled")
                                visible = false
                            }
                            Component.onCompleted: visible = false
                        }

                    }

                }

            }
        }
    }
}
