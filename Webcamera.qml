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
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import Qt.labs.folderlistmodel 2.0
import QtWebView 1.1
import Process 1.0
import SonyAPI 1.0
import SonyLiveview 1.0
import ProcessPhotos 1.0
import PrintPhotos 1.0
import CSVFile 1.0
import Firebase 1.0

Rectangle {
    color: "transparent"
    Camera {
        id: camera
        captureMode: Camera.CaptureStillImage
        deviceId: mainSettings.cameraDeviceId
    }

    VideoOutput {
        anchors.fill: parent
        source: camera
    }
}

