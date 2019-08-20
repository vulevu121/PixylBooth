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
import QtMultimedia 5.8


Item {
    id: root
    property alias templateImagePath: templateImageField.text
//    property alias printFolder: printFolderField.text
    property alias saveFolder: saveFolderField.text
//    property alias emailFolder: emailFolderField.text
    property alias displayScale: displayScalingButton.value

    property alias bgColor: bgColorRectangle.color
    property alias countDownColor: countDownColorRectangle.color

    property alias countdownTimer: countdownTimerButton.value
    property alias beforeCaptureTimer: beforeCaptureTimerButton.value
    property alias afterCaptureTimer: afterCaptureTimerButton.value
    property alias reviewTimer: reviewTimerButton.value
    property alias endSessionTimer: endSessionTimerButton.value
    property alias showLiveVideoOnStartSwitch: showLiveVideoOnStartSwitch.checked
    property alias showLiveVideoOnCountdownSwitch: showLiveVideoOnCountdownSwitch.checked
    property alias mirrorLiveVideoSwitch: mirrorLiveVideoSwitch.checked

    property alias printerName: printerNameField.text
    property alias autoPrint: autoPrint.checked
    property alias autoPrintCopies: autoPrintCopies.value
    property alias printCopiesPerSession: printCopiesPerSessionButton.value

//    property string lastFolder: "file:///Users/Vu/Documents/PixylBooth/Videos"
    property alias startVideoPlaylist: startVideoPlaylist
    property alias beforeCaptureVideoPlaylist: beforeCapturePlaylist
    property alias afterCaptureVideoPlaylist: afterCaptureVideoPlaylist

    property real rowHeight: pixel(6)
    property real textSize: pixel(4)
    property real spacing: pixel(3)
    property real columnMargins: pixel(3)

    property real numberPhotos
    property string templateFormat
    property real buttonHeight: pixel(12)

    property alias emojiFolder: emojiFolderField.text
//    property alias canvasSaveFolder: canvasSaveFolderField.text

    function loadPlaylist(playlist, playlistString) {
        playlist.clear()
        var datamodel = JSON.parse(playlistString)
        for (var i = 0 ; i < datamodel.length ; i++) playlist.addItem(datamodel[i])
    }

    function getPlaylistString(playlist) {
        var datamodel = []
        for (var i = 0 ; i < playlist.itemCount ; i++) datamodel.push(playlist.itemSource(i))
        return JSON.stringify(datamodel)
    }


    Settings {
        category: "General"
        id: generalSettings
        property alias countdownTimer: countdownTimerButton.value
        property alias beforeCaptureTimer: beforeCaptureTimerButton.value
        property alias afterCaptureTimer: afterCaptureTimerButton.value
        property alias reviewTimer: reviewTimerButton.value
        property alias endSessionTimer: endSessionTimerButton.value
        property alias displayScale: displayScalingButton.value

    }

    Settings {
        category: "Profile"
        id: profileSettings
        property alias saveFolder: saveFolderField.text
        property alias templateImagePath: templateImageField.text
//        property alias printFolder: printFolderField.text
//        property alias emailFolder: emailFolderField.text
        property alias templateFormat: root.templateFormat
        property alias numberPhotos: root.numberPhotos
        property alias emojiFolder: emojiFolderField.text
    }


    Settings {
        category: "Camera"
        id: cameraSettings
        property alias showLiveVideoOnStart: showLiveVideoOnStartSwitch.checked
        property alias showLiveVideoOnCountdown: showLiveVideoOnCountdownSwitch.checked
        property alias mirrorLiveVideo: mirrorLiveVideoSwitch.checked
//        property string cameraDeviceId
//        property alias cameraDeviceIdIndex: cameraDeviceIdCombo.currentIndex
//        property alias cameraDisplayName: cameraDeviceIdCombo.currentText
    }


    Settings {
        category: "Color"
        id: colorSettings
        property alias backgroundColor: bgColorRectangle.color
        property alias countDownColor: countDownColorRectangle.color

    }

    Settings {
        category: "Printer"
        id: printerSettings
        property alias printerName: printerNameField.text
        property alias autoPrint: autoPrint.checked
        property alias autoPrintCopies: autoPrintCopies.value
        property alias printCopiesPerSession: printCopiesPerSessionButton.value
    }

    Settings {
        category: "Videos"
        id: videoSettings
        property string lastFolder
        property string startVideos
        property string beforeCaptureVideos
        property string afterCaptureVideos
        property string printingVideos
        property string signingVideos
    }

//    Settings {
//        category: "Canvas"
//        id: canvasSettings
//        property alias emojiFolder: emojiFolderField.text
////        property alias canvasSaveFolder: canvasSaveFolderField.text
//    }


    PrintPhotos {
        id: imagePrint
    }


    ListModel {
        id: settingModel
        ListElement {
            name: "General"
            icon: "qrc:/icon/settings"
            view: "generalView"
        }
        ListElement {
            name: "Profile"
            icon: "qrc:/icon/profile"
            view: "profileView"
        }
        ListElement {
            name: "Camera"
            icon: "qrc:/icon/camera"
            view: "cameraView"
        }
        ListElement {
            name: "Color"
            icon: "qrc:/icon/color"
            view: "colorView"
        }
        ListElement {
            name: "Printer"
            icon: "qrc:/icon/print"
            view: "printerView"
        }
        ListElement {
            name: "Video"
            icon: "qrc:/icon/video_library"
            view: "videoView"
        }
        ListElement {
            name: "Lighting"
            icon: "qrc:/icon/light"
            view: "lightingView"
        }
        ListElement {
            name: "Canvas"
            icon: "qrc:/icon/paint"
            view: "canvasView"
        }
    }

    Component {
        id: settingDelegate
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: pixel(12)
            clip: true

            Row {
                anchors.margins: pixel(5)
//                anchors.leftMargin: pixel(5)
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
                    var viewList = [generalView, profileView, cameraView, colorView, printerView, videoView, lightingView, canvasView]
                    stackView.replace(viewList[index])
                    listView.currentIndex = index
                }
            }

        }
    }



    Popup {
        id: filePopup
        anchors.centerIn: parent

        width: root.width * 0.9
        height: root.height * 0.7

        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnReleaseOutside
        z: 10

//        onOpened: {
//            fileBrowser.show()
//        }

//        Overlay.modal: GaussianBlur {
//            source: root
//            radius: 8
//            samples: 16
//            deviation: 3
//        }

        VideoBrowser {
            id: fileBrowser
            folder: videoSettings.lastFolder
            anchors.fill: parent

            Component.onCompleted: {
                browserClosed.connect(filePopup.close)
                fileSelected.connect(filePopup.close)
            }
        }

    }

    ColumnLayout {
        anchors.fill: parent
        anchors {
            leftMargin: pixel(5)
            rightMargin: pixel(5)
            topMargin: pixel(20)
            bottomMargin: pixel(5)
        }


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
                source: "qrc:/corner"
                visible: false
            }

            Image {
                id: bottomLeftCorner
                width: pixel(3)
                height: pixel(3)
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                source: "qrc:/corner"
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
                width: pixel(35)
                color: "#333"

                ListView {
                    id: listView
                    boundsBehavior: Flickable.StopAtBounds
                    model: settingModel
                    anchors.fill: parent
                    delegate: settingDelegate
                    highlightMoveDuration: 100               
                    highlight: Rectangle {
                        color: Material.color(Material.Cyan, Material.Shade800)
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
                        height: buttonHeight
                        width: height * 3
                    }

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("After Capture Video Timer")
                        subtitle: qsTr("Seconds to display video after capture ")
                    }

                    UpDownButton {
                        id: afterCaptureTimerButton
                        height: buttonHeight
                        width: height * 3
                    }

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Capture Countdown")
                        subtitle: qsTr("Seconds before picture taken")
                    }


                    UpDownButton {
                        id: countdownTimerButton
                        height: buttonHeight
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
                        height: buttonHeight
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
                        height: buttonHeight
                        width: height * 3
                    }



                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Display Scaling")
                        subtitle: qsTr("Scaling factor for display buttons and text")
                    }

                    UpDownButton {
                        id: displayScalingButton
                        height: buttonHeight
                        width: height * 3
                    }



                    RowLayout {}
                }
            }

            Item {
                id: profileView
                visible: false

                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.spacing
                    anchors.margins: root.columnMargins

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Template Image")
                        subtitle: "Location of template PNG image"
                    }

                    TextField {
                        id: templateImageField
                        font.pixelSize: root.textSize
                        Layout.fillWidth: true
                        placeholderText: "Choose a template..."

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                templateImageFileDialog.open()
                            }
                        }

                        FileDialog {
                            id: templateImageFileDialog
                            title: "Please select a template"
                            nameFilters: ["PNG Image Files (*.png)"]
                            onAccepted: {
                                templateImageField.text = stripFilePrefix(String(fileUrl))
                            }
                        }
                    }

                    Button {
                        text: "Edit Template"
                        onClicked: {
                            var component = Qt.createComponent("TemplateEditor.qml")
                            var window    = component.createObject(root)
                            window.show()
                        }
                    }

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Save Folder")
                        subtitle: "Location to save current session"
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
                                saveFolderField.text = stripFilePrefix(String(folder))
                            }
                        }
                    }



