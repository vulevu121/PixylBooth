import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
//import QtQml.Models 2.12

Popup {
    id: root
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    modal: true
//    background: Rectangle {
//        color: Material.background
//        radius: pixel(2)
//        Material.elevation: 4
//    }

    Overlay.modal: Rectangle {
            color: "#A0101010"
    }

    property alias source: imageView.source
    property real iconSize: pixel(8)
    property real buttonWidth: pixel(20)
    property real buttonHeight: pixel(10)

    Image {
        id: imageView
        asynchronous: true
        anchors.fill: parent
        anchors.margins: pixel(1)
        fillMode: Image.PreserveAspectFit
    }

    Row {
        height: iconSize
        anchors.top: imageView.bottom
        spacing: pixel(3)

        Button {
            id: printButton
            text: qsTr("Print")
            icon.source: "qrc:/Images/print_white_48dp.png"
            icon.width: iconSize
            icon.height: iconSize
            display: AbstractButton.IconOnly
            Layout.alignment: Qt.AlignHCenter
//            width: buttonWidth
//            height: buttonHeight
            Material.accent: Material.color(Material.Cyan, Material.Shade700)
            highlighted: true
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
//            width: buttonWidth
//            height: buttonHeight
            Material.accent: Material.color(Material.Orange, Material.Shade700)
            highlighted: true
            onClicked: {
                console.log("Email!")
                emailPopup.open()
                emailTextField.forceActiveFocus()
            }
        }

//            Button {
//                text: qsTr("SMS")
//                icon.source: "qrc:/Images/sms_white_48dp.png"
//                icon.width: iconSize
//                icon.height: iconSize
//                display: AbstractButton.IconOnly
//                Layout.alignment: Qt.AlignHCenter
//                width: buttonWidth
//                height: buttonHeight
//                onClicked: {
//                    console.log("SMS!")
//                }
//            }
    }




    BusyIndicator {
        anchors.centerIn: parent
        running: imageView.status == Image.Loading
    }

    Popup {
        id: emailPopup
        modal: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Overlay.modal: Rectangle {
                color: "#A0101010"
        }

//        background: Rectangle {
//            color: Material.background
//            radius: pixel(3)
//            Material.elevation: 4
//        }


        Column {
            anchors.fill: parent

            Row {
                spacing: pixel(5)

                TextField {
                    id: emailTextField
                    width: root.width * 0.8
                    placeholderText: "Enter your email..."
                    focus: true
//                    font.capitalization: Font.Normal


                    Keys.onReturnPressed: {
                        emailSendButton.clicked()
                    }

                    onTextChanged: {
                        autoCompleteListModel.clear()

                        if (emailTextField.text.length > 2) {

                            for (var i = 0 ; i < emailList.count ; i++) {
                                var email = String(emailList.get(i).email)
                                var input = String(emailTextField.text)

                                if (email.toLowerCase().search(input.toLowerCase()) >= 0) {
                                    autoCompleteListModel.append({"email" : email});
                                }
                            }
                        }


                    }
                }


                Button {
                    id: emailSendButton
                    text: "Send"
                    Material.accent: Material.color(Material.Orange, Material.Shade700)
                    highlighted: true
                    onClicked: {
                        if (emailTextField.text.length > 0) {
                            emailList.append({"filePath": String(getFileName(imageView.source)), "email": emailTextField.text})

                            var filePath = stripFilePrefix(String(imageView.source))
                            var email = emailTextField.text
                            var string = filePath.concat(",").concat(email)

                            csvFile.exportCSV(string)
                            emailTextField.clear()

                            emailPopup.close()
                        }


                    }
                }
            }


            Rectangle {
                id: autoCompleteContainer
                width: parent.width
                height: pixel(6) * 4
                color: Material.background
                clip: true

                ListModel {
                    id: autoCompleteListModel
                }


//                DelegateModel {
//                    id: autoCompleteDelegateModel
//                    model: emailList


//                    groups: [
//                        DelegateModelGroup {
//                            name: "filtered"
//                            includeByDefault: false
//                        }
//                    ]

//                    filterOnGroup: "filtered"

//                    delegate: Item {
//                        height: pixel(6)
//                        Text {
//                            text: email
//                            color: Material.foreground
//                            font.pixelSize: pixel(5)
//                        }
//                    }
//                }


                ListView {
                    anchors.fill: parent
                    anchors.margins: pixel(3)
                    id: autoCompleteListView
                    model: autoCompleteListModel

                    delegate: Item {
                        height: pixel(6)
                        Text {
                            text: email
                            color: Material.foreground
                            font.pixelSize: pixel(5)

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    emailTextField.text = parent.text
                                }
                            }
                        }
                    }
                }

            }

            InputPanel {
                width: root.width

            }

        }


    }


    Popup {
        id: printPopup
        modal: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Overlay.modal: Rectangle {
                color: "#A0101010"
        }

//        background: Rectangle {
//            color: Material.background
//            radius: pixel(3)
//            Material.elevation: 4
//        }

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
                Material.accent: Material.color(Material.Cyan, Material.Shade700)
                highlighted: true
                onClicked: {
//                    console.log(printCopyCountButton.value)
//                    console.log(root.source)

                    imagePrint.printPhoto(stripFilePrefix(imageView.source), printCopyCountButton.value)
                    printPopup.close()
                }
            }

            ColumnLayout {}


        }

    }
}
