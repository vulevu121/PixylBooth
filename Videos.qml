import QtQuick 2.0
//import QtQuick.Window 2.2
//import QtQuick.VirtualKeyboard 2.2
//import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
//import Qt.labs.platform 1.1
//import QtQuick.Dialogs 1.3

ColumnLayout {
    id: root
    signal playStartVideoSignal()
    signal playBeforeCaptureVideoSignal()
    signal setStartVideoSignal(string file)
    signal setBeforeCaptureVideoSignal(string file)
    signal setAfterCaptureVideoSignal(string file)
    
    property string rootFolder: "file:///home/eelab10/PixylBooth"
    
    function setStartVideoField(path) {
//        startVideoField.text = path
        startVideoListModel.append({"name": path.replace("file://", ""), "colorCode": "black"})
    }
    
    function setBeforeCaptureVideoField(path) {
//        beforeCaptureVideoField.text = path
        beforeCaptureVideoListModel.append({"name": path.replace("file://", ""), "colorCode": "black"})
    }
    
    function setAfterCaptureVideoField(path) {
        afterCaptureVideoField.text = path
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
            folder: rootFolder
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(setStartVideoSignal)
                fileSelected.connect(setStartVideoField)
            }
        }
        
        FileBrowser {
            id: beforeCaptureVideoBrowser
            folder: rootFolder
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(setBeforeCaptureVideoSignal)
                fileSelected.connect(setBeforeCaptureVideoField)
            }
        }
        
        FileBrowser {
            id: afterCaptureVideoBrowser
            folder: rootFolder
            anchors.fill: parent
            Component.onCompleted: {
                fileSelected.connect(filePopup.close)
                browserClosed.connect(filePopup.close)
                fileSelected.connect(setAfterCaptureVideoSignal)
                fileSelected.connect(setAfterCaptureVideoField)
            }
        }
    }
    
    
    Pane {
        id: pane
        width: 200
        height: 200
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Material.elevation: 4
        
        ColumnLayout {
            id: columnLayout1
            width: 100
            height: 100
            
            RowLayout {
                Button {
                    text: qsTr("Start Video")
                    onClicked: {
                        playStartVideoSignal()
                    }
                }
                
                Button {
                    text: qsTr("Before Capture Video")
                    onClicked: {
                        playBeforeCaptureVideoSignal()
                    }
                }
                
                Button {
                    text: qsTr("After Capture Video")
                    //                    onClicked: {
                    //                        listModel.append({"name": "hello", "colorCode": "red"})
                    //                    }
                }
            }
            
            GroupBox {
                id: groupBox
                width: 200
                height: 200
                Layout.minimumHeight: 200
                Layout.fillWidth: true
                title: qsTr("Start Videos")
                
                
                
                ListView {
                    id: startVideoListView
                    anchors.leftMargin: 30
                    boundsBehavior: Flickable.DragOverBounds
                    anchors.bottomMargin: 30
                    anchors.topMargin: 30
                    anchors.fill: parent
                    Layout.fillWidth: true
                    spacing: 5
                    
                    
                    delegate: Item {
                        x: 5
                        width: 80
                        height: 40
                        Row {
                            id: row1
                            spacing: 5
                            Rectangle {
                                width: 32
                                height: 32
                                color: colorCode
                            }
                            
                            Text {
                                text: name
                                anchors.verticalCenter: parent.verticalCenter
                                font.bold: true
                                color: "white"
                            }
                        }
                    }
                    
                    model: ListModel {
                        id: startVideoListModel
                    }
                }
                
                Label {
                    text: "+"
                    font.pixelSize: 36
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            startVideoBrowser.show()
                            filePopup.open()
                            
                        }
                    }
                    
                }
            }
            
            
            RowLayout {
                id: rowLayout2
                width: 100
                height: 100
                Label {
                    id: label2
                    text: qsTr("After Capture Video")
                }
                
                TextField {
                    id: afterCaptureVideoField
                    text: qsTr("")
                    Layout.fillWidth: true
                    placeholderText: "Choose after capture video..."
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            afterCaptureVideoBrowser.show()
                            filePopup.open()
                        }
                        
                    }
                }
                
            }
            
            GroupBox {
                id: beforeCaptureVideoGroupBox
                width: 200
                height: 200
                title: qsTr("Before Capture Videos")
                Layout.minimumHeight: 200
                ListView {
                    id: beforeCaptureListView
                    anchors.leftMargin: 30
                    delegate: Item {
                        x: 5
                        width: 80
                        height: 40
                        Row {
                            id: row2
                            spacing: 5
                            Rectangle {
                                width: 32
                                height: 32
                                color: colorCode
                            }

                            Text {
                                color: "#ffffff"
                                text: name
                                anchors.verticalCenter: parent.verticalCenter
                                font.bold: true
                            }
                        }
                    }
                    anchors.bottomMargin: 30
                    anchors.topMargin: 30
                    boundsBehavior: Flickable.DragOverBounds
                    anchors.fill: parent
                    spacing: 5
                    Layout.fillWidth: true
                    model: ListModel {
                        id: beforeCaptureVideoListModel
                    }
                }
                
                Label {
                    x: 0
                    y: 0
                    text: "+"
                    font.pixelSize: 36
                    MouseArea {
                        anchors.fill: parent
                        
                        onClicked: {
                            beforeCaptureVideoBrowser.show()
                            filePopup.open()
                        }
                    }
                }
                Layout.fillWidth: true
            }
            
            
            
        }
    }
    
    
}



















































































/*##^## Designer {
    D{i:12;anchors_height:160;anchors_width:110;anchors_x:"-12";anchors_y:17}D{i:11;anchors_height:160;anchors_width:110;anchors_x:"-12";anchors_y:17}
D{i:25;anchors_height:160;anchors_width:110;anchors_x:"-12";anchors_y:17}D{i:24;anchors_height:160;anchors_width:110;anchors_x:"-12";anchors_y:17}
}
 ##^##*/
