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
    
    
//    function playStartVideo(path) {
//        contentLoader.source = "ContentVideo.qml"
//        contentLoader.item.mediaSource = path
//        contentLoader.item.play()
//    }

//    function playBeforeCaptureVideo() {
//        contentLoader.source = "ContentVideo.qml"
//        contentLoader.item.mediaSource = beforeCaptureVideoSource
//        contentLoader.item.play()
//    }

//    function setStartVideoSource(path) {
//        startVideoSource = path
//    }

//    function setBeforeCaptureVideoSource(path) {
//        beforeCaptureVideoSource = path
//    }

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
                    text: "Play"
                    onClicked: {
                        var model = videosPage.startVideoListModel
                        var randomIdx = Math.round(Math.random(1) * (model.count-1))
                        var randomItem = model.get(randomIdx)
                        playVideo(randomItem.filePath)
                    }
                }
                
                Button {
                    text: "Start"
                    
                    onClicked: {
                        capturePage.state = ""
                        var model = videosPage.startVideoListModel
                        var randomIdx = Math.round(Math.random(1) * (model.count-1))
                        var randomItem = model.get(randomIdx)
                        playVideo(randomItem.filePath)
                    }
                }
                
                Button {
                    text: "BeforeCapture"
                    
                    onClicked: {
                        capturePage.state = "beforecapture"
                        var model = videosPage.beforeCaptureVideoListModel
                        var randomIdx = Math.round(Math.random(1) * (model.count-1))
                        var randomItem = model.get(randomIdx)
                        playVideo(randomItem.filePath)
                    }
                }
                
                Button {
                    text: "Countdown"
                    
                    onClicked: {
                        capturePage.state = "countdown"
                        countdownTimer.start(generalView.captureTimer)
                    }
                }
                
                Button {
                    text: "Capture"
                    
                    onClicked: {
                        capturePage.state = "capture"
                    }
                }
            }
            

            states: [
                State {
                    name: "start"
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
            }
            
            
            Rectangle {
                id: captureFrame
                width: 640
                height: 480
                color: "black"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0
            }
            
            Loader {
                id: contentLoader
                anchors.fill: parent
                opacity: 1
            }

            Countdown {
                id: countdownTimer
                textColor: root.countDownColor
                opacity: 0
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
            General {
                id: generalView
                anchors.fill: parent
            }

        }
        Item {
            Camera {
                anchors.fill: parent
            }
        }
        
        Item {
            Colors {
                anchors.fill: parent

                Component.onCompleted: {
                    countDownColorSelected.connect(root.setcountDownColor)
                    bgColorSelected.connect(root.setBgColor)
                }

            }
        }
        
        
        Item {
            Videos {
                id: videosPage
                anchors.fill: parent


//                Component.onCompleted: {
//                    setStartVideoSignal.connect(root.setStartVideoSource)
//                    setBeforeCaptureVideoSignal.connect(root.setBeforeCaptureVideoSource)
//                    playStartVideoSignal.connect(root.playStartVideo)
//                    playBeforeCaptureVideoSignal.connect(root.playBeforeCaptureVideo)
//                }
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






































































