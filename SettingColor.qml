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
    signal bgColorSelected(string color)
    signal countDownColorSelected(string color)
    Settings {
        category: "Color"
        property alias backgroundColor: bgColorRectangle.color
        property alias countDownColor: countDownColorRectangle.color
    }
    CustomPane {
        id: customPane
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        title: "Color"

        ColumnLayout {
            id: columnLayout3
            anchors.fill: parent


            RowLayout {
                id: rowLayout5
                width: 100
                height: 100

                Label {
                    id: element5
                    height: 48
                    text: qsTr("Countdown Color")
                    Layout.minimumWidth: 200
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }

                Rectangle {
                    id: countDownColorRectangle
                    width: 48
                    height: 48
                    color: "#ffffff"
                    radius: 8
                    border.color: "#555555"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            countDownColorDialog.color = countDownColorRectangle.color
                            countDownColorDialog.open()

                        }

                    }


                }

                ColorDialog {
                    id: countDownColorDialog
                    title: "Please choose a countdown color"

                    onAccepted: {
                        countDownColorRectangle.color = color
                        countDownColorSelected(color)
                    }
                }

                Label {
                    id: countDownColorHex
                    height: 48
                    text: countDownColorRectangle.color
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }

            }
            RowLayout {
                id: rowLayout4
                width: 100
                height: 100

                Label {
                    id: element4
                    height: 48
                    text: qsTr("Background Color")
                    Layout.minimumWidth: 200
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }

                Rectangle {
                    id: bgColorRectangle
                    width: 48
                    height: 48
                    color: "#000000"
                    radius: 8
                    border.color: "#999"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            bgColorDialog.color = bgColorRectangle.color
                            bgColorDialog.open()
                        }

                    }
                }

                ColorDialog {
                    id: bgColorDialog
                    title: "Please choose a background color"

                    onAccepted: {
                        bgColorRectangle.color = color
                        bgColorSelected(color)
                    }
                }

                Label {
                    id: bgColorHex
                    height: 48
                    text: bgColorRectangle.color
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 24
                }
            }
        }
    }






}

/*##^## Designer {
    D{i:2;anchors_height:100;anchors_width:100;anchors_x:0;anchors_y:30}
}
 ##^##*/