//                    CustomLabel {
//                        height: root.rowHeight
//                        Layout.fillWidth: true
//                        text: qsTr("Print Folder")
//                        subtitle: "Location to save prints"
//                    }

//                    TextField {
//                        id: printFolderField
//                        font.pixelSize: root.textSize
//                        Layout.fillWidth: true
//                        placeholderText: "Choose a print folder..."

//                        MouseArea {
//                            anchors.fill: parent
//                            onClicked: {
//                                printFolderDialog.open()
//                            }
//                        }

//                        FolderDialog {
//                            id: printFolderDialog
//                            title: "Please select print directory"
//                            onAccepted: {
//                                printFolderField.text = stripFilePrefix(String(folder))
//                            }
//                        }
//                    }

//                    CustomLabel {
//                        height: root.rowHeight
//                        Layout.fillWidth: true
//                        text: qsTr("Email Folder")
//                        subtitle: "Location to save email list"
//                    }

//                    TextField {
//                        id: emailFolderField
//                        font.pixelSize: root.textSize
//                        Layout.fillWidth: true
//                        placeholderText: "Choose a email folder..."

//                        MouseArea {
//                            anchors.fill: parent
//                            onClicked: {
//                                emailFolderDialog.open()
//                            }
//                        }

//                        FolderDialog {
//                            id: emailFolderDialog
//                            title: "Please select email directory"
//                            onAccepted: {
//                                emailFolderField.text = stripFilePrefix(String(folder))
//                            }
//                        }
//                    }



                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Emojis Folder")
                        subtitle: "Location of emojis"
                    }

                    TextField {
                        id: emojiFolderField
                        font.pixelSize: root.textSize
                        Layout.fillWidth: true
                        placeholderText: "Choose an emoji folder..."

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                emojiFolderFolderDialog.open()
                            }
                        }

                        FolderDialog {
                            id: emojiFolderFolderDialog
                            title: "Please select directory"
                            onAccepted: {
                                emojiFolderField.text = stripFilePrefix(String(folder))
                            }
                        }
                    }

