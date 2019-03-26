import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.1
//import QtGraphicalEffects 1.12
import QtMultimedia 5.4

Window {
    id: root
    visible: true
    x: 0
    y: 0
    width: 1080
    height: 1920
    //    minimumWidth: 1080
    //    minimumHeight: 1920
    //    maximumWidth: 1080
    //    maximumHeight: 1920
    color: bgColor
    title: qsTr("PixylBooth")

    property real pixelDensity: Screen.pixelDensity
    property string bgColor: "#222"
    property string countDownColor: "#fff"

    Settings {
        property alias x: root.x
        property alias y: root.y
    }

    Settings {
        category: "Color"
        property alias backgroundColor: root.bgColor
        property alias countDownColor: root.countDownColor
    }

    function toPixels(percentage) {
        return percentage * Math.min(root.width, root.height);
    }

    function playVideo(path) {
        contentLoader.source = "ContentVideo.qml"
        contentLoader.item.mediaSource = path
        contentLoader.item.play()

    }


    function setcountDownColor(color) {
        countDownColor = color
    }

    function setBgColor(color) {
        bgColor = color
    }

    SwipeView {
        id: swipeview
        currentIndex: tabBar.currentIndex
        anchors.fill: parent

        Item {
            id: capturePage

            ColumnLayout {
                Button {
                    text: "Start"
                    onClicked: {
                        capturePage.state = "start"
                    }
                }

                Button {
                    text: "BeforeCapture"
                    onClicked: {
                        capturePage.state = "beforecapture"
                    }
                }

                Button {
                    text: "Countdown"

                    onClicked: {
                        capturePage.state = "countdown"
                    }
                }

                Button {
                    text: "Capture"

                    onClicked: {
                        capturePage.state = "capture"
                    }
                }

                Button {
                    text: "Stop Video"

                    onClicked: {
                        contentLoader.item.stop()
                    }
                }
            }


            states: [
                State {
                    name: "start"
                    PropertyChanges {
                        target: captureFrame
                        opacity: 1
                        width: 160
                        height: 120
                        y: 0
                        x: root.width - width
                    }
                    PropertyChanges {
                        target: contentLoader
                        opacity: 1
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 0
                    }
                    StateChangeScript {
                        script: {
                            var model = videosPage.startVideoListModel
                            var randomIdx = Math.round(Math.random(1) * (model.count-1))
                            var randomItem = model.get(randomIdx)
                            playVideo(randomItem.filePath)
                        }
                    }
                },

                State {
                    name: "beforecapture"
                    PropertyChanges {
                        target: captureFrame
                        opacity: 0
                    }
                    PropertyChanges {
                        target: contentLoader
                        opacity: 1
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 0
                    }
                    StateChangeScript {
                        script: {
                            capturePage.state = "beforecapture"
                            var model = videosPage.beforeCaptureVideoListModel
                            var randomIdx = Math.round(Math.random(1) * (model.count-1))
                            var randomItem = model.get(randomIdx)
                            playVideo(randomItem.filePath)
                        }
                    }
                },

                State {
                    name: "countdown"
                    PropertyChanges {
                        target: captureFrame
                        opacity: 1
                    }
                    PropertyChanges {
                        target: contentLoader
                        opacity: 0
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 1
                    }
                    StateChangeScript {
                        script: {
                            capturePage.state = "countdown"
                            countdownTimer.start(generalView.captureTimer)
                            contentLoader.item.stop()
                        }
                    }
                },

                State {
                    name: "capture"
                    PropertyChanges {
                        target: captureFrame
                        opacity: 1
                    }
                    PropertyChanges {
                        target: contentLoader
                        opacity: 0
                    }
                    PropertyChanges {
                        target: countdownTimer
                        opacity: 0
                    }

                }
            ]

            transitions: Transition {
                NumberAnimation {
                    properties: "opacity"
                    duration: 200
                }
                NumberAnimation {
                    properties: "scale"
                    duration: 200
                }
                NumberAnimation {
                    properties: "x"
                    duration: 100
                }
                NumberAnimation {
                    properties: "y"
                    duration: 100
                }
                
                NumberAnimation {
                    properties: "width"
                    duration: 100
                }
                NumberAnimation {
                    properties: "height"
                    duration: 100
                }
            }
            
            CaptureFrame {
                id: captureFrame
                width: 640
                height: 480
                x: (root.width - width) / 2
                y: 50
                opacity: 0
                z: 2
            }
            
            Loader {
                id: contentLoader
                anchors.fill: parent
                opacity: 1
            }

            Countdown {
                id: countdownTimer
                anchors.fill: captureFrame
                textColor: root.countDownColor
                opacity: 0
                z: 5
            }


            Rectangle {
                id: rectangle
                width: 400
                height: 400
                color: "transparent"
                border.color: "#ffffff"
                border.width: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        countdownTimer.start(generalView.captureTimer)
                    }
                }
            }



        }
        Item {
            SettingGeneral {
                id: generalView
                anchors.fill: parent
            }

        }
        Item {
            SettingCamera {
                id: cameraView
                anchors.fill: parent
            }
        }

        Item {
            SettingColor {
                id: colorsView
                anchors.fill: parent

                Component.onCompleted: {
                    countDownColorSelected.connect(root.setcountDownColor)
                    bgColorSelected.connect(root.setBgColor)
                }
            }
        }


        Item {
            SettingVideo {
                id: videosPage
                anchors.fill: parent
            }
        }

    }


    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: root.height
        width: root.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: root.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    TabBar {
        id: tabBar
        x: 864
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        currentIndex: swipeview.currentIndex
        Material.elevation: 1

        TabButton {
            text: "Capture"
            width: implicitWidth
        }


        TabButton {
            text: "General"
            width: implicitWidth
        }


        TabButton {
            text: "Camera"
            width: implicitWidth
        }

        TabButton {
            text: "Color"
            width: implicitWidth
        }


        TabButton {
            text: "Videos"
            width: implicitWidth
        }


    }

}






































































