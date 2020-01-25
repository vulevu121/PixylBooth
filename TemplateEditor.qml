import QtQuick 2.6
import QtQuick.Dialogs 1.0
import QtQuick.Window 2.12
import Qt.labs.folderlistmodel 1.0
import Qt.labs.settings 1.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12

ApplicationWindow {
    id: templateEditor
    visible: true
    color: "black"

    property int titleBarHeight: pixel(10)
    property string templateImagePath
    property string templateFormat
    property int numberPhotos
    property real iconSize: pixel(6)
    property int selectedPhotoIndex: 0
    property alias aspectRatio: templateImage.aspectRatio
    property bool infoToolbarVisible: true
    minimumWidth: 1050
    minimumHeight: 700

    Settings {
        category: "Profile"
        id: profile
        property alias templateEditorWidth: templateEditor.width
        property alias templateEditorHeight: templateEditor.height
        property alias templateEditorX: templateEditor.x
        property alias templateEditorY: templateEditor.y
        property alias templateImagePath: templateEditor.templateImagePath
        property alias templateFormat: templateEditor.templateFormat
        property alias numberPhotos: templateEditor.numberPhotos
        property alias infoToolbarX: infoToolbar.x
        property alias infoToolbarY: infoToolbar.y
    }

    function pixel(pixel) {
        return pixel * 4
    }

    function addFilePrefix(path) {
        if (path.search("file://") >= 0)
            return path

        var filePrefix = "file://"

        if (path.length > 2 && path[1] === ':')
            filePrefix += "/"

        return filePrefix.concat(path)
    }

    function get_pheight(pwidth) {
        return (pwidth / aspectRatio)
    }

    function get_ax(px) {
        return (px / templateImage.width * templateImage.sourceSize.width)
    }

    function get_ay(py) {
        return (py / templateImage.height * templateImage.sourceSize.height)
    }

    function get_acx(ax, awidth) {
        return (ax + awidth / 2)
    }

    function get_acy(ay, aheight) {
        return (ay + aheight / 2)
    }


    function get_awidth(pwidth) {
        return (pwidth / templateImage.width * templateImage.sourceSize.width)
    }

    function get_aheight(pheight) {
        return (pheight / templateImage.height * templateImage.sourceSize.height)
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["PNG files (*.png)"]

        onAccepted: {
            console.log(fileUrl)
        }
    }

    ToolBar {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        background: Rectangle {
            color: Material.background

        }

        ColumnLayout {

            ToolButton {
                text: "Open Template Image"
                icon.source: "qrc:/icons/photo"
                Layout.fillWidth: true
                display: Button.IconOnly

                ToolTip {
                    text: parent.text
                    visible: parent.hovered
                }

                onClicked: {
                    fileDialog.open()
                }
            }

            ToolButton {
                text: "Add Photo"
                icon.source: "qrc:/icons/add"
                Layout.fillWidth: true
                display: Button.IconOnly

                ToolTip {
                    text: parent.text
                    visible: parent.hovered
                }

                onClicked: {
                    var pwidth = Math.round(templateImage.width*0.5)
                    var pheight = Math.round(pwidth / aspectRatio)
                    var px = Math.round((templateImage.width - pwidth)/2)
                    var py = Math.round((templateImage.height - pheight)/2)
                    photoFrameModel.append({"px": px, "py": py, "pwidth": pwidth, "pheight": pheight, "ax": 0, "ay": 0, "awidth": 0, "aheight": 0})
                }

            }

            ToolButton {
                text: "Clear"
                icon.source: "qrc:/icons/clear-all"
                Layout.fillWidth: true
                display: Button.IconOnly

                ToolTip {
                    text: parent.text
                    visible: parent.hovered
                }

                onClicked: {
                    photoFrameModel.clear()
                }
            }


            ToolButton {
                text: "Rotate Left"
                icon.source: "qrc:/icons/rotate-left"
                Layout.fillWidth: true
                display: Button.IconOnly
                autoRepeat: true

                ToolTip {
                    text: parent.text
                    visible: parent.hovered
                    timeout: 1000
                }
                onClicked: {
                    photoFrameModel.get(selectedPhotoIndex).protation -= 5
                }

            }
            ToolButton {
                text: "Rotate Right"
                icon.source: "qrc:/icons/rotate-right"
                Layout.fillWidth: true
                display: Button.IconOnly
                autoRepeat: true

                ToolTip {
                    text: parent.text
                    visible: parent.hovered
                }

                onClicked: {
                    photoFrameModel.get(selectedPhotoIndex).protation += 5
                }

            }
            ToolButton {
                text: "Delete"
                icon.source: "qrc:/icons/delete-forever"
                Layout.fillWidth: true
                display: Button.IconOnly

                ToolTip {
                    text: parent.text
                    visible: parent.hovered
                }

                onClicked: {
                    photoFrameModel.remove(selectedPhotoIndex)
                }

            }
            ToolButton {
                text: "Increase Size"
                icon.source: "qrc:/icons/arrow-expand-all"
                Layout.fillWidth: true
                display: Button.IconOnly
                autoRepeat: true

                ToolTip {
                    text: parent.text
                    visible: parent.hovered
                }

                onClicked: {
                    photoFrameModel.get(selectedPhotoIndex).pwidth += 10
                    photoFrameModel.get(selectedPhotoIndex).pheight = get_pheight(photoFrameModel.get(selectedPhotoIndex).pwidth)
                }

            }
            ToolButton {
                text: "Decrease Size"
                icon.source: "qrc:/icons/arrow-collapse-all"
                Layout.fillWidth: true
                display: Button.IconOnly
                autoRepeat: true

                ToolTip {
                    text: parent.text
                    visible: parent.hovered
                }

                onClicked: {
                    photoFrameModel.get(selectedPhotoIndex).pwidth -= 10
                    photoFrameModel.get(selectedPhotoIndex).pheight = get_pheight(photoFrameModel.get(selectedPhotoIndex).pwidth)
                }

            }

            ToolButton {
                text: "Exit"
                icon.source: "qrc:/icons/exit-run"
                Layout.fillWidth: true
                display: Button.IconOnly

                ToolTip {
                    text: parent.text
                    visible: parent.hovered
                }

                onClicked: {
                    templateEditor.close()
                }

            }
        }
    }

    Image {
        id: templateImage
        z: 3
        opacity: 0.8
        x : 100
        y : 50

        property real aspectRatio: sourceSize.width / sourceSize.height
        source: addFilePrefix(templateImagePath)
        width: templateImage.sourceSize.height >= templateImage.sourceSize.width ? height * aspectRatio : 900
        height: templateImage.sourceSize.height >= templateImage.sourceSize.width ? 600 : width / aspectRatio
    }

    Rectangle {
        anchors.fill: templateImage
        width: templateImage.width
        height: templateImage.height
        z:2

        Repeater {
            id: repeater
            model: photoFrameModel

            Rectangle {
                id: photoFrame
                x: px
                y: py
                rotation: protation
                color: "#008000"
                width: pwidth
                height: pheight
                z: 2
                opacity: 1
                border.width: selectedPhotoIndex == index ? 12 : 4
                border.color: selectedPhotoIndex == index ? "#FF0000" : "#000000"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    drag.target: photoFrame

                    onMouseXChanged: {
                        var ax = get_ax(photoFrame.x)
                        var ay = get_ay(photoFrame.y)
                        var awidth = get_awidth(photoFrame.width)
                        var aheight = get_aheight(photoFrame.height)
                        xLabel.value = Math.round(ax)
                        yLabel.value = Math.round(ay)
                        widthLabel.value = Math.round(awidth)
                        heightLabel.value = Math.round(aheight)
                        cxLabel.value = Math.round(get_acx(ax, awidth))
                        cyLabel.value = Math.round(get_acy(ay, aheight))
//                        selectedPhotoIndex = index
                    }

                    onHeightChanged: {
                        var ax = get_ax(photoFrame.x)
                        var awidth = get_awidth(photoFrame.width)
                        widthLabel.value = Math.round(awidth)
                        cxLabel.value = Math.round(get_acx(ax, awidth))
                    }

                    onWidthChanged: {
                        var ay = get_ay(photoFrame.y)
                        var aheight = get_aheight(photoFrame.height)
                        heightLabel.value = Math.round(aheight)
                        cyLabel.value = Math.round(get_acy(ay, aheight))
                    }

                    onPressed: {
                        selectedPhotoIndex = index
                    }

                    onReleased: {
                        photoFrameModel.get(index).px = Math.round(photoFrame.x)
                        photoFrameModel.get(index).py = Math.round(photoFrame.y)

                        photoFrameModel.get(index).ax = Math.round(get_ax(photoFrame.x))
                        photoFrameModel.get(index).ay = Math.round(get_ay(photoFrame.y))
                    }
                }


                Text {
                    text: index+1
                    z: 1
                    font.pointSize: 48
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                }

                //            PinchArea {
                //                anchors.fill: parent
                //                pinch.target: photoFrame
                //                pinch.minimumRotation: 0
                //                pinch.maximumRotation: 0
                //                pinch.minimumScale: 0.1
                //                pinch.maximumScale: 10
                //                pinch.dragAxis: Pinch.XAndYAxis

                //                onPinchFinished: {
                //                    console.log(pinch.startPoint1, pinch.startPoint2)
                //                    photoFrameModel.get(index).pwidth = photoFrame.width
                //                    photoFrameModel.get(index).pheight = get_pheight(photoFrame.width)

                //                    photoFrameModel.get(index).awidth = get_awidth(photoFrameModel.get(index).pwidth)
                //                    photoFrameModel.get(index).aheight = get_aheight(photoFrameModel.get(index).pheight)

                //                }
                //            }





                //            Rectangle {
                //                anchors.fill: parent
                //                anchors.margins: 20
                //                MouseArea {
                //                    id: dragArea
                //                    hoverEnabled: true
                //                    anchors.fill: parent
                //                    drag.target: photoFrame


                //                    onWheel: {
                //                        photoFrameModel.get(index).pwidth += Math.round(photoFrameModel.get(index).pwidth * wheel.angleDelta.y / 120 / 40);
                //                        photoFrameModel.get(index).pheight = get_pheight(photoFrameModel.get(index).pwidth)

                //                        photoFrameModel.get(index).awidth = get_awidth(photoFrame.width)
                //                        photoFrameModel.get(index).aheight = get_aheight(photoFrame.height)
                //                    }

                //                    onReleased: {
                //                        photoFrameModel.get(index).px = photoFrame.x
                //                        photoFrameModel.get(index).py = photoFrame.y

                //                        photoFrameModel.get(index).ax = get_ax(photoFrame.x)
                //                        photoFrameModel.get(index).ay = get_ay(photoFrame.y)

                //                    }
                //                }
                //            }

            }
        }

    }


    Component.onCompleted: {
        if (templateFormat) {
            photoFrameModel.clear()
            var jsonModel = JSON.parse(templateFormat)
            for (var i = 0; i < jsonModel.length; ++i) {
                photoFrameModel.append(jsonModel[i])
            }
        }

//        console.log("Template loaded.")
    }

    onClosing: {
        var i = 0
        for (i = 0 ; i < photoFrameModel.count ; i++) {
            photoFrameModel.get(i).ax = Math.round(get_ax(photoFrameModel.get(i).px))
            photoFrameModel.get(i).ay = Math.round(get_ay(photoFrameModel.get(i).py))
            photoFrameModel.get(i).awidth = Math.round(get_awidth(photoFrameModel.get(i).pwidth))
            photoFrameModel.get(i).aheight = Math.round(get_aheight(photoFrameModel.get(i).pheight))
        }

        var jsonModel = []
        for (i = 0; i < photoFrameModel.count; i++) {
            jsonModel.push(photoFrameModel.get(i))
        }

        templateFormat = JSON.stringify(jsonModel)
        numberPhotos = photoFrameModel.count

//        console.log("Template saved.")
    }

    ListModel {
        id: photoFrameModel
        ListElement {
            px: 0
            py: 0
            pcx: 0
            pcy: 0
            pwidth: 300
            pheight: 200
            protation: 0
            ax: 0
            ay: 0
            acx: 0
            acy: 0
            awidth: 300
            aheight: 200

        }
        ListElement {
            px: 0
            py: 0
            pcx: 0
            pcy: 0
            pwidth: 300
            pheight: 200
            protation: 0
            ax: 0
            ay: 0
            acx: 0
            acy: 0
            awidth: 300
            aheight: 200
        }
        ListElement {
            px: 0
            py: 0
            pcx: 0
            pcy: 0
            pwidth: 300
            pheight: 200
            protation: 0
            ax: 0
            ay: 0
            acx: 0
            acy: 0
            awidth: 300
            aheight: 200
        }


    }

    ToolBar {
        id: infoToolbar
        x: 176
        y: 238
        z: 10
        width: 200
        height: infoToolbarVisible ? 200 : titleBar.height

        onHoveredChanged: {
            if (hovered) {
                opacity = 1
            }
            else {
                opacity = 0.5
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 100
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }

        background: Rectangle {
            radius: pixel(2)
            color: Material.background

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: Material.color(Material.Grey, Material.Shade700)
                }

                GradientStop {
                    position: titleBar.percent
                    color: Material.color(Material.Grey, Material.Shade900)
                }

                GradientStop {
                    position: titleBar.percent + 0.01
                    color: Material.background
                }

                GradientStop {
                    position: 1.0
                    color: Material.background
                }
            }
        }

        Button {
            id: titleBar
            height: titleBarHeight
            text: "Info                              "
            display: Button.TextBesideIcon
            icon.source: "qrc:/icons/info"
            flat: true
            highlighted: true

            property real percent: height / infoToolbar.height

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            MouseArea {
                id: dragArea
                anchors.fill: titleBar
                drag.target: infoToolbar

                onPressAndHold: {
                    infoToolbarVisible = !infoToolbarVisible
                }
            }
        }

        ColumnLayout {
            visible: infoToolbarVisible
            anchors {
                top: titleBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: pixel(2)
            }

            GridLayout {
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                Label {
                    id: xLabel
                    property real value
                    text: "X: " + value
                }
                Label {
                    id: yLabel
                    property real value
                    text: "Y: " + value
                }
                Label {
                    id: cxLabel
                    property real value
                    text: "CX: " + value
                }
                Label {
                    id: cyLabel
                    property real value
                    text: "CY: " + value
                }

                Label {
                    id: widthLabel
                    property real value
                    text: "W: " + value
                }
                Label {
                    id: heightLabel
                    property real value
                    text: "H: " + value
                }

            }

            RowLayout {}
        }

    }



}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
