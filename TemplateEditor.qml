import QtQuick 2.6
import QtQuick.Dialogs 1.0
import QtQuick.Window 2.12
import Qt.labs.folderlistmodel 1.0
import Qt.labs.settings 1.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12

Window {
    id: templateEditor
    visible: true
    color: "black"

    property real photoAspectRatio: 3/2
    width: 1200
    height: width / photoAspectRatio

    minimumWidth: width
    maximumWidth: width

    maximumHeight: height
    minimumHeight: height
//    height: width / photoAspectRatio
    property real iconSize: pixel(8)

    Settings {
        category: "Profile"
        property alias templateEditorWidth: templateEditor.width
        property alias templateEditorHeight: templateEditor.height
        property alias templateEditorX: templateEditor.x
        property alias templateEditorY: templateEditor.y
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
        return Math.round(pwidth / photoAspectRatio)
    }

    function get_ax(px) {
        return Math.round(px / templateImage.width * templateImage.sourceSize.width)
    }

    function get_ay(py) {
        return Math.round(py / templateImage.height * templateImage.sourceSize.height)
    }

    function get_awidth(pwidth) {
        return Math.round(pwidth / templateImage.width * templateImage.sourceSize.width)
    }

    function get_aheight(pheight) {
        return Math.round(pheight / templateImage.height * templateImage.sourceSize.height)
    }


//    Settings {
//        id: templateSettings
//        category: "Template"
//        property string templateFormat
//        property real numberPhotos

//    }

//    Settings {
//        category: "Profile"
//        id: profileSettings
//        property string templateImagePath
//    }


    Image {
        id: templateImage
        source: addFilePrefix(root.templateImagePath)
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        z: 3
    }

    Component.onCompleted: {
        if (root.templateFormat) {
          photoFrameModel.clear()
          var jsonModel = JSON.parse(root.templateFormat)
          for (var i = 0; i < jsonModel.length; ++i) {
              photoFrameModel.append(jsonModel[i])
          }
        }

        console.log("Template loaded.")
    }

    onClosing: {

        for (var i = 0 ; i < photoFrameModel.count ; i++) {
            photoFrameModel.get(i).ax = get_ax(photoFrameModel.get(i).px)
            photoFrameModel.get(i).ay = get_ay(photoFrameModel.get(i).py)
            photoFrameModel.get(i).awidth = get_awidth(photoFrameModel.get(i).pwidth)
            photoFrameModel.get(i).aheight = get_aheight(photoFrameModel.get(i).pheight)
        }

        var jsonModel = []
        for (var i = 0; i < photoFrameModel.count; i++) {
            jsonModel.push(photoFrameModel.get(i))
        }
        root.templateFormat = JSON.stringify(jsonModel)
        root.numberPhotos = photoFrameModel.count

        console.log("Template saved.")
    }

    ListModel {
        id: photoFrameModel
        ListElement {
            px: 0
            py: 0
            pwidth: 300
            pheight: 200
            ax: 0
            ay: 0
            awidth: 300
            aheight: 200
        }
        ListElement {
            px: 0
            py: 0
            pwidth: 300
            pheight: 200
            ax: 0
            ay: 0
            awidth: 300
            aheight: 200
        }
        ListElement {
            px: 0
            py: 0
            pwidth: 300
            pheight: 200
            ax: 0
            ay: 0
            awidth: 300
            aheight: 200
        }


    }


    ColumnLayout {
        id: buttons
        anchors.fill: parent
        z: 4

        Button {
            text: "Add Photo"
            icon.source: "qrc:/Images/add_white_48dp.png"
            icon.width: iconSize
            icon.height: iconSize
            width: height

//            display: Button.IconOnly
            onClicked: {
                var pwidth = templateImage.width / 2
                var pheight = templateImage.height / 2
                var px = templateImage.width/2 - pwidth/2
                var py = templateImage.height/2 - pheight/2
                photoFrameModel.append({"px": px, "py": py, "pwidth": pwidth, "pheight": pheight, "ax": 0, "ay": 0, "awidth": 0, "aheight": 0})
            }
        }

        Button {
            text: "Close"
            icon.source: "qrc:/Images/close_white_48dp.png"
            icon.width: iconSize
            icon.height: iconSize
            width: height

            onClicked: {
                templateEditor.close()
            }
        }

        RowLayout {}
    }


    Repeater {
        id: repeater
        model: photoFrameModel

        Rectangle {
            id: photoFrame
            x: px
            y: py
            color: "#008000"
            width: pwidth
            height: pheight
            z: 2
            opacity: 1
            border.width: 3

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                drag.target: photoFrame

                onReleased: {
                    photoFrameModel.get(index).px = photoFrame.x
                    photoFrameModel.get(index).py = photoFrame.y

                    photoFrameModel.get(index).ax = get_ax(photoFrame.x)
                    photoFrameModel.get(index).ay = get_ay(photoFrame.y)
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

            ColumnLayout {
                z: 1

                Button {
                    text: "Delete"
                    display: Button.IconOnly
                    icon.source: "qrc:/Images/delete_forever_white_48dp.png"
                    icon.width: iconSize
                    icon.height: iconSize
                    flat: true

                    onClicked: {
                        photoFrameModel.remove(index)
                    }
                }

                Button {
                    text: "Scale up"
                    display: Button.IconOnly
                    icon.source: "qrc:/Images/zoom_in_white_48dp.png"
                    icon.width: iconSize
                    icon.height: iconSize
                    flat: true
                    autoRepeat: true


                    onClicked: {
                        photoFrameModel.get(index).pwidth += 10
                        photoFrameModel.get(index).pheight = get_pheight(photoFrameModel.get(index).pwidth)
                    }

                }

                Button {
                    text: "Scale down"
                    display: Button.IconOnly
                    icon.source: "qrc:/Images/zoom_out_white_48dp.png"
                    icon.width: iconSize
                    icon.height: iconSize
                    flat: true
                    autoRepeat: true


                    onClicked: {
                        photoFrameModel.get(index).pwidth -= 10
                        photoFrameModel.get(index).pheight = get_pheight(photoFrameModel.get(index).pwidth)
                    }
                }

//                Button {
//                    text: "Drag"
//                    display: Button.IconOnly
//                    icon.source: "qrc:/Images/open_with_white_48dp.png"
//                    icon.width: iconSize
//                    icon.height: iconSize
//                    flat: true

//                    MouseArea {
//                        anchors.fill: parent
//                        hoverEnabled: true
//                        drag.target: photoFrame

//                        onReleased: {
//                            photoFrameModel.get(index).px = photoFrame.x
//                            photoFrameModel.get(index).py = photoFrame.y

//                            photoFrameModel.get(index).ax = get_ax(photoFrame.x)
//                            photoFrameModel.get(index).ay = get_ay(photoFrame.y)
//                        }
//                    }
//                }

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
