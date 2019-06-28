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
    property alias printFolder: printFolderField.text
    property alias saveFolder: saveFolderField.text
    property alias emailFolder: emailFolderField.text
    property alias displayScale: displayScalingButton.value

    property alias bgColor: bgColorRectangle.color
    property alias countDownColor: countDownColorRectangle.color

    property alias countdownTimer: countdownTimerButton.value
    property alias beforeCaptureTimer: beforeCaptureTimerButton.value
    property alias reviewTimer: reviewTimerButton.value
    property alias endSessionTimer: endSessionTimerButton.value
    property alias showLiveVideoOnStartSwitch: showLiveVideoOnStartSwitch.checked
    property alias showLiveVideoOnCountdownSwitch: showLiveVideoOnCountdownSwitch.checked
    property alias mirrorLiveVideoSwitch: mirrorLiveVideoSwitch.checked

    property alias printerName: printerNameField.text
    property alias autoPrint: autoPrint.checked
    property alias autoPrintCopies: autoPrintCopies.value
    property alias printCopiesPerSession: printCopiesPerSessionButton.value

    property string lastFolder: "file:///Users/Vu/Documents/PixylBooth/Videos"
    property alias startVideoPlaylist: startVideoPlaylist
    property alias beforeCaptureVideoPlaylist: beforeCapturePlaylist
    property alias afterCaptureVideoPlaylist: afterCaptureVideoPlaylist

    property real rowHeight: pixel(6)
    property real textSize: pixel(4)
    property real spacing: pixel(3)
    property real columnMargins: pixel(3)

    property string tempFilePath

    Settings {
        category: "General"
        id: generalSettings
        property alias countdownTimer: countdownTimerButton.value
        property alias beforeCaptureTimer: beforeCaptureTimerButton.value
        property alias reviewTimer: reviewTimerButton.value
        property alias endSessionTimer: endSessionTimerButton.value
        property alias displayScale: displayScalingButton.value
    }

    Settings {
        category: "Profile"
        id: profileSettings
        property alias saveFolder: saveFolderField.text
        property alias templateImagePath: templateImageField.text
        property alias printFolder: printFolderField.text
        property alias emailFolder: emailFolderField.text
    }

    Settings {
        category: "Camera"
        id: cameraSettings
        property alias showLiveVideoOnStart: showLiveVideoOnStartSwitch.checked
        property alias showLiveVideoOnCountdown: showLiveVideoOnCountdownSwitch.checked
        property alias mirrorLiveVideo: mirrorLiveVideoSwitch.checked
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
        property alias lastFolder: root.lastFolder
        property string startVideos
        property string beforeCaptureVideos
        property string afterCaptureVideos
    }


    PrintPhotos {
        id: imagePrint
    }


    ListModel {
        id: settingModel
        ListElement {
            name: "General"
            icon: "qrc:/Images/settings_white_48dp.png"
        }
        ListElement {
            name: "Profile"
            icon: "qrc:/Images/folder_shared_white_48dp.png"
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
            height: pixel(12)

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
                    listView.currentIndex = index
                    if(index == 0 && stackView.currentItem != generalView) {
                        stackView.replace(generalView)
                    }
                    else if(index == 1 && stackView.currentItem != profileView) {
                        stackView.replace(profileView)
                    }
                    else if(index == 2 && stackView.currentItem != cameraView) {
                        stackView.replace(cameraView)
                    }
                    else if(index == 3 && stackView.currentItem != colorView) {
                        stackView.replace(colorView)
                    }
                    else if(index == 4 && stackView.currentItem != printerView) {
                        stackView.replace(printerView)
                    }
                    else if(index == 5 && stackView.currentItem != videoView) {
                        stackView.replace(videoView)
                    }
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
            folder: root.lastFolder
            anchors.fill: parent

            Component.onCompleted: {
                browserClosed.connect(filePopup.close)
                fileSelected.connect(filePopup.close)
            }
        }



//        FileBrowser {
//            id: startVideoBrowser
//            folder: root.lastFolder
//            anchors.fill: parent
//            Component.onCompleted: {
//                browserClosed.connect(filePopup.close)
//                fileSelected.connect(filePopup.close)
//                fileSelected.connect(startVideoPlaylist.addItem)
//            }
//        }

//        FileBrowser {
//            id: beforeCaptureVideoBrowser
//            folder: root.lastFolder
//            anchors.fill: parent
//            Component.onCompleted: {
//                browserClosed.connect(filePopup.close)
//                fileSelected.connect(filePopup.close)
//                fileSelected.connect(beforeCapturePlaylist.addItem)
//            }
//        }

//        FileBrowser {
//            id: afterCaptureVideoBrowser
//            folder: root.lastFolder
//            anchors.fill: parent
//            Component.onCompleted: {
//                browserClosed.connect(filePopup.close)
//                fileSelected.connect(filePopup.close)
//                fileSelected.connect(afterCaptureVideoPlaylist.addItem)
//            }
//        }
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
                        id: countdownTimerButton
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
                        text: qsTr("Display Scaling")
                        subtitle: qsTr("Scaling factor for display buttons and text")
                    }

                    UpDownButton {
                        id: displayScalingButton
                        height: pixel(10)
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
                        subtitle: "Location of template image"
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
                            nameFilters: ["Image Files (*.jpg *.png)"]
                            onAccepted: {
                                templateImageField.text = stripFilePrefix(String(fileUrl))
                            }
                        }
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
                                saveFolderField.text = stripFilePrefix(String(folder))
                            }
                        }
                    }

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Print Folder")
                        subtitle: "Location to save prints"
                    }

                    TextField {
                        id: printFolderField
                        font.pixelSize: root.textSize
                        Layout.fillWidth: true
                        placeholderText: "Choose a print folder..."

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                printFolderDialog.open()
                            }
                        }

                        FolderDialog {
                            id: printFolderDialog
                            title: "Please select print directory"
                            onAccepted: {
                                printFolderField.text = stripFilePrefix(String(folder))
                            }
                        }
                    }

                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Email Folder")
                        subtitle: "Location to save email list"
                    }

                    TextField {
                        id: emailFolderField
                        font.pixelSize: root.textSize
                        Layout.fillWidth: true
                        placeholderText: "Choose a email folder..."

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                emailFolderDialog.open()
                            }
                        }

                        FolderDialog {
                            id: emailFolderDialog
                            title: "Please select email directory"
                            onAccepted: {
                                emailFolderField.text = stripFilePrefix(String(folder))
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

                    ComboBox {
                        Layout.fillWidth: true

                        model: QtMultimedia.availableCameras
                        textRole: "displayName"
                        displayText: "Liveview: " + currentText
                        delegate: ItemDelegate {
                            text: modelData.displayName

                            onClicked: {
                                camera.deviceId = modelData.deviceId
//                                console.log(modelData.displayName)
                            }
                        }

                    }

//                    ListView {
//                        Layout.fillWidth: true
//                        height: 300


//                        model: QtMultimedia.availableCameras
//                        delegate: Text {
//                            text: modelData.displayName

//                            color: "white"

//                            MouseArea {
//                                anchors.fill: parent
//                                onClicked: {
//                                    camera.deviceId = modelData.deviceId
//                                }
//                            }
//                        }
//                    }

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
                        id: printCopiesPerSessionButton
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
                    var playlists = [startVideoPlaylist, beforeCapturePlaylist, afterCaptureVideoPlaylist]
                    var playlistsString = [videoSettings.startVideos, videoSettings.beforeCaptureVideos, videoSettings.afterCaptureVideos]

                    for (var j = 0 ; j < playlists.length ; j++) {
                        playlists[j].clear()
                        var datamodel = JSON.parse(playlistsString[j])
                        for (var i = 0 ; i < datamodel.length ; i++) playlists[j].addItem(datamodel[i])
                    }

                }

                Component.onDestruction: {

                    var playlists = [startVideoPlaylist, beforeCapturePlaylist, afterCaptureVideoPlaylist]
                    var playlistsString = [videoSettings.startVideos, videoSettings.beforeCaptureVideos, videoSettings.afterCaptureVideos]

                    for (var j = 0 ; j < playlists.length ; j++) {
                        var datamodel = []
                        for (var i = 0 ; i < playlists[j].itemCount ; i++) datamodel.push(playlists[j].itemSource(i))

                        if (j === 0) videoSettings.startVideos = JSON.stringify(datamodel)
                        else if (j === 1) videoSettings.beforeCaptureVideos = JSON.stringify(datamodel)
                        else if (j === 2) videoSettings.afterCaptureVideos = JSON.stringify(datamodel)
                    }

                }


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


                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.spacing
                    anchors.margins: root.columnMargins

                    VideoList {
                        id: startVideoList
                        Layout.fillWidth: true
                        title: "Start Videos"
                        model: startVideoPlaylist


                        addButton.onClicked: {
                            filePopup.open()
                            fileBrowser.playlist = startVideoPlaylist
                        }

                        clearButton.onClicked: {
                            startVideoPlaylist.clear()
                        }
                    }

                    VideoList {
                        id: beforeCaptureVideoList
                        Layout.fillWidth: true
                        title: "Before Capture Videos"
                        model: beforeCapturePlaylist

                        addButton.onClicked: {
                            filePopup.open()
                            fileBrowser.playlist = beforeCapturePlaylist
                        }

                        clearButton.onClicked: {
                            beforeCapturePlaylist.clear()
                        }

                    }

                    VideoList {
                        id: afterCaptureVideoCaptureList
                        Layout.fillWidth: true
                        title: "After Capture Videos"
                        model: afterCaptureVideoPlaylist

                        addButton.onClicked: {
                            filePopup.open()
                            fileBrowser.playlist = afterCaptureVideoPlaylist
                        }
                        clearButton.onClicked: {
                            afterCaptureVideoPlaylist.clear()
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