//                    CustomLabel {
//                        height: root.rowHeight
//                        Layout.fillWidth: true
//                        text: qsTr("Canvas Save Folder")
//                        subtitle: "Location to save guest's canvas"
//                    }

//                    TextField {
//                        id: canvasSaveFolderField
//                        font.pixelSize: root.textSize
//                        Layout.fillWidth: true
//                        placeholderText: "Choose a save folder..."

//                        MouseArea {
//                            anchors.fill: parent
//                            onClicked: {
//                                canvasSaveDialog.open()
//                            }
//                        }

//                        FolderDialog {
//                            id: canvasSaveDialog
//                            title: "Please select directory"
//                            onAccepted: {
//                                canvasSaveFolderField.text = stripFilePrefix(String(folder))
//                            }
//                        }
//                    }

                    RowLayout {}

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
                        id: showLiveVideoOnStartSwitch
                    }

                    CustomLabel {
                        text: "Live Video on Countdown"
                        subtitle: "Shows live video during countdown"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }
                    Switch {
                        id: showLiveVideoOnCountdownSwitch
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
                                printerNameField.text = imagePrint.getPrinterName(printerNameField.text)

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
                        id: autoPrint
                    }

                    CustomLabel {
                        text: "Automatic Print Copies"
                        subtitle: "Number of copies for automatic printing"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }

                    UpDownButton {
                        id: autoPrintCopies
                        height: buttonHeight
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
                        id: printCopiesPerSessionButton
                        height: buttonHeight
                        width: height * 3
                    }



                    RowLayout {}

                }
            }

            Item {
                id: videoView
                visible: false

                Playlist {
                    id: startVideoPlaylist
                    playbackMode: Playlist.Random
                }

                Playlist {
                    id: beforeCapturePlaylist
                    playbackMode: Playlist.Random
                }

                Playlist {
                    id: afterCaptureVideoPlaylist
                    playbackMode: Playlist.Random
                }

                Playlist {
                    id: printingVideoPlaylist
                    playbackMode: Playlist.Random
                }

                Playlist {
                    id: signingVideosPlaylist
                    playbackMode: Playlist.Random
                }


                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.spacing
                    anchors.margins: root.columnMargins

                    VideoList {
                        Layout.fillWidth: true
                        title: "Start Videos"
                        playlist: startVideoPlaylist

                        onSaveRequest: {
                            videoSettings.startVideos = getPlaylistString(startVideoPlaylist)
                        }

                        Component.onCompleted: {
                            loadPlaylist(startVideoPlaylist, videoSettings.startVideos)
                        }

                    }

                    VideoList {
                        Layout.fillWidth: true
                        title: "Before Capture Videos"
                        playlist: beforeCapturePlaylist

                        onSaveRequest: {
                            videoSettings.beforeCaptureVideos = getPlaylistString(beforeCapturePlaylist)
                        }

                        Component.onCompleted: {
                            loadPlaylist(beforeCapturePlaylist, videoSettings.beforeCaptureVideos)
                        }

                    }

                    VideoList {
                        id: afterCaptureVideoCaptureList
                        Layout.fillWidth: true
                        title: "After Capture Videos"
                        playlist: afterCaptureVideoPlaylist

                        onSaveRequest: {
                            videoSettings.afterCaptureVideos = getPlaylistString(afterCaptureVideoPlaylist)
                        }

                        Component.onCompleted: {
                            loadPlaylist(afterCaptureVideoPlaylist, videoSettings.afterCaptureVideos)
                        }

                    }

                    VideoList {
                        Layout.fillWidth: true
                        title: "Printing Videos"
                        playlist: printingVideoPlaylist

                        onSaveRequest: {
                            videoSettings.printingVideos = getPlaylistString(printingVideoPlaylist)
                        }

                        Component.onCompleted: {
                            loadPlaylist(printingVideoPlaylist, videoSettings.printingVideos)
                        }

                    }

                    VideoList {
                        Layout.fillWidth: true
                        title: "Signing Videos"
                        playlist: signingVideosPlaylist

                        onSaveRequest: {
                            videoSettings.signingVideos = getPlaylistString(signingVideosPlaylist)
                        }

                        Component.onCompleted: {
                            loadPlaylist(signingVideosPlaylist, videoSettings.signingVideos)
                        }

                    }
                    RowLayout {  }
                }

            }

            Item {
                id: lightingView
                visible: false

                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.spacing
                    anchors.margins: root.columnMargins

                    CustomLabel {
                        text: "Serial COM Port"
                        subtitle: "COM port number for serial communication"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }

                    ComboBox {
                        model: ListModel {
                            ListElement { text: "COM1" }
                            ListElement { text: "COM2" }
                            ListElement { text: "COM3" }
                        }
                    }


                    RowLayout {}
                }



            }

            Item {
                id: canvasView
                visible: false

                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.spacing
                    anchors.margins: root.columnMargins



                    RowLayout {}

                }
            }
        }

    }

}







































/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:3;anchors_x:0;anchors_y:30}
}
 ##^##*/
