import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.13
import QtQuick.VirtualKeyboard 2.13
import QtQuick.VirtualKeyboard.Styles 2.13
import QtQuick.VirtualKeyboard.Settings 2.13

Popup {
    id: canvasPopup
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    modal: true
    padding: pixel(2)

    property string saveFolder
    property real iconSize: pixel(20)
    property string smsFileURL: addFilePrefix(settings.saveFolder + "/SMS.txt")
    property string emailFileURL: addFilePrefix(settings.saveFolder + "/Email.txt")
    property real autoCompleteRowHeight: pixel(6)
    property real buttonRadius: pixel(2)

    Overlay.modal: Rectangle {
            color: "#64000000"
    }

    background: Rectangle {
        color: "#000000"
        opacity: 0.8
    }

    onOpened: {
        var canvasURL = getCanvasURL()
        canvas.lastCanvasLoaded = false
        canvas.loadImage(canvasURL)

        loadModelFromJson(openFile(smsFileURL), smsModel)
        loadModelFromJson(openFile(emailFileURL), emailModel)
    }

    onClosed: {
        saveCanvas()

        saveFile(smsFileURL, getJsonFromModel(smsModel))
        saveFile(emailFileURL, getJsonFromModel(emailModel))

    }

    property alias source: image.source

    function getCanvasURL() {
        var fileURL = String(image.source)
        var canvasURL = fileURL.replace(".jpg", ".png")
        return canvasURL.replace("/Prints/", "/Canvas/")
    }

    function saveCanvas() {
        var canvasURL = getCanvasURL()
        canvas.save(stripFilePrefix(canvasURL))
        console.log("[CanvasPopup]", canvasURL, "saved")
    }

    function loadModelFromJson(json, model) {
        model.clear()
        var data = JSON.parse(json)
        for (var i = 0 ; i < data.length ; i++) model.append(data[i])
    }

    function getJsonFromModel(model) {
        var data = []
        for (var i = 0 ; i < model.count ; i++) data.push(model.get(i))
        return JSON.stringify(data)
    }

    function openFile(fileUrl) {
        var request = new XMLHttpRequest();
        request.open("GET", fileUrl, false);
        request.send(null);
        return request.responseText;
    }

    function saveFile(fileUrl, text) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
        return request.status;
    }

    ListModel {
        id: smsModel
    }

    ListModel {
        id: emailModel
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
        nameFilters: ["*.png", "*.PNG"]
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
        id: emailPopup
        modal: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Overlay.modal: Rectangle {
                color: "#64000000"
        }

        background: Rectangle {
            color: "#000000"
            opacity: 0.8
        }

        onOpened: {
            emailTextField.forceActiveFocus()
        }

        onClosed: {
            emailTextField.clear()
        }

        Column {
            anchors.fill: parent

            RowLayout {
                spacing: pixel(5)
                width: parent.width

                TextField {
                    id: emailTextField
                    width: captureView.width * 0.8
                    placeholderText: "Enter your email"
                    inputMethodHints: Qt.ImhLowercaseOnly
                    focus: true
                    Layout.fillWidth: true
                    font.pixelSize: pixel(10)

                    Keys.onReturnPressed: {
                        emailSendButton.clicked()
                    }

                    onTextChanged: {
                        autoCompleteListModel.clear()

                        if (emailTextField.text.length > 2) {
                            for (var i = 0 ; i < emailModel.count ; i++) {
                                var email = String(emailModel.get(i).Email.toLowerCase())
                                var input = String(emailTextField.text.toLowerCase())
                                if (email.search(input) >= 0) {
                                    autoCompleteListModel.append({"email" : email.toLowerCase()});
                                    break;
                                }
                            }
                        }
                    }
                }


                Button {
                    id: emailSendButton
                    text: "Send"
                    focusPolicy: Qt.NoFocus
                    icon.source: "qrc:/icon/send"
                    icon.width: iconSize
                    icon.height: iconSize
                    display: AbstractButton.TextBesideIcon
                    Layout.alignment: Qt.AlignRight
                    Material.accent: Material.color(Material.Orange, Material.Shade700)
                    highlighted: true
                    onClicked: {
                        if (emailTextField.text.length > 0) {
                            var photoPath = String(image.source)
                            var inputEmail = emailTextField.text.toLowerCase()
                            emailModel.append({"PhotoPath": photoPath, "Email": inputEmail})
//                            emailTextField.clear()
                            emailPopup.close()
                        }

                    }
                }
            }


            Rectangle {
                id: autoCompleteRect
                width: parent.width
                height: autoCompleteRowHeight * 2
                color: Material.background
                clip: true


                ListModel {
                    id: autoCompleteListModel
                }

                ListView {
                    anchors.fill: parent
                    anchors.margins: pixel(3)
                    id: autoCompleteListView
                    model: autoCompleteListModel


                    delegate: Item {
                        height: autoCompleteRowHeight
                        Text {
                            text: email
                            color: Material.foreground
                            font.pixelSize: autoCompleteRowHeight

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    emailTextField.text = email
                                }
                            }
                        }
                    }
                }

            }

            InputPanel {
                width: mainWindow.width * 0.9
            }

        }


    }

    Popup {
        id: printPopup
        modal: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Overlay.modal: Rectangle {
                color: "#64000000"
        }

        background: Rectangle {
            color: "#000000"
            opacity: 0.8
        }

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.fill: parent
            spacing: pixel(6)

            ColumnLayout {}

            UpDownButton {
                id: printCopyCountButton
                min: 1
                value: 1
                text: settings.paperCutting ? value*2 : value
                max: settings.printCopiesPerSession
                height: pixel(20)
                width: height * 3
                Layout.alignment: Qt.AlignCenter
            }

            RoundButton {
                text: qsTr("Print")
                font.pixelSize: iconSize
                font.capitalization: Font.MixedCase
                Layout.alignment: Qt.AlignCenter
                radius: canvasPopup.buttonRadius
                Material.accent: Material.color(Material.Cyan, Material.Shade700)
                highlighted: true
                onClicked: {
//                    console.log(printCopyCountButton.value)
//                    console.log(root.source)
                    toast.show("Printing photo")
                    imagePrint.printPhoto(stripFilePrefix(image.source), printCopyCountButton.value, false)
                    toast.show("Printing " + printCopyCountButton.value + " copies")
                    printPopup.close()
                }
            }

            RoundButton {
                text: qsTr("Print + Paint")
                radius: canvasPopup.buttonRadius
                font.pixelSize: iconSize*0.8
                font.capitalization: Font.MixedCase
                Layout.alignment: Qt.AlignCenter
                Material.accent: Material.color(Material.Cyan, Material.Shade900)
                highlighted: true
                onClicked: {
//                    console.log(printCopyCountButton.value)
//                    console.log(root.source)
                    toast.show("Printing photo with paint")
                    imagePrint.printPhoto(stripFilePrefix(image.source), printCopyCountButton.value, true)
                    toast.show("Printing " + printCopyCountButton.value + " copies")
                    printPopup.close()
                }
            }

            ColumnLayout {}

        }

    }

    Popup {
        id: smsPopup
        modal: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Overlay.modal: Rectangle {
                color: "#64000000"
        }

        background: Rectangle {
            color: "#000000"
            opacity: 0.8
        }

        onOpened: {
            phoneNumber.forceActiveFocus()
        }

        onClosed: {
            phoneNumber.clear()
        }


        ColumnLayout {
            ComboBox {
                id: carrierCombo
                Layout.fillWidth: true
                model: ["Select your Service Carrier", "ATT", "T-Mobile", "Verizon", "Sprint", "Metro PCS", "Boost Mobile", "Cricket"]
                displayText: "Service Carrier: " + currentText
                focusPolicy: Qt.NoFocus
            }
            RowLayout {
                TextField {
                    id: phoneNumber
                    focus: true
                    placeholderText: "Phone number"
                    inputMask: "999-999-9999"
                    inputMethodHints: Qt.ImhDigitsOnly
                    font.pixelSize: pixel(10)
                    Layout.fillWidth: true
                    horizontalAlignment: TextInput.AlignHCenter

                }

                Button {
                    text: qsTr("Send SMS")
                    icon.source: "qrc:/icon/sms"
                    focusPolicy: Qt.NoFocus
                    icon.width: iconSize
                    icon.height: iconSize
                    display: AbstractButton.TextUnderIcon
                    Layout.alignment: Qt.AlignHCenter
                    Material.accent: Material.color(Material.Yellow, Material.Shade700)
                    highlighted: true
                    onClicked: {
                        var photoPath = String(image.source)
                        smsModel.append({ "PhotoPath": photoPath, "Phone": phoneNumber.text, "Carrier": carrierCombo.currentText })
    //                    console.log(getJsonFromModel(smsModel))
                        smsPopup.close()
                    }
                }
            }



            InputPanel {
                implicitWidth: mainWindow.width * 0.9
//                implicitHeight: mainWindow.height * 0.5
            }
        }
    }

    Rectangle {
        id: toolBar
        width: parent.width
        height: pixel(40)
        color: "transparent"

        anchors {
            top: parent.top
        }

        RowLayout {

            anchors {
                fill: parent
            }

            RoundButton {
                text: "Save"
                icon.source: "qrc:/icon/save"
                icon.width: iconSize
                icon.height: iconSize
                font.capitalization: Font.MixedCase
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                highlighted: true
                radius: canvasPopup.buttonRadius
                Material.accent: Material.color(Material.Green, Material.Shade700)

                onClicked: {
                    saveCanvas()
                }
            }

            RoundButton {
                text: "Clear"
                icon.source: "qrc:/icon/clear_all"
                icon.width: iconSize
                icon.height: iconSize
                font.capitalization: Font.MixedCase
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                highlighted: true
                Material.accent: Material.color(Material.Red, Material.Shade700)
                radius: canvasPopup.buttonRadius
                onClicked: {
                    canvas.clearRect = true

                }
            }

            RoundButton {
                id: printButton
                text: qsTr("Print")
                icon.source: "qrc:/icon/print"
                icon.width: iconSize
                icon.height: iconSize
                font.capitalization: Font.MixedCase
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Material.accent: Material.color(Material.Cyan, Material.Shade700)
                radius: canvasPopup.buttonRadius
                highlighted: true
                onClicked: {
                    saveCanvas()

                    printCopyCountButton.value = 1
                    printPopup.open()
                }
            }

            RoundButton {
                text: qsTr("Email")
                icon.source: "qrc:/icon/email"
                icon.width: iconSize
                icon.height: iconSize
                font.capitalization: Font.MixedCase
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Material.accent: Material.color(Material.Orange, Material.Shade700)
                radius: canvasPopup.buttonRadius
                highlighted: true
                onClicked: {
                    console.log("[CanvasPopup]", "Email button pressed")
                    emailPopup.open()
                    emailTextField.forceActiveFocus()
                }
            }

            RoundButton {
                text: qsTr("SMS")
                icon.source: "qrc:/icon/sms"
                icon.width: iconSize
                icon.height: iconSize
                font.capitalization: Font.MixedCase
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Material.accent: Material.color(Material.Yellow, Material.Shade700)
                radius: canvasPopup.buttonRadius
                highlighted: true
                onClicked: {
                    smsPopup.open()
                }
            }

            RoundButton {
                id: closeButton
                text: "Close"
                icon.source: "qrc:/icon/close"
                icon.width: iconSize
                icon.height: iconSize
                font.capitalization: Font.MixedCase
                display: AbstractButton.TextUnderIcon
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Material.accent: Material.color(Material.Grey, Material.Shade700)
                radius: canvasPopup.buttonRadius
                highlighted: true
                onClicked: {
                    canvasPopup.close()
                }
            }
        }
    }

    Rectangle {
        id: paletteRect
        width: parent.width
        height: canrect.paletteSize

        anchors {
            top: toolBar.bottom
        }

        clip: true
        color: "black"
//            border.width: 1
//            border.color: "white"

        RowLayout {
            anchors.fill: parent
            Image {
                source: "qrc:/icon/back"
                height: canrect.paletteSize
                width: height
                Layout.alignment: Qt.AlignLeft
                z: 1
            }

            ListView {
//                    anchors.fill: parent
                id: colorPalette
                model: colorModel
                delegate: colorDelegate
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                implicitHeight: canrect.paletteSize

                spacing: 0
                highlightFollowsCurrentItem: true
                orientation: ListView.Horizontal

                highlight: Rectangle {
                    color: "red"
                }

                highlightMoveDuration: 100


            }

            Image {
                source: "qrc:/icon/forward"
                height: canrect.paletteSize
                width: height
                Layout.alignment: Qt.AlignRight
                z: 1
            }
        }


    }

    Rectangle {
        id: brushRect
        height: canrect.paletteSize
        width: parent.width

        anchors {
            top: paletteRect.bottom
        }

        color: "black"
//            border.width: 1
//            border.color: "white"
        clip: true

        RowLayout {
            anchors.fill: parent
            Image {
                source: "qrc:/icon/back"
                height: canrect.paletteSize
                width: height
                Layout.alignment: Qt.AlignLeft
                z: 1
            }


            ListView {
                id: brushPalette
//                    anchors.fill: parent
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                implicitHeight: canrect.paletteSize
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

            Image {
                source: "qrc:/icon/forward"
                height: canrect.paletteSize
                width: height
                Layout.alignment: Qt.AlignRight
                z: 1
            }
        }


    }

    Image {
            id: image
//            width: parent.width
//            height: pixel(100)
            fillMode: Image.PreserveAspectFit
            source: ""

            anchors {
                left: parent.left
                right: parent.right
                top: brushRect.bottom
                bottom: parent.bottom
            }



            Rectangle {
                id: canrect
//                anchors.fill: parent
                property int mouseX
                property int mouseY
                property int lastX
                property int lastY
                property bool pressed
                property bool released
                property bool changed
                property int paletteSize: pixel(20)
                property int emojiSize: pixel(20)
                color: "transparent"
//                opacity: 0.5

                width: parent.paintedWidth
                height: parent.paintedHeight

                anchors {
                    centerIn: parent
                }

                Canvas {
                    id: canvas
                    anchors.fill: parent

                    onImageLoaded: {
                        console.log("[CanvasPopup]", "Canvas loaded")
                        if (canvas.lastCanvasLoaded == false) {
                            console.log("[CanvasPopup]", "Paint requested")
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
                        ct.save();
                        ct.shadowColor = 'transparent'
                        ct.drawImage(img, mouseX-size/2, mouseY-size/2, size, size);
                        ct.restore();
                    }

                    onPaint: {
                        var ctx = getContext("2d");

                        var canvasURL = getCanvasURL()

                        if (canvas.lastCanvasLoaded == false) {
                            if (canvas.isImageLoaded(canvasURL)) {
                                ctx.drawImage(canvasURL, 0, 0, ctx.canvas.width, ctx.canvas.height)
                                console.log("[CanvasPopup]", canvasURL, "drawn")
                                canvas.lastCanvasLoaded = true
                                canvas.requestPaint()

                                canvas.unloadImage(canvasURL)
                                console.log("[CanvasPopup]", canvasURL, "unloaded")
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
                            captureView.stopAllTimers()
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
