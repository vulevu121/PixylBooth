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
import QtMultimedia 5.4
import Process 1.0
import SonyAPI 1.0
import SonyLiveview 1.0
import PrintPhotos 1.0

ColumnLayout {
    id: root

    property alias printerName: printerNameField.text
    property alias maxCopyCount: maxCopyCountSlider.value

    Settings {
        category: "Printer"
        property alias printerName: printerNameField.text
        property alias maxCopyCount: maxCopyCountSlider.value
    }

    PrintPhotos {
        id: imagePrint
    }

    CustomPane {
        Layout.preferredWidth: root.width * 0.9
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        title: "Printer"

        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                spacing: 20
                CustomLabel {
                    text: "Printer Name"
                    subtitle: "The printer of your choice"
                    font.pixelSize: 24
                    height: 48
                }
                TextField {
                    id: printerNameField
                    Layout.fillWidth: true
                    placeholderText: "Click here to set printer"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            printerNameField.text = String(imagePrint.getPrinterName())

                        }
                    }
                }
            }

            RowLayout {
                spacing: 20
                CustomLabel {
                    text: "Max Print Copies"
                    subtitle: "Print limit per session"
                    font.pixelSize: 24
                    height: 48
                }
                Slider {
                    id: maxCopyCountSlider
                    height: 48
                    Layout.fillWidth: true
                    stepSize: 1
                    to: 20
                    value: 5
                }

                Label {
                    height: 48
                    text: maxCopyCountSlider.value
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }


            }
        }
    }
}
