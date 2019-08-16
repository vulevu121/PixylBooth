import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.13

Popup {
    id: canvasPopup
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    modal: true
    padding: 2

    property string saveFolder
    property real iconSize: pixel(20)

    Overlay.modal: Rectangle {
            color: "#A0101010"
    }

    onOpened: {
        var canvasURL = getCanvasURL()
        canvas.lastCanvasLoaded = false
        canvas.loadImage(canvasURL)
    }

    onClosed: {
        var canvasURL = getCanvasURL()
//                    console.log(canvasURL)
        canvas.save(stripFilePrefix(canvasURL))
        console.log(canvasURL, "saved")
    }


//    margins: 0
//    background: Rectangle {
//        color: Material.background
//        opacity: 1
//        radius: pixel(2)
//    }
    property alias source: image.source

    function getCanvasURL() {
        var fileURL = String(image.source)
        var canvasURL = fileURL.replace(".jpg", ".png")
        return canvasURL.replace("/Prints/", "/Canvas/")
    }

    ListModel {
        id: colorModel
        ListElement { foreground: "#ffffff"; background: "#ffffff" }
        ListElement { foreground: "#000000"; background: "#000000" }
        ListElement { foreground: "#00ffff"; background: "#4d4cff" }
        ListElement { foreground: "#e40e34"; background: "#cd1588" }
        ListElement { foreground: "#6fff00"; background: "#ffff00" }
        ListElement { foreground: "#fc66b5"; background: "#9803d1" }
        ListElement { foreground: "#f4df82"; background: "#ddb462" }
        ListElement { foreground: "#59e7ff"; background: "#216d7a" }
        ListElement { foreground: "#f98f21"; background: "#ddb462" }
    }

    Component {
        id: colorDelegate

        Item {
            width: canrect.paletteSize
            height: canrect.paletteSize
            Rectangle {
                anchors.fill: parent
                anchors.margins: 2

                gradient: Gradient {
                    GradientStop { position: 0.0; color: foreground }
                    GradientStop { position: 1.0; color: background }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        colorPalette.currentIndex = index
                        canvas.strokeColor = foreground
                        canvas.shadowColor = background
                    }
                }
            }
        }
    }

    FolderListModel {
        id: emojisModel
        folder: addFilePrefix(settings.emojiFolder)
        nameFilters: ["*.png"]
    }

    Component {
        id: brushDelegate

        Item {
            width: canrect.paletteSize
            height: canrect.paletteSize
            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                color: "black"

                Image {
                    anchors.fill: parent
                    source: fileURL
                    sourceSize.width: canrect.paletteSize
                    sourceSize.height: canrect.paletteSize

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        brushPalette.currentIndex = index

                        if (index == 0) {
                            canvas.rainbowColor = false
                        }
                        else if (index == 1) {
                            canvas.rainbowColor = true
                        }
                        else if (index >= 2) {
                            canvas.patternImage = fileURL
                        }

                        canvas.loadImage(emojisModel.get(index, "fileURL"))

                    }
                }
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
            spacing: pixel(6)

            ColumnLayout {}



            UpDownButton {
                id: printCopyCountButton
                min: 1
                value: 1
                max: settings.printCopiesPerSession
                height: pixel(20)
                width: height * 3
                Layout.alignment: Qt.AlignCenter
            }

            Button {
                text: qsTr("Print")
                font.pixelSize: iconSize
                Layout.alignment: Qt.AlignCenter
                Material.accent: Material.color(Material.Cyan, Material.Shade700)
                highlighted: true
                onClicked: {
//                    console.log(printCopyCountButton.value)
//                    console.log(root.source)

                    imagePrint.printPhoto(stripFilePrefix(imageView.source), printCopyCountButton.value)
                    toast.show("Printing " + printCopyCountButton.value + " copies")
                    printPopup.close()
                }
            }



            ColumnLayout {}


        }

    }

    Column {
        spacing: 4
        anchors.fill: parent

        RowLayout {
            anchors {
                left: parent.left
                right: parent.right
            }
//            spacing: 4

            Button {
                text: "Save"
                icon.source: "qrc:/icon/save"
                icon.width: iconSize
                icon.height: iconSize
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                highlighted: true
                Material.accent: Material.color(Material.Green, Material.Shade700)
                onClicked: {
                    var canvasURL = getCanvasURL()
//                    console.log(canvasURL)
                    canvas.save(stripFilePrefix(canvasURL))
                }
            }

            Button {
                text: "Clear"
                icon.source: "qrc:/icon/clear_all"
                icon.width: iconSize
                icon.height: iconSize
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                highlighted: true
                Material.accent: Material.color(Material.Red, Material.Shade700)
                onClicked: {
                    canvas.clearRect = true

                }
            }

            Button {
                id: printButton
                text: qsTr("Print")
                icon.source: "qrc:/icon/print"
                icon.width: iconSize
                icon.height: iconSize
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                Material.accent: Material.color(Material.Cyan, Material.Shade700)
                highlighted: true
                onClicked: {
                    printCopyCountButton.value = 1
                    printPopup.open()
                }
            }

            Button {
                text: qsTr("Email")
                icon.source: "qrc:/icon/email"
                icon.width: iconSize
                icon.height: iconSize
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                Material.accent: Material.color(Material.Orange, Material.Shade700)
                highlighted: true
                onClicked: {
                    console.log("Email!")
                    emailPopup.open()
                    emailTextField.forceActiveFocus()
                }
            }

            Button {
                text: qsTr("SMS")
                icon.source: "qrc:/icon/sms"
                icon.width: iconSize
                icon.height: iconSize
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                Material.accent: Material.color(Material.Yellow, Material.Shade700)
                highlighted: true
                onClicked: {
                    console.log("SMS!")

                }
            }

            Button {
                id: closeButton
                text: "Close"
                icon.source: "qrc:/icon/close"
                icon.width: iconSize
                icon.height: iconSize
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                Material.accent: Material.color(Material.Grey, Material.Shade700)
                highlighted: true
                onClicked: {
                    canvasPopup.close()
                }
            }

        }

        Rectangle {
            id: palleteRect
            width: image.width
            height: canrect.paletteSize
            z: 1

            clip: true
            color: "black"
//            border.width: 1
//            border.color: "white"

            ListView {
                anchors.fill: parent
                id: colorPalette
                model: colorModel
                delegate: colorDelegate
                spacing: 0
                highlightFollowsCurrentItem: true
                orientation: ListView.Horizontal

                highlight: Rectangle {
                    color: "red"
                }

                highlightMoveDuration: 100


            }
        }

        Rectangle {
            id: brushRect
            z: 2
            height: canrect.paletteSize
            width: image.width

            color: "black"
//            border.width: 1
//            border.color: "white"
            clip: true

            ListView {
                id: brushPalette
                anchors.fill: parent
                model: emojisModel
                delegate: brushDelegate
                spacing: 0
                highlightFollowsCurrentItem: true
                orientation: ListView.Horizontal

                highlight: Rectangle {
                    color: "red"
                }

                highlightMoveDuration: 100
            }

        }

        Image {
            id: image
            width: parent.width
            height: width / photoAspectRatio
            fillMode: Image.PreserveAspectFit
            source: ""

            Rectangle {
                id: canrect
                anchors.fill: parent
                property int mouseX
                property int mouseY
                property int lastX
                property int lastY
                property bool pressed
                property bool released
                property bool changed
                property int paletteSize: 50
                property int emojiSize: 72
                color: "transparent"

                Canvas {
                    id: canvas
                    anchors.fill: parent

                    onImageLoaded: {
                        console.log("loaded")
                        if (canvas.lastCanvasLoaded == false) {
                            console.log("loaded", "requestPaint")
                            canvas.requestPaint()
                        }
                    }

//                    onImageDrawnChanged: {
//                        canvas.requestPaint()
//                    }

                    onClearRectChanged: {
                        canvas.requestPaint()
                    }

//                    onLastCanvasLoadedChanged: {
//                        canvas.requestPaint()
//                    }

                    property color strokeColor: "#00ffff"
                    property color shadowColor: "#4d4cff"
                    property real hue: 0.0
                    property bool rainbowColor: false
                    property int brushType: brushPalette.currentIndex
                    property string patternImage: ""
                    property bool clearRect: false
//                    property bool imageDrawn: false
                    property bool lastCanvasLoaded: false


                    function drawLine(ct) {
                        if (canrect.pressed) {
                            ct.lineWidth = 8
                            ct.lineJoin = 'round'
                            ct.lineCap = 'round'
                            ct.shadowBlur = 10
                            canrect.pressed = false
                        }

                        var lastX = canrect.lastX
                        var lastY = canrect.lastY
                        var mouseX = canrect.mouseX
                        var mouseY = canrect.mouseY

                        if (rainbowColor) {
                            ct.strokeStyle = Qt.hsla(hue, 1, 0.5, 1)
                            ct.shadowColor = Qt.hsla(hue, 1, 0.5, 0.5)
                            hue = hue < 1 ? hue + 0.01 : 0
                        }
                        else {
                            ct.strokeStyle = canvas.strokeColor
                            ct.shadowColor = canvas.shadowColor
                        }

                        ct.beginPath()
                        ct.moveTo(lastX, lastY)
                        ct.lineTo(mouseX, mouseY)
                        ct.stroke()

                        canrect.lastX = canrect.mouseX
                        canrect.lastY = canrect.mouseY
                    }

                    function drawImage(ct, img) {
                        var mouseX = canrect.mouseX
                        var mouseY = canrect.mouseY
//                        var lastX = canrect.lastX
//                        var lastY = canrect.lastY

                        var size = canrect.emojiSize
                        ct.drawImage(img, mouseX-size/2, mouseY-size/2, size, size)

                    }

                    onPaint: {
                        var ctx = getContext("2d");

                        var canvasURL = getCanvasURL()

                        if (canvas.lastCanvasLoaded == false) {
                            if (canvas.isImageLoaded(canvasURL)) {
                                ctx.drawImage(canvasURL, 0, 0, ctx.canvas.width, ctx.canvas.height)
                                console.log(canvasURL, "drawn")
                                canvas.lastCanvasLoaded = true
                                canvas.requestPaint()

                                canvas.unloadImage(canvasURL)
                                console.log(canvasURL, "unloaded")
                            }
                            else {
                                canvas.loadImage(canvasURL)
                            }
                        }


                        if (clearRect) {
                            ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height)
                            clearRect = false;
                        }
                        else {
                            if (brushType in [0, 1]) {
                                drawLine(ctx)
                            }
                            else if (brushType >= 2) {
                                if (canrect.pressed) {
                                    drawImage(ctx, patternImage)
                                    canrect.pressed = false
                                }

                            }
                        }

                    }
                    MouseArea {
                        anchors.fill: parent

                        onPressed: {
                            canrect.pressed = true;
                            canrect.lastX = mouseX;
                            canrect.lastY = mouseY;
                            canrect.mouseX = mouseX;
                            canrect.mouseY = mouseY;
                            canvas.requestPaint();
                        }


                        onPositionChanged: {
                            canrect.mouseX = mouseX;
                            canrect.mouseY = mouseY;
                            canvas.requestPaint();
                        }

                    }
                }
            }
        }
    }


}
