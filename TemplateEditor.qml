/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/
import QtQuick 2.6
import QtQuick.Dialogs 1.0
import QtQuick.Window 2.1
import Qt.labs.folderlistmodel 1.0
import Qt.labs.settings 1.1

Window {
    id: root
    visible: true
    width: 1200; height: 800
    color: "black"

    function addFilePrefix(path) {
        if (path.search("file://") >= 0)
            return path

        var filePrefix = "file://"

        if (path.length > 2 && path[1] === ':')
            filePrefix += "/"

        return filePrefix.concat(path)
    }


    Settings {
        id: settings
        category: "Template"
        property string jsonString

    }

    Settings {
        category: "Profile"
        id: profile
        property string templateImagePath
    }


    Image {
        id: templateImage
        source: addFilePrefix(profile.templateImagePath)
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectFit
        z: 10
    }

    Component.onCompleted: {
        if (settings.jsonString) {
          photoFrameModel.clear()
          var jsonModel = JSON.parse(settings.jsonString)
          for (var i = 0; i < jsonModel.length; ++i) {
              photoFrameModel.append(jsonModel[i])
          }
        }
    }

    onClosing: {
        var jsonModel = []
        for (var i = 0; i < photoFrameModel.count; i++) {
            jsonModel.push(photoFrameModel.get(i))
        }
        settings.jsonString = JSON.stringify(jsonModel)
    }

    ListModel {
        id: photoFrameModel
        ListElement {
            index: 0
            px: 0
            py: 0
            pwidth: 300
            pheight: 200
            pcolor: "red"
            ax: 0
            ay: 0
            awidth: 300
            aheight: 200
        }
        ListElement {
            index: 1
            px: 0
            py: 0
            pwidth: 300
            pheight: 200
            pcolor: "green"
            ax: 0
            ay: 0
            awidth: 300
            aheight: 200
        }
        ListElement {
            index: 2
            px: 0
            py: 0
            pwidth: 300
            pheight: 200
            pcolor: "blue"
            ax: 0
            ay: 0
            awidth: 300
            aheight: 200
        }

    }


    Repeater {
        id: repeater
        model: photoFrameModel

        Rectangle {
            id: photoFrame
            x: px
            y: py
            color: pcolor
            width: pwidth
            height: pheight

            Text {
                text: index+1
                z: 1
                font.pointSize: 24
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: "black"
            }

            PinchArea {
                anchors.fill: parent
                pinch.target: photoFrame
                pinch.minimumRotation: 0
                pinch.maximumRotation: 0
                pinch.minimumScale: 0.1
                pinch.maximumScale: 10
                pinch.dragAxis: Pinch.XAndYAxis

                onPinchFinished: {

                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 20
                MouseArea {
                    id: dragArea
                    hoverEnabled: true
                    anchors.fill: parent
                    drag.target: photoFrame


                    onWheel: {
                        photoFrameModel.get(index).pwidth += Math.round(photoFrameModel.get(index).pwidth * wheel.angleDelta.y / 120 / 40);
                        photoFrameModel.get(index).pheight = Math.round(photoFrameModel.get(index).pwidth * 2 / 3)
                        photoFrameModel.get(index).pwidth = photoFrame.width
                        photoFrameModel.get(index).pheight = photoFrame.height

                        var awidth = Math.round(photoFrameModel.get(index).pwidth / root.width * templateImage.sourceSize.width)
                        var aheight = Math.round(photoFrameModel.get(index).pheight / root.height * templateImage.sourceSize.height)

                        photoFrameModel.get(index).awidth = awidth
                        photoFrameModel.get(index).aheight = aheight
                    }

                    onReleased: {
                        photoFrameModel.get(index).px = photoFrame.x
                        photoFrameModel.get(index).py = photoFrame.y

                        var ax = Math.round(photoFrameModel.get(index).px / root.width * templateImage.sourceSize.width)
                        var ay = Math.round(photoFrameModel.get(index).py / root.height * templateImage.sourceSize.height)

                        photoFrameModel.get(index).ax = ax
                        photoFrameModel.get(index).ay = ay

                    }
                }
            }

        }
    }




}
