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
import QtGraphicalEffects 1.0

Item {
    id: root
    property real rowHeight: pixel(6)
    property real textSize: pixel(4)
    property real spacing: pixel(3)

    property alias captureTimer: captureTimerSlider.value
    property alias beforeCaptureTimer: beforeCaptureTimerSlider.value
    property alias reviewTimer: reviewTimerSlider.value
    property alias saveFolder: saveFolderField.text
    property alias endSessionTimer: endSessionTimerSlider.value
    property alias liveVideoStartSwitch: liveVideoStartSwitch.checked
    property alias liveVideoCountdownSwitch: liveVideoCountdownSwitch.checked
    property alias printerName: printerNameField.text
    property alias maxCopyCount: maxCopyCountSlider.value

    property alias startVideoListModel: startVideoListModel
    property alias beforeCaptureVideoListModel: beforeCaptureVideoListModel
    property alias afterCaptureVideoListModel: afterCaptureVideoListModel

    property string lastFolder: "file:///"
    property string startVideosListModelString: ""
    property string beforeCaptureVideosListModelString: ""
    property string afterCaptureVideosListModelString: ""

    Settings {
        category: "General"
        property alias captureTimer: captureTimerSlider.value
        property alias beforeCaptureTimer: beforeCaptureTimerSlider.value
        property alias reviewTimer: reviewTimerSlider.value
        property alias saveFolder: saveFolderField.text
        property alias endSessionTimer: endSessionTimerSlider.value
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
        property alias maxCopyCount: maxCopyCountSlider.value
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

    function pixel(pixel) {
        return pixel * Screen.pixelDensity
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
                    if(index == 0) {
                        stackView.pop()
                        stackView.push(generalView)
                    }
                    else if(index == 1) {
                        stackView.pop()
                        stackView.push(cameraView)
                    }
                }
            }

        }
    }


    ColumnLayout {
        anchors.fill: parent
        anchors {
            topMargin: pixel(10)
            bottomMargin: pixel(10)
            leftMargin: pixel(10)
            rightMargin: pixel(10)
        }

        Material.background: Material.color(Material.Grey, Material.Shade800)
        Material.primary: Material.color(Material.Grey, Material.Shade700)

        Rectangle {
            id: outerRect
            Layout.alignment: Qt.AlignCenter
            width: parent.width
            height: parent.height
            color: Material.background
            radius: pixel(3)

            Rectangle {
                id: leftSide
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: pixel(40)
                color: Material.primary

                ListView {
                    id: listView
                    boundsBehavior: Flickable.StopAtBounds
                    model: settingModel
                    anchors.fill: parent
                    delegate: settingDelegate
                    highlight: Rectangle {
                        color: Material.background
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

            }

            Item {
                id: generalView
                visible: false
                property real rowHeight: pixel(6)
                property real textSize: pixel(4)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: pixel(4)
                    spacing: pixel(3)

                    RowLayout {
                        CustomLabel {
                            font.pixelSize: generalView.textSize
                            height: generalView.rowHeight
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("Before Capture Video Time")
                            subtitle: qsTr("Time to display video before capture ")
                        }

                        Slider {
                            id: beforeCaptureTimerSlider
                            height: generalView.rowHeight
                            Layout.fillWidth: true
                            stepSize: 1
                            to: 20
                            value: 5
                        }

                        Label {
                            height: generalView.rowHeight
                            text: beforeCaptureTimerSlider.value + " s"
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: generalView.textSize
                        }
                    }

                    RowLayout {
                        CustomLabel {
                            font.pixelSize: generalView.textSize
                            height: generalView.rowHeight
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("Capture Countdown")
                            subtitle: qsTr("Time before picture taken")
                        }

                        Slider {
                            id: captureTimerSlider
                            height: 48
                            Layout.fillWidth: true
                            stepSize: 1
                            to: 20
                            value: 5
                        }

                        Label {
                            height: generalView.rowHeight
                            text: captureTimerSlider.value + " s"
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: generalView.textSize
                        }
                    }

                    RowLayout {
                        CustomLabel {
                            font.pixelSize: generalView.textSize
                            height: generalView.rowHeight
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("Review Time")
                            subtitle: qsTr("Duration to display photo")
                        }

                        Slider {
                            id: reviewTimerSlider
                            Layout.fillWidth: true
                            transformOrigin: Item.Left
                            value: 5
                            stepSize: 1
                            to: 20
                        }

                        Label {
                            height: generalView.rowHeight
                            text: reviewTimerSlider.value + " s"
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: generalView.textSize
                        }
                    }

                    RowLayout {
                        CustomLabel {
                            font.pixelSize: generalView.textSize
                            height: generalView.rowHeight
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("End Session Timer   ")
                            subtitle: qsTr("Duration to show the end of session")
                        }

                        Slider {
                            id: endSessionTimerSlider
                            Layout.fillWidth: true
                            transformOrigin: Item.Left
                            value: 5
                            stepSize: 1
                            to: 20
                        }

                        Label {
                            height: generalView.rowHeight
                            text: endSessionTimerSlider.value + " s"
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: generalView.textSize
                        }
                    }

                    RowLayout {
                        id: rowLayout
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        spacing: pixel(3)

                        CustomLabel {
                            id: label
                            text: qsTr("Save Folder")
                            subtitle: "Location to save photos"
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: generalView.textSize
                        }

                        TextField {
                            id: saveFolderField
                            font.pixelSize: generalView.textSize
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
        //                            console.log(folder)
                                }
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

                    RowLayout {
                        Switch {
                            id: liveVideoStartSwitch
                            text: qsTr("Show Live Video on Start")
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Switch {
                            id: liveVideoCountdownSwitch
                            text: qsTr("Show Live Video During Countdown")
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Switch {
                            id: autoTriggerSwitch
                            text: qsTr("Auto Trigger Camera")
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Switch {
                            id: mirrorLiveVideoSwitch
                            text: qsTr("Mirror Live Video")
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {}

                }

            }
        }



        CustomPane {
            id: cameraPane
            title: "Camera"
            Layout.minimumWidth: 400
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible: false

            ColumnLayout {
                anchors.fill: parent
                spacing: 20











//                RowLayout {
////                    Dial {
////                        id: dial
////                        value: 0
////                        stepSize: 90
////                        from: 0.0
////                        to: 270

////                        Label {
////                            text: Math.round(dial.value)
////                            verticalAlignment: Text.AlignVCenter
////                            horizontalAlignment: Text.AlignHCenter
////                            anchors.horizontalCenter: parent.horizontalCenter
////                            anchors.verticalCenter: parent.verticalCenter
////                        }
////                    }

//                    Label {
//                        text: qsTr("Live Video Rotation")
//                    }
//                }


                RowLayout {
                }



            }
        }

        CustomPane {
            id: colorPane
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            title: "Color"
            visible: false

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

        CustomPane {
            id: printerPane
            Layout.preferredWidth: root.width * 0.9
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            title: "Printer"
            visible: false

            ColumnLayout {
                anchors.fill: parent
                RowLayout {
                    spacing: 20
                    CustomLabel {
                        text: "Printer Name"
                        subtitle: "The printer of your choice"
                        font.pixelSize: 24
                        height: 48
                    }
                    TextField {
                        id: printerNameField
                        Layout.fillWidth: true
                        placeholderText: "Click here to set printer"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                printerNameField.text = String(imagePrint.getPrinterName())

                            }
                        }
                    }
                }

                RowLayout {
                    spacing: 20
                    CustomLabel {
                        text: "Max Print Copies"
                        subtitle: "Print limit per session"
                        font.pixelSize: 24
                        height: 48
                    }
                    Slider {
                        id: maxCopyCountSlider
                        height: 48
                        Layout.fillWidth: true
                        stepSize: 1
                        to: 20
                        value: 5
                    }

                    Label {
                        height: 48
                        text: maxCopyCountSlider.value
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 24
                    }


                }
            }
        }

        ColumnLayout {
            id: videoPane
            visible: false

            property alias startVideoListModel: startVideoListModel
            property alias beforeCaptureVideoListModel: beforeCaptureVideoListModel
            property alias afterCaptureVideoListModel: afterCaptureVideoListModel

        //    property string lastFolder: "file:///Users/Vu/Documents/PixylBooth/Videos"
            property string lastFolder: "file:///"

            property string startVideosListModelString: ""
            property string beforeCaptureVideosListModelString: ""
            property string afterCaptureVideosListModelString: ""


            Settings {
                category: "Videos"
                property alias startVideos: root.startVideosListModelString
                property alias beforeCaptureVideos: root.beforeCaptureVideosListModelString
                property alias afterCaptureVideos: root.afterCaptureVideosListModelString
                property alias lastFolder: root.lastFolder
            }

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

            Pane {
                id: pane
                Layout.minimumWidth: 500
                Layout.preferredWidth: root.width * 0.9
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                background: Rectangle {
                    color: "transparent"
                }

                ColumnLayout {
                    id: columnLayout1
                    anchors.fill: parent

                    Button {
                        text: "test"
                        onClicked: {
                            startVideoListModel.remove(0)
                        }
                    }

                    VideoList {
                        id: startVideoList
                        Layout.fillWidth: true
                        title: "Start Videos"
                        //                delegate: fileDelegate
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
                        //                delegate: fileDelegate
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
                        //                delegate: fileDelegate
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
