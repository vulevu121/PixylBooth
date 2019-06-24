import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.1
import QtMultimedia 5.5
import QtGraphicalEffects 1.0
import Qt.labs.folderlistmodel 2.0

VideoOutput {
    id: liveView
    visible: true
    width: parent.width
    height: width / photoAspectRatio
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top

    Rectangle {
        anchors.fill: parent

        border.color: "white"
        border.width: 1
        color: "transparent"
    }


    source: camera
//                autoOrientation: true

}
