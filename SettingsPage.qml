import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.2
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
    property alias saveFolder: saveFolderField.text
    property alias displayScale: displayScalingButton.value
    property alias lockPin: lockPinTextField.text

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
    property alias portraitModeSwitch: portraitModeSwitch.checked

    property alias printerName: printerNameField.text
    property alias autoPrint: autoPrint.checked
    property alias autoPrintCopies: autoPrintCopies.value
    property alias printCopiesPerSession: printCopiesPerSessionButton.value
    property alias paperName: paperNameField.text
    property alias print6x4Split: print6x4SplitSwitch.checked

    property alias startVideoPlaylist: startVideoPlaylist
    property alias beforeCaptureVideoPlaylist: beforeCapturePlaylist
    property alias afterCaptureVideoPlaylist: afterCaptureVideoPlaylist
    property alias processingVideoPlaylist: processingVideoPlaylist
    property alias printingVideoPlaylist: printingVideoPlaylist
    property alias signingVideoPlaylist: signingVideoPlaylist

    property real rowHeight: pixel(24)
    property real textSize: pixel(16)
    property real spacing: pixel(20)
    property real columnMargins: pixel(10)

    property real numberPhotos
    property string templateFormat
    property real buttonHeight: pixel(36)

    property alias emojiFolder: emojiFolderField.text

    function loadPlaylist(playlist, playlistString) {
        if (String(playlistString).length == 0) return;
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
        property alias lockPin: lockPinTextField.text

    }

    Settings {
        category: "Profile"
        id: profileSettings
        property alias saveFolder: saveFolderField.text
        property alias templateImagePath: templateImageField.text
        property alias templateFormat: root.templateFormat
        property alias numberPhotos: root.numberPhotos
        property alias emojiFolder: emojiFolderField.text
//        property alias albumUrl: albumUrlField.text
    }


    Settings {
        category: "Camera"
        id: cameraSettings
        property alias showLiveVideoOnStart: showLiveVideoOnStartSwitch.checked
        property alias showLiveVideoOnCountdown: showLiveVideoOnCountdownSwitch.checked
        property alias mirrorLiveVideo: mirrorLiveVideoSwitch.checked
        property alias portraitMode: portraitModeSwitch.checked
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
        property alias paperName: paperNameField.text
        property alias print6x4Split: print6x4SplitSwitch.checked
    }

    Settings {
        category: "Videos"
        id: videoSettings
        property string lastFolder
        property string startVideos
        property string beforeCaptureVideos
        property string afterCaptureVideos
        property string processingVideos
        property string printingVideos
        property string signingVideos
    }

    ListModel {
        id: settingModel
        ListElement {
            name: "General"
            iconSource: "qrc:/svg/sliders-h-solid"
        }
        ListElement {
            name: "Profile"
            iconSource: "qrc:/svg/user-solid"
        }
        ListElement {
            name: "Camera"
            iconSource: "qrc:/svg/camera-solid"
        }
        ListElement {
            name: "Color Theme"
            iconSource: "qrc:/svg/palette-solid"
        }
        ListElement {
            name: "Printer"
            iconSource: "qrc:/svg/print-solid"
        }
        ListElement {
            name: "Animation"
            iconSource: "qrc:/svg/youtube"
        }
        ListElement {
            name: "Lighting"
            iconSource: "qrc:/svg/lightbulb-solid"
        }
        ListElement {
            name: "Canvas"
            iconSource: "qrc:/svg/brush-solid"
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

//        VideoBrowser {
//            id: fileBrowser
//            folder: videoSettings.lastFolder
//            anchors.fill: parent

//            Component.onCompleted: {
//                browserClosed.connect(filePopup.close)
//                fileSelected.connect(filePopup.close)
//            }
//        }

    }

    ColumnLayout {
        anchors.fill: parent
        anchors {
            leftMargin: pixel(20)
            rightMargin: pixel(20)
            topMargin: pixel(80)
            bottomMargin: pixel(20)
        }

        StackView {
            id: stackView
//            anchors.fill: parent
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
//            anchors.left: leftSide.right
//            anchors.right: parent.right
//            anchors.top: parent.top
//            anchors.bottom: parent.bottom


            initialItem: ListView {
                id: listView
                boundsBehavior: Flickable.StopAtBounds
                model: settingModel
    //                anchors.fill: parent
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: true


                delegate: ItemDelegate {
                    id: control
                    text: name
                    width: parent.width
                    icon.source: iconSource
                    display: AbstractButton.TextBesideIcon

                    onClicked: {
                        listView.currentIndex = index
                        var viewList = [generalView, profileView, cameraView, colorView, printerView, videoView, lightingView, canvasView]
                        stackView.push(viewList[index])
                    }
                }

//                highlightMoveDuration: 100
//                highlight: Rectangle {
//                    color: Material.color(Material.Cyan, Material.Shade800)
//                }

            }


        }


        Item {
            id: generalView
            visible: false

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.columnMargins
                spacing: root.spacing


                RowLayout {
                    Button {
                        icon.source: 'qrc:/svg/angle-left-solid'

                        onClicked: {
                            stackView.pop()
                            console.log("pop")
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: 'General'
                        enabled: false
                    }
                }

                RowLayout {
                    CustomLabel {
                        Layout.alignment: Qt.AlignLeft
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Before Capture Timer")
                        subtitle: qsTr("Duration to display video before capture")
                    }

                    UpDownButton {
                        id: beforeCaptureTimerButton
                        height: buttonHeight
                        width: height * 3
                        min: 2
                    }
                }


                RowLayout {
                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("After Capture Timer")
                        subtitle: qsTr("Duration to display video after capture")
                    }

                    UpDownButton {
                        id: afterCaptureTimerButton
                        height: buttonHeight
                        width: height * 3
                        min: 2
                    }
                }


                RowLayout {

                    CustomLabel {

                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Capture Countdown")
                        subtitle: qsTr("Duration before picture taken")
                    }


                    UpDownButton {

                        id: countdownTimerButton
                        height: buttonHeight
                        width: height * 3
                        min: 3
                    }
                }


                RowLayout {


                    CustomLabel {

                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Review Timer")
                        subtitle: qsTr("Duration to display photo after capture")
                    }

                    UpDownButton {

                        id: reviewTimerButton
                        height: buttonHeight
                        width: height * 3
                        min: 2
                    }

                }

                RowLayout {

                    CustomLabel {

                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("End Session Timer")
                        subtitle: qsTr("Duration to show the end of session")
                    }

                    UpDownButton {

                        id: endSessionTimerButton
                        height: buttonHeight
                        width: height * 3
                        min: 10
                    }
                }



                RowLayout {


                    CustomLabel {

                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Scaling Factor")
                        subtitle: qsTr("Scaling factor for the user interface")
                    }

                    UpDownButton {

                        id: displayScalingButton
                        height: buttonHeight
                        width: height * 3
                        min: 1
                    }
                }

                RowLayout {

                    CustomLabel {

                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Lock PIN")
                        subtitle: qsTr("Password to lock/unlock screen")
                    }

                    TextField {

                        id: lockPinTextField
                        font.pointSize: 16
                        horizontalAlignment: TextInput.AlignHCenter
                        placeholderText: "Enter a PIN"
                        echoMode: TextInput.Password
                        inputMethodHints: Qt.ImhDigitsOnly
                        enabled: true

                        onEditingFinished: {
                            keypad.visible = false
                        }

                        onPressed: {
                            keypad.visible = true
                        }
                    }


                }

                InputPanel {
                    id: keypad
                    visible: false
                    Layout.fillWidth: true

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

                RowLayout {
                    Button {
                        icon.source: 'qrc:/svg/angle-left-solid'

                        onClicked: {
                            stackView.pop()
                            console.log("pop")
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: 'Profile'
                        enabled: false
                    }
                }

                CustomLabel {
                    height: root.rowHeight
                    Layout.fillWidth: true
                    text: qsTr("Template Image")
                    subtitle: "Path of template image for photos"
                }

                PathField {
                    id: templateImageField
                    font.pixelSize: root.textSize
                    Layout.fillWidth: true
                    placeholderText: "Choose a template..."
                    title: "Please select a template"
                    nameFilters: ["PNG Image Files (*.png)"]
                    isFile: true
                }

                Button {
                    text: "Format Template"
                    onClicked: {
                        var component = Qt.createComponent("TemplateEditor.qml")
                        var window    = component.createObject(root)
                        window.show()

                    }
                }


//                    CustomLabel {
//                        height: root.rowHeight
//                        Layout.fillWidth: true
//                        text: qsTr("Album Link")
//                        subtitle: "Album URL for QR code generation"
//                    }

//                    RowLayout {
//                        Layout.fillWidth: true
//                        TextField {
//                            id: albumUrlField
//                            font.pixelSize: root.textSize
//                            Layout.fillWidth: true

//                            placeholderText: "Enter album URL"
//                            selectByMouse: true

//                            onReleased: {
//                                contextMenu.open()
//                            }

//                            Menu {
//                                id: contextMenu

//                                MenuItem {
//                                    text: "Cut"

//                                    iconSource: "qrc:/icons/clear-black"
//                                    onTriggered: {
//                                        albumUrlField.cut()
//                                    }
//                                }

//                                MenuItem {
//                                    text: "Clear"

//                                    iconSource: "qrc:/icons/clear-black"
//                                    onTriggered: {
//                                        albumUrlField.clear()
//                                    }
//                                }
//                                MenuItem {
//                                    text: "Copy"
//                                    iconSource: "qrc:/icons/copy-black"
//                                    onTriggered: {
//                                        albumUrlField.selectAll()
//                                        albumUrlField.copy()
//                                    }
//                                }
//                                MenuItem {
//                                    text: "Clear 'n' Paste"
//                                    iconSource: "qrc:/icons/paste_black"
//                                    onTriggered: {
//                                        albumUrlField.clear()
//                                        albumUrlField.paste()
//                                    }
//                                }
//                            }
//                        }
//                        Button {
//                            icon.source: "qrc:/icons/check"
//                            onClicked: {
//                                getQrImage()
//                            }
//                        }
//                    }






                CustomLabel {
                    height: root.rowHeight
                    Layout.fillWidth: true
                    text: qsTr("Save Folder")
                    subtitle: "Folder to save current session"
                }

                PathField {
                    id: saveFolderField
                    font.pixelSize: root.textSize
                    Layout.fillWidth: true
                    placeholderText: "Choose a save folder..."
                    title: "Please select save directory"
                    isFile: false

                    onDialogOk: {
                        captureView.sonyRemote.saveFolder = saveFolderField.text + "/Camera"
//                            captureView.sonyRemote.restart()
                    }

                }

                CustomLabel {
                    height: root.rowHeight
                    Layout.fillWidth: true
                    text: qsTr("Emojis Folder")
                    subtitle: "Folder of emojis"
                }

                PathField {
                    id: emojiFolderField
                    font.pixelSize: root.textSize
                    Layout.fillWidth: true
                    placeholderText: "Choose an emoji folder..."
                    title: "Please select emoji folder"
                    isFile: false

                }





//                    TextField {
//                        id: emojiFolderField
//                        font.pixelSize: root.textSize
//                        Layout.fillWidth: true
//                        placeholderText: "Choose an emoji folder..."

//                        MouseArea {
//                            anchors.fill: parent
//                            onClicked: {
//                                emojiFolderFolderDialog.open()
//                            }
//                        }

//                        FolderDialog {
//                            id: emojiFolderFolderDialog
//                            title: "Please select directory"
//                            onAccepted: {
//                                emojiFolderField.text = stripFilePrefix(String(folder))
//                            }
//                        }
//                    }

//                    CustomLabel {
//                        height: root.rowHeight
//                        Layout.fillWidth: true
//                        text: qsTr("Canvas Save Folder")
//                        subtitle: "Folder to save guest's canvas"
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

                RowLayout {
                    Button {
                        icon.source: 'qrc:/svg/angle-left-solid'

                        onClicked: {
                            stackView.pop()
                            console.log("pop")
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: 'Camera'
                        enabled: false
                    }
                }

                CustomLabel {
                    text: "Live Video on Start"
                    subtitle: "Shows live video on start screen"
                    height: root.rowHeight
                    Layout.fillWidth: true
                    visible: false
                }
                Switch {
                    id: showLiveVideoOnStartSwitch
                    visible: false
                }

                CustomLabel {
                    text: "Live Video on Countdown"
                    subtitle: "Shows live video during countdown"
                    height: root.rowHeight
                    Layout.fillWidth: true
                    visible: false
                }
                Switch {
                    id: showLiveVideoOnCountdownSwitch
                    visible: false
                }

                CustomLabel {
                    text: "Auto Camera Trigger"
                    subtitle: "Trigger camera shutter automatically"
                    height: root.rowHeight
                    Layout.fillWidth: true
                    visible: false
                }
                Switch {
                    id: autoTriggerSwitch
                    visible: false
                }

                RowLayout {
                    Layout.fillWidth: true

                    CustomLabel {
                        text: "Mirror Live Video"
                        subtitle: "Flips live video horizontally"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }

                    Switch {
                        Layout.alignment: Qt.AlignRight
                        id: mirrorLiveVideoSwitch
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    CustomLabel {
                        text: "Portrait Mode"
                        subtitle: "Capture images in vertical orientation"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }

                    Switch {
                        Layout.alignment: Qt.AlignRight
                        id: portraitModeSwitch
                    }
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

                RowLayout {
                    Button {
                        icon.source: 'qrc:/svg/angle-left-solid'

                        onClicked: {
                            stackView.pop()
                            console.log("pop")
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: 'Theme'
                        enabled: false
                    }
                }

                RowLayout {

                    CustomLabel {
                        Layout.fillWidth: true
                        height: root.rowHeight
                        text: qsTr("Countdown Color")
                        subtitle: qsTr("Color of the countdown text")
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        Rectangle {
                            id: countDownColorRectangle
                            width: root.rowHeight
                            height: root.rowHeight
                            color: "#ffffff"
                            radius: 4
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
                            enabled: false
                        }

                    }

                }

                RowLayout {
                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: qsTr("Background Color")
                        subtitle: qsTr("Color of the background")
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        Rectangle {
                            id: bgColorRectangle
                            width: root.rowHeight
                            height: root.rowHeight
                            color: "#000000"
                            radius: 4
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
                            enabled: false
                        }


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

                RowLayout {
                    Button {
                        icon.source: 'qrc:/svg/angle-left-solid'

                        onClicked: {
                            stackView.pop()
                            console.log("pop")
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: 'Printer'
                        enabled: false
                    }
                }

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
                            printPhotos.getPrinterSettings(printerNameField.text)
                            printerNameField.text = printPhotos.printerName
                            paperNameField.text = printPhotos.paperName
                        }
                    }
                }

                CustomLabel {
                    height: root.rowHeight
                    Layout.fillWidth: true
                    text: "Paper Name"
                    subtitle: "Paper name for selected printer"
                }
                TextField {
                    id: paperNameField
                    Layout.fillWidth: true
                    placeholderText: "Click here to change printer preference"
                    height: root.rowHeight

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            printPhotos.getPrinterSettings(printerNameField.text)
                            printerNameField.text = printPhotos.printerName
                            paperNameField.text = printPhotos.paperName
                        }
                    }
                }

                RowLayout {
                    CustomLabel {
                        height: root.rowHeight
                        Layout.fillWidth: true
                        text: "6x4 Split"
                        subtitle: "Print double for 6x4 split"
                    }

                    Switch {
                        id: print6x4SplitSwitch
                    }
                }


                RowLayout {
                    CustomLabel {
                        text: "Automatic Printing"
                        subtitle: "Print automatically after each session"
                        height: root.rowHeight
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: autoPrint
                    }
                }

                RowLayout {
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
                        min: 1
                    }
                }

                RowLayout {
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
                        min: 1
                    }
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
                id: processingVideoPlaylist
                playbackMode: Playlist.Random
            }

            Playlist {
                id: printingVideoPlaylist
                playbackMode: Playlist.Random
            }

            Playlist {
                id: signingVideoPlaylist
                playbackMode: Playlist.Random
            }


            ColumnLayout {
                anchors.fill: parent
                spacing: root.spacing
                anchors.margins: root.columnMargins

                RowLayout {
                    Button {
                        icon.source: 'qrc:/svg/angle-left-solid'

                        onClicked: {
                            stackView.pop()
                            console.log("pop")
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: 'Animation'
                        enabled: false
                    }
                }

                VideoList {
                    id: startVideoVideoList
                    Layout.fillWidth: true
                    title: "Start Videos"
                    playlist: startVideoPlaylist
                    onHideChanged: {
                        if (!hide) {
                            beforeCaptureVideoList.collapse()
                            afterCaptureVideoList.collapse()
                            processingVideoList.collapse()
                            printingVideoList.collapse()
                            signingVideoList.collapse()
                        }
                    }

                    onSaveRequest: {
                        videoSettings.startVideos = getPlaylistString(startVideoPlaylist)
                    }

                    Component.onCompleted: {
                        loadPlaylist(startVideoPlaylist, videoSettings.startVideos)
                    }

                }

                VideoList {
                    id: beforeCaptureVideoList
                    Layout.fillWidth: true
                    title: "Before Capture Videos"
                    playlist: beforeCapturePlaylist

                    onHideChanged: {
                        if (!hide) {
                            startVideoVideoList.collapse()
                            afterCaptureVideoList.collapse()
                            processingVideoList.collapse()
                            printingVideoList.collapse()
                            signingVideoList.collapse()
                        }
                    }

                    onSaveRequest: {
                        videoSettings.beforeCaptureVideos = getPlaylistString(beforeCapturePlaylist)
                    }

                    Component.onCompleted: {
                        loadPlaylist(beforeCapturePlaylist, videoSettings.beforeCaptureVideos)
                    }

                }

                VideoList {
                    id: afterCaptureVideoList
                    Layout.fillWidth: true
                    title: "After Capture Videos"
                    playlist: afterCaptureVideoPlaylist

                    onHideChanged: {
                        if (!hide) {
                            startVideoVideoList.collapse()
                            beforeCaptureVideoList.collapse()
                            processingVideoList.collapse()
                            printingVideoList.collapse()
                            signingVideoList.collapse()
                        }
                    }

                    onSaveRequest: {
                        videoSettings.afterCaptureVideos = getPlaylistString(afterCaptureVideoPlaylist)
                    }

                    Component.onCompleted: {
                        loadPlaylist(afterCaptureVideoPlaylist, videoSettings.afterCaptureVideos)
                    }

                }

                VideoList {
                    id: processingVideoList
                    Layout.fillWidth: true
                    title: "Processing Videos"
                    playlist: processingVideoPlaylist

                    onHideChanged: {
                        if (!hide) {
                            startVideoVideoList.collapse()
                            beforeCaptureVideoList.collapse()
                            afterCaptureVideoList.collapse()
                            printingVideoList.collapse()
                            signingVideoList.collapse()
                        }
                    }

                    onSaveRequest: {
                        videoSettings.processingVideos = getPlaylistString(processingVideoPlaylist)
                    }

                    Component.onCompleted: {
                        loadPlaylist(processingVideoPlaylist, videoSettings.processingVideos)
                    }

                }

                VideoList {
                    id: printingVideoList
                    Layout.fillWidth: true
                    title: "Printing Videos"
                    playlist: printingVideoPlaylist

                    onHideChanged: {
                        if (!hide) {
                            startVideoVideoList.collapse()
                            beforeCaptureVideoList.collapse()
                            afterCaptureVideoList.collapse()
                            processingVideoList.collapse()
                            signingVideoList.collapse()
                        }
                    }

                    onSaveRequest: {
                        videoSettings.printingVideos = getPlaylistString(printingVideoPlaylist)
                    }

                    Component.onCompleted: {
                        loadPlaylist(printingVideoPlaylist, videoSettings.printingVideos)
                    }

                }

                VideoList {
                    id: signingVideoList
                    Layout.fillWidth: true
                    title: "Signing Videos"
                    playlist: signingVideoPlaylist

                    onHideChanged: {
                        if (!hide) {
                            startVideoVideoList.collapse()
                            beforeCaptureVideoList.collapse()
                            afterCaptureVideoList.collapse()
                            processingVideoList.collapse()
                            printingVideoList.collapse()
                        }
                    }

                    onSaveRequest: {
                        videoSettings.signingVideos = getPlaylistString(signingVideoPlaylist)
                    }

                    Component.onCompleted: {
                        loadPlaylist(signingVideoPlaylist, videoSettings.signingVideos)
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

                RowLayout {
                    Button {
                        icon.source: 'qrc:/svg/angle-left-solid'

                        onClicked: {
                            stackView.pop()
                            console.log("pop")
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: 'Lighting'
                        enabled: false
                    }
                }

                RowLayout {}

            }

//                ColumnLayout {
//                    anchors.fill: parent
//                    spacing: root.spacing
//                    anchors.margins: root.columnMargins

//                    CustomLabel {
//                        text: "Serial COM Port"
//                        subtitle: "COM port number for serial communication"
//                        height: root.rowHeight
//                        Layout.fillWidth: true
//                    }

//                    ComboBox {
//                        model: ListModel {
//                            ListElement { text: "COM1" }
//                            ListElement { text: "COM2" }
//                            ListElement { text: "COM3" }
//                        }
//                    }


//                    RowLayout {}
//                }



        }

        Item {
            id: canvasView
            visible: false

            ColumnLayout {
                anchors.fill: parent
                spacing: root.spacing
                anchors.margins: root.columnMargins

                RowLayout {
                    Button {
                        icon.source: 'qrc:/svg/angle-left-solid'

                        onClicked: {
                            stackView.pop()
                            console.log("pop")
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: 'Canvas'
                        enabled: false
                    }
                }
                RowLayout {}

            }
        }



    }


}
