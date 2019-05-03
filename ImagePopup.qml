import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3

Popup {
    id: root
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    modal: true
    background: Rectangle {
        color: Material.background
        radius: pixel(2)
        Material.elevation: 4
    }

    property alias source: imageView.source
    property real iconSize: pixel(7)
    property real buttonWidth: pixel(20)
    property real buttonHeight: pixel(10)

    Rectangle {
        id: buttonHolder
        width: buttonWidth * 3 + pixel(10)
        height: buttonHeight + pixel(10)
        radius: pixel(2)
        anchors.top: parent.bottom
        anchors.right: parent.right
        color: Material.background

        RowLayout {
            spacing: pixel(1)
            anchors.fill: parent

            Button {
                id: printButton
                text: qsTr("Print")
                icon.source: "qrc:/Images/print_white_48dp.png"
                icon.width: iconSize
                icon.height: iconSize
                display: AbstractButton.IconOnly
                Layout.alignment: Qt.AlignHCenter
                width: buttonWidth
                height: buttonHeight
                onClicked: {
                    printCopyCountButton.value = 1
                    printPopup.open()
                }
            }
            Button {
                text: qsTr("Email")
                icon.source: "qrc:/Images/email_white_48dp.png"
                icon.width: iconSize
                icon.height: iconSize
                display: AbstractButton.IconOnly
                Layout.alignment: Qt.AlignHCenter
                width: buttonWidth
                height: buttonHeight
                onClicked: {
                    console.log("Email!")
                }
            }

            Button {
                text: qsTr("SMS")
                icon.source: "qrc:/Images/sms_white_48dp.png"
                icon.width: iconSize
                icon.height: iconSize
                display: AbstractButton.IconOnly
                Layout.alignment: Qt.AlignHCenter
                width: buttonWidth
                height: buttonHeight
                onClicked: {
                    console.log("SMS!")
                }
            }
        }
    }


    Image {
        id: imageView
        asynchronous: true
        anchors.fill: parent
        anchors.margins: pixel(1)
        fillMode: Image.PreserveAspectFit
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: imageView.status == Image.Loading
    }

    Popup {
        id: printPopup
        modal: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Material.background
            radius: pixel(3)
            Material.elevation: 4
        }

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.fill: parent

            ColumnLayout {}



            UpDownButton {
                id: printCopyCountButton
                min: 1
                value: 1
                max: settingGeneral.printCopiesPerSession
                height: pixel(20)
                width: height * 3
                Layout.alignment: Qt.AlignCenter
            }

            Button {
                text: qsTr("Print")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    console.log(printCopyCountButton.value)
                    console.log(root.source)


//                    imagePrint.printPhotos(imageView.source, printCopyCountButton.value)
                }
            }

            ColumnLayout {}


        }

    }
}
