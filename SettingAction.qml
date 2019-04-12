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
//    property alias captureAction: captureActionField.text
//    property alias liveviewAction: liveViewField.text
    property alias pythonPath: pythonField.text

    Settings {
        category: "Action"
//        property alias captureAction: captureActionField.text
//        property alias liveviewAction: liveViewField.text
        property alias pythonPath: pythonField.text
    }

    function stripFilePrefix(a) {
        if (a.search('C:') >= 0) {
            return a.replace("file:///", "")
        }
        return a.replace("file://", "")
    }

    CustomPane {
        id: cameraActions
        Layout.preferredWidth: root.width * 0.9
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        title: "Camera Action"


        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                spacing: 20

                CustomLabel {
                    text: "Python Executable"
                    subtitle: "Path to python exe"
                }
                TextField {
                    id: pythonField
                    Layout.fillWidth: true
                    placeholderText: "Select path to python"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pythonFileDialog.visible = true
                        }

                        FileDialog {
                            id: pythonFileDialog
                            title: "Please choose a file"
                            folder: shortcuts.home
                            onAccepted: {
                                pythonField.text = root.stripFilePrefix(String(fileUrl))
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

//            RowLayout {
//                spacing: 20

//                CustomLabel {
//                    text: "Capture Action"
//                    subtitle: "Executable for capture action"
//                }
//                TextField {
//                    id: captureActionField
//                    Layout.fillWidth: true
//                    placeholderText: "Select python script or executable"

//                    MouseArea {
//                        anchors.fill: parent
//                        onClicked: {
//                            fileDialog.visible = true
//                        }

//                        FileDialog {
//                            id: fileDialog
//                            title: "Please choose a file"
//                            folder: shortcuts.home
//                            onAccepted: {
//                                captureActionField.text = root.stripFilePrefix(String(fileUrl))
//                            }

//                            onRejected: {
////                                console.log("Canceled")
//                                visible = false
//                            }
//                            Component.onCompleted: visible = false
//                        }

//                    }

//                }

//            }

//            RowLayout {
//                spacing: 20

//                CustomLabel {
//                    text: "Live View Action"
//                    subtitle: "Script to start live view"
//                }
//                TextField {
//                    id: liveViewField
//                    Layout.fillWidth: true
//                    placeholderText: "Select python script or executable"

//                    MouseArea {
//                        anchors.fill: parent
//                        onClicked: {
//                            lvFileDialog.visible = true
//                        }

//                        FileDialog {
//                            id: lvFileDialog
//                            title: "Please choose a file"
//                            folder: shortcuts.home
//                            onAccepted: {
//                                liveViewField.text = root.stripFilePrefix(String(fileUrl))
//                            }

//                            onRejected: {
////                                console.log("Canceled")
//                                visible = false
//                            }
//                            Component.onCompleted: visible = false
//                        }

//                    }

//                }

//            }
        }
    }
}









































/*##^## Designer {
    D{i:0;height:1920;width:1080}
}
 ##^##*/
