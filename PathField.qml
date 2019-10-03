import QtQuick 2.12
//import QtQuick.Window 2.2
//import QtQuick.VirtualKeyboard 2.2
//import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
//import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
//import Qt.labs.settings 1.1
//import PrintPhotos 1.0
//import QtGraphicalEffects 1.12
//import QtMultimedia 5.8

TextField {
    id: textField
    font.pixelSize: root.textSize
    placeholderText: ""

    property bool isFile: true
    property alias nameFilters: fileDialog.nameFilters
    property string title: ""

    signal dialogOk

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (isFile) {
                fileDialog.open()
            } else {
                folderDialog.open()
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: textField.title
        folder: addFilePrefix(textField.text)
        nameFilters: [""]
        onAccepted: {
            textField.text = stripFilePrefix(String(fileUrl))
            dialogOk()
        }
    }

    FolderDialog {
        id: folderDialog
        title: textField.title
        folder: addFilePrefix(textField.text)

        onAccepted: {
            textField.text = stripFilePrefix(String(folder))
            dialogOk()
        }
    }

}
