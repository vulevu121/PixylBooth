import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3

Window {
    id: root
    visible: true
    width: 1080
    height: 1920
    color: bgColor

    property string bgColor: "#222"
    property string fgColor: "#999"
    property string startVideoSource
    property string beforeCaptureVideoSource

    function toPixels(percentage) {
        return percentage * Math.min(root.width, root.height);
    }

    function browseStartVideo() {
        startVideoBrowser.show()
        filePopup.open()
    }

    function browseBeforeCaptureVideo() {
        beforeCaptureVideoBrowser.show()
        filePopup.open()
    }

    function playStartVideo() {
        contentLoader.source = "ContentVideo.qml"
        contentLoader.item.mediaSource = startVideoSource
        contentLoader.item.play()
    }

    function playBeforeCaptureVideo() {
        contentLoader.source = "ContentVideo.qml"
        contentLoader.item.mediaSource = beforeCaptureVideoSource
        contentLoader.item.play()
    }

    function setStartVideoSource(path) {
        startVideoSource = path
    }

    function setBeforeCaptureVideoSource(path) {
        beforeCaptureVideoSource = path
    }

    function setFgColor(color) {
        fgColor = color
    }

    function setBgColor(color) {
        bgColor = color
    }

    title: qsTr("PixylBooth")
    property real pixelDensity: Screen.pixelDensity
    Material.theme: Material.Dark
    Material.accent: Material.Blue

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
            folder: qsTr("file:///c:/Users/Vu/Documents/Photobooth/Videos")
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(root.setStartVideoSource)
            }
        }

        FileBrowser {
            id: beforeCaptureVideoBrowser
            folder: qsTr("file:///c:/Users/Vu/Documents/Photobooth/Videos")
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(root.setBeforeCaptureVideoSource)
            }
        }
    }



    SwipeView {
        id: swipeview
        currentIndex: tabBar.currentIndex
        anchors.fill: parent


        Item {
            id: firstPage

            Loader {
                id: contentLoader
                anchors.fill: parent
            }

            Countdown {
                id: countdownTimer
                textColor: fgColor
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
                        countdownTimer.start(5)
                    }


                }
            }


        }
        Item {
            id: secondPage

            General {
                id: general
                anchors.fill: parent
            }

        }
        Item {
            id: thirdPage

            Colors {
                id: colors
                anchors.fill: parent

                Component.onCompleted: {
                    fgColorSelected.connect(root.setFgColor)
                    bgColorSelected.connect(root.setBgColor)
                }

            }
        }

        Item {
            id: fourthPage

            Videos {
                id: videos
                anchors.fill: parent

                Component.onCompleted: {
                    browseStartVideo.connect(root.browseStartVideo)
                    browseBeforeCaptureVideo.connect(root.browseBeforeCaptureVideo)
                    playStartVideo.connect(root.playStartVideo)
                    playBeforeCaptureVideo.connect(root.playBeforeCaptureVideo)
                }
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
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        currentIndex: swipeview.currentIndex

        TabButton {
            text: "Capture"
            width: implicitWidth
        }

        TabButton {
            text: "General"
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






































































