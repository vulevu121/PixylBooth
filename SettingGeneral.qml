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
import PrintPhotos 1.0
import QtGraphicalEffects 1.12

Item {
    id: root

    property alias bgColor: bgColorRectangle.color
    property alias countDownColor: countDownColorRectangle.color

    property alias captureTimer: captureTimerButton.value
    property alias beforeCaptureTimer: beforeCaptureTimerButton.value
    property alias reviewTimer: reviewTimerButton.value
    property alias saveFolder: saveFolderField.text
    property alias endSessionTimer: endSessionTimerButton.value
    property alias liveVideoStartSwitch: liveVideoStartSwitch.checked
    property alias liveVideoCountdownSwitch: liveVideoCountdownSwitch.checked
    property alias printerName: printerNameField.text
    property alias maxCopyCount: maxCopyCountButton.value

    property alias startVideoListModel: startVideoListModel
    property alias beforeCaptureVideoListModel: beforeCaptureVideoListModel
    property alias afterCaptureVideoListModel: afterCaptureVideoListModel

    property string lastFolder: "file:///"
    property string startVideosListModelString: ""
    property string beforeCaptureVideosListModelString: ""
    property string afterCaptureVideosListModelString: ""

    property real rowHeight: pixel(6)
    property real textSize: pixel(4)
    property real spacing: pixel(3)
    property real columnMargins: pixel(3)


    Settings {
        category: "General"
        property alias captureTimer: captureTimerButton.value
        property alias beforeCaptureTimer: beforeCaptureTimerButton.value
        property alias reviewTimer: reviewTimerButton.value
        property alias saveFolder: saveFolderField.text
        property alias endSessionTimer: endSessionTimerButton.value
    }

    Settings {
        category: "Camera"
        property alias liveVideoStartSwitch: liveVideoStartSwitch.checked
        property alias liveVideoCountdownSwitch: liveVideoCountdownSwitch.checked
    }


    Settings {
        category: "Color"
        property alias backgroundColor: bgColorRectangle.color
        property alias countDownColor: countDownColorRectangle.color

    }

    Settings {
        category: "Printer"
        property alias printerName: printerNameField.text
        property alias maxCopyCount: maxCopyCountButton.value
    }

    Settings {
        category: "Videos"
        property alias startVideos: root.startVideosListModelString
        property alias beforeCaptureVideos: root.beforeCaptureVideosListModelString
        property alias afterCaptureVideos: root.afterCaptureVideosListModelString
        property alias lastFolder: root.lastFolder
    }


    PrintPhotos {
        id: imagePrint
    }

    function setLastFolder(folder) {
        lastFolder = folder
    }


    function addStartVideo(path) {
        var pathSplit = ""
        pathSplit = path.split("/")
        var fileName = pathSplit[pathSplit.length - 1]

        startVideoListModel.append({ "fileName": fileName, "filePath": path })
        createStartVideosListModelString()

    }

    function addBeforeCaptureVideo(path) {
        var pathSplit = ""
        pathSplit = path.split("/")
        var fileName = pathSplit[pathSplit.length - 1]

        beforeCaptureVideoListModel.append({ "fileName": fileName, "filePath": path })
    }

    function addAfterCaptureVideo(path) {
        var pathSplit = ""
        pathSplit = path.split("/")
        var fileName = pathSplit[pathSplit.length - 1]

        afterCaptureVideoListModel.append({ "fileName": fileName, "filePath": path })
    }



    ListModel {
        id: settingModel
        ListElement {
            name: "General"
            icon: "qrc:/Images/settings_white_48dp.png"
        }
        ListElement {
            name: "Camera"
            icon: "qrc:/Images/camera_alt_white_48dp.png"
        }
        ListElement {
            name: "Color"
            icon: "qrc:/Images/color_lens_white_48dp.png"
        }
        ListElement {
            name: "Printer"
            icon: "qrc:/Images/print_white_48dp.png"
        }
        ListElement {
            name: "Video"
            icon: "qrc:/Images/video_library_white_48dp.png"
        }
    }

    Component {
        id: settingDelegate
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: iconImage.height + pixel(4)

            Row {
                anchors.margins: pixel(2)
                anchors.fill: parent
                spacing: pixel(1)
                Image {
                    id: iconImage
                    width: pixel(8)
                    height: pixel(8)
                    source: icon
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: name
                    color: Material.foreground
                }

            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex = index
                    if(index == 0 && stackView.currentItem != generalView) {
                        stackView.replace(generalView)
                    }
                    else if(index == 1 && stackView.currentItem != cameraView) {
                        stackView.replace(cameraView)
                    }
                    else if(index == 2 && stackView.currentItem != colorView) {
                        stackView.replace(colorView)
                    }
                    else if(index == 3 && stackView.currentItem != printerView) {
                        stackView.replace(printerView)
                    }
                    else if(index == 4 && stackView.currentItem != videoView) {
                        stackView.replace(videoView)
                    }
                }
            }

        }
    }



    ColumnLayout {
        anchors.fill: parent
        anchors.margins: pixel(15)

        Rectangle {
            id: outerRect
            Layout.alignment: Qt.AlignCenter
            width: parent.width
            height: parent.height
            color: "#222"
            radius: pixel(3)

            Image {
                id: topLeftCorner
                width: pixel(3)
                height: pixel(3)
                anchors.left: parent.left
                anchors.top: parent.top
                source: "qrc:/Images/corner.png"
                visible: false
            }

            Image {
                id: bottomLeftCorner
                width: pixel(3)
                height: pixel(3)
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                source: "qrc:/Images/corner.png"
                rotation: 270
                visible: false
            }


            ColorOverlay {
                anchors.fill: topLeftCorner
                source: topLeftCorner
                color: bgColorRectangle.color
                z: 5
            }

            ColorOverlay {
                anchors.fill: bottomLeftCorner
                source: bottomLeftCorner
                color: bgColorRectangle.color
                rotation: 270
                z: 5
            }

            Rectangle {
                id: leftSide
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: pixel(40)
                color: "#333"

                ListView {
                    id: listView
                    boundsBehavior: Flickable.StopAtBounds
                    model: settingModel
                    anchors.fill: parent
                    delegate: settingDelegate
                    highlight: Rectangle {
                        color: "#222"
                    }

                }
            }

            StackView {
                id: stackView
                anchors.left: leftSide.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                initialItem: generalView

                pushEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to:1
                        duration: 200
                    }
                }
                pushExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to:0
                        duration: 200
                    }
                }
                popEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to:1
                        duration: 200
                    }
                }
                popExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to:0
                        duration: 200
                    }
                }

                replaceEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to:1
                        duration: 200
                    }
                }
                replaceExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to:0
                        duration: 200
                    }
                }




            }

            Item {
                id: generalView
                visible: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.columnMargins
                    spacing: root.spacing

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Before Capture Video Timer")
                        subtitle: qsTr("Seconds to display video before capture ")
                    }

                    UpDownButton {
                        id: beforeCaptureTimerButton
                        height: pixel(10)
                        width: height * 3
                    }

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Capture Countdown")
                        subtitle: qsTr("Seconds before picture taken")
                    }

                    UpDownButton {
                        id: captureTimerButton
                        height: pixel(10)
                        width: height * 3
                    }


                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Review Time")
                        subtitle: qsTr("Seconds to display photo after capture")
                    }

                    UpDownButton {
                        id: reviewTimerButton
                        height: pixel(10)
                        width: height * 3
                    }


                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("End Session Timer")
                        subtitle: qsTr("Seconds to show the end of session")
                    }

                    UpDownButton {
                        id: endSessionTimerButton
                        height: pixel(10)
                        width: height * 3
                    }

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Save Folder")
                        subtitle: "Location to save photos"
                    }

                    TextField {
                        id: saveFolderField
                        font.pixelSize: root.textSize
                        Layout.fillWidth: true
                        placeholderText: "Choose a save folder..."

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                folderDialog.open()
                            }
                        }

                        FolderDialog {
                            id: folderDialog
                            title: "Please select save directory"
                            onAccepted: {
                                saveFolderField.text = root.stripFilePrefix(String(folder))
                            }
                        }
                    }

                    RowLayout {
                    }
                }
            }


            Item {
                id: cameraView
                visible: false

                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.spacing
                    anchors.margins: root.columnMargins

                    CustomLabel {
                        text: "Live Video on Start"
                        subtitle: "Shows live video on start screen"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }
                    Switch {
                        id: liveVideoStartSwitch
                    }

                    CustomLabel {
                        text: "Live Video on Countdown"
                        subtitle: "Shows live video during countdown"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }
                    Switch {
                        id: liveVideoCountdownSwitch
                    }

                    CustomLabel {
                        text: "Auto Camera Trigger"
                        subtitle: "Trigger camera shutter automatically"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }
                    Switch {
                        id: autoTriggerSwitch
                    }

                    CustomLabel {
                        text: "Mirror Live Video"
                        subtitle: "Flips live video horizontally"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: mirrorLiveVideoSwitch
                    }

                    RowLayout {}

                }

            }

            Item {
                id: colorView
                visible: false

                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.spacing
                    anchors.margins: root.columnMargins

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Countdown Color")
                        subtitle: qsTr("Color of the countdown text")
                    }

                    RowLayout {
                        Rectangle {
                            id: countDownColorRectangle
                            width: root.rowHeight
                            height: root.rowHeight
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

                        TextEdit {
                            id: countDownColorHex
                            height: root.rowHeight
                            text: countDownColorRectangle.color
                            verticalAlignment: Text.AlignVCenter
                            font.capitalization: Font.AllUppercase
                            color: Material.foreground
                        }

                    }

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Background Color")
                        subtitle: qsTr("Color of the background")
                    }

                    RowLayout {
                        Rectangle {
                            id: bgColorRectangle
                            width: root.rowHeight
                            height: root.rowHeight
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
                            }
                        }

                        TextEdit {
                            id: bgColorHex
                            height: root.rowHeight
                            text: bgColorRectangle.color
                            verticalAlignment: Text.AlignVCenter
                            font.capitalization: Font.AllUppercase
                            color: Material.foreground
                        }


                    }



                    RowLayout {}
                }

            }

            Item {
                id: printerView
                visible: false

                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.spacing
                    anchors.margins: root.columnMargins

                    // ==== Printer Name ====
                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: "Printer Name"
                        subtitle: "The printer selected for printing photos"
                    }
                    TextField {
                        id: printerNameField
                        Layout.fillWidth: true
                        placeholderText: "Click here to set printer"
                        height: root.rowHeight

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                printerNameField.text = String(imagePrint.getPrinterName())

                            }
                        }
                    }

                    // === Automatic Printing ====
                    CustomLabel {
                        text: "Automatic Printing"
                        subtitle: "Print automatically after each session"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: autoPrinting
                    }

                    CustomLabel {
                        text: "Automatic Print Copies"
                        subtitle: "Number of copies for automatic printing"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }

                    UpDownButton {
                        id: autoPrintCopies
                        height: pixel(10)
                        width: height * 3
                    }

                    // === Print Limit ====
                    CustomLabel {
                        text: "Print Limit"
                        subtitle: "Number of copies allowed per session"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }

                    UpDownButton {
                        id: maxCopyCountButton
                        height: pixel(10)
                        width: height * 3
                    }



                    RowLayout {}

                }
            }

            Item {
                id: videoView
                visible: false

                Component.onCompleted: {
                    var i
                    if (startVideosListModelString) {
                      startVideoListModel.clear()
                      var datamodel = JSON.parse(startVideosListModelString)
                      for (i = 0; i < datamodel.length; ++i) startVideoListModel.append(datamodel[i])
                    }

                    if (beforeCaptureVideosListModelString) {
                      beforeCaptureVideoListModel.clear()
                      var datamodel2 = JSON.parse(beforeCaptureVideosListModelString)
                      for (i = 0; i < datamodel2.length; ++i) beforeCaptureVideoListModel.append(datamodel2[i])
                    }

                    if (afterCaptureVideosListModelString) {
                      afterCaptureVideoListModel.clear()
                      var datamodel3 = JSON.parse(afterCaptureVideosListModelString)
                      for (i = 0; i < datamodel3.length; ++i) afterCaptureVideoListModel.append(datamodel3[i])
                    }

                }

                Component.onDestruction: {
                    var datamodel = []
                    var i
                    for (i = 0; i < startVideoListModel.count; ++i) datamodel.push(startVideoListModel.get(i))
                    startVideosListModelString = JSON.stringify(datamodel)

                    var datamodel2 = []
                    for (i = 0; i < beforeCaptureVideoListModel.count; ++i) datamodel2.push(beforeCaptureVideoListModel.get(i))
                    beforeCaptureVideosListModelString = JSON.stringify(datamodel2)

                    var datamodel3 = []
                    for (i = 0; i < afterCaptureVideoListModel.count; ++i) datamodel3.push(afterCaptureVideoListModel.get(i))
                    afterCaptureVideosListModelString = JSON.stringify(datamodel3)
                }

                ListModel {
                    id: startVideoListModel
                }

                ListModel {
                    id: beforeCaptureVideoListModel
                }

                ListModel {
                    id: afterCaptureVideoListModel
                }

                Popup {
                    id: filePopup
                    anchors.centerIn: parent
                    width: root.width
                    height: root.height * 0.5
                    modal: true
                    focus: true
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnReleaseOutside
                    z: 10

                    FileBrowser {
                        id: startVideoBrowser
                        folder: lastFolder
                        anchors.fill: parent
                        Component.onCompleted: {
                            fileSelected.connect(filePopup.close)
                            browserClosed.connect(filePopup.close)
                            fileSelected.connect(addStartVideo)
                        }
                    }

                    FileBrowser {
                        id: beforeCaptureVideoBrowser
                        folder: lastFolder
                        anchors.fill: parent
                        Component.onCompleted: {
                            fileSelected.connect(filePopup.close)
                            browserClosed.connect(filePopup.close)
                            fileSelected.connect(addBeforeCaptureVideo)
                        }
                    }

                    FileBrowser {
                        id: afterCaptureVideoBrowser
                        folder: lastFolder
                        anchors.fill: parent
                        Component.onCompleted: {
                            fileSelected.connect(filePopup.close)
                            browserClosed.connect(filePopup.close)
                            fileSelected.connect(addAfterCaptureVideo)
                        }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.spacing
                    anchors.margins: root.columnMargins

                    VideoList {
                        id: startVideoList
                        Layout.fillWidth: true
                        title: "Start Videos"
                        model: startVideoListModel

                        addButton.onClicked: {
                            startVideoBrowser.show()
                            filePopup.open()
                        }
                        clearButton.onClicked: {
                            startVideoListModel.clear()
                        }

                    }

                    VideoList {
                        id: beforeCaptureVideoList
                        Layout.fillWidth: true
                        title: "Before Capture Videos"
                        model: beforeCaptureVideoListModel

                        addButton.onClicked: {
                            beforeCaptureVideoBrowser.show()
                            filePopup.open()
                        }
                        clearButton.onClicked: {
                            beforeCaptureVideoListModel.clear()
                        }
                    }

                    VideoList {
                        id: afterCaptureVideoCaptureList
                        Layout.fillWidth: true
                        title: "After Capture Videos"
                        model: afterCaptureVideoListModel

                        addButton.onClicked: {
                            afterCaptureVideoBrowser.show()
                            filePopup.open()
                        }
                        clearButton.onClicked: {
                            afterCaptureVideoListModel.clear()
                        }

                    }
                    RowLayout {  }
                }

            }

        }

    }

}





































/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:3;anchors_x:0;anchors_y:30}
}
 ##^##*/
