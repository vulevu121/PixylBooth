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

ColumnLayout {
    id: debugLayout
    z: 5
    opacity: 0.5
    visible: false
    enabled: visible

    Button {
        text: "startRecMode"
        onClicked: {
            sonyAPI.startRecMode()
        }
    }

    Button {
        text: "startLiveview"
        onClicked: {
            sonyAPI.startLiveview()
        }
    }

    Button {
        text: "actTakePicture"
        onClicked: {
            sonyAPI.actTakePicture()
        }
    }

    Button {
        text: "actHalfPressShutter"
        onClicked: {
            sonyAPI.actHalfPressShutter()
        }
    }

    Button {
        text: "cancelHalfPressShutter"
        onClicked: {
            sonyAPI.cancelHalfPressShutter()
        }
    }

    Button {
        text: "start"
        onClicked: {
            sonyAPI.start()
        }
    }

    Button {
        text: "Auth"
        onClicked: {
            firebase.authenticate("vulevu121@gmail.com", "123456")
        }
    }

    Button {
        text: "getAccountInfo"
        onClicked: {
            firebase.getAccountInfo()
        }
    }

    Button {
        text: "getUserData"
        onClicked: {
            firebase.getUserData()
        }
    }
}
