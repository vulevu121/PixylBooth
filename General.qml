import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.3

ColumnLayout {
    id: columnLayout1
    Pane {
        id: optionsPane
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth: 600
        Material.elevation: 4
        
        
        GroupBox {
            id: optionsGroupBox
            font.pointSize: 24
            title: "Options"
            anchors.fill: parent
            
            ColumnLayout {
                id: columnLayout
                anchors.fill: parent
                spacing: 20
                
                RowLayout {
                    id: rowLayout1
                    width: 100
                    height: 100
                    
                    Label {
                        id: element
                        height: 48
                        text: qsTr("Timer between each photo")
                        Layout.minimumWidth: 300
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 24
                        
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
                        id: captureTimerEdit
                        height: 48
                        text: captureTimerSlider.value + " s"
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 24
                    }
                }
                
                RowLayout {
                    id: rowLayout2
                    width: 100
                    height: 100
                    
                    Label {
                        height: 48
                        text: qsTr("Duration to display photo")
                        Layout.minimumWidth: 300
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 24
                    }
                    
                    Slider {
                        id: displayTimerSlider
                        Layout.fillWidth: true
                        transformOrigin: Item.Left
                        value: 5
                        stepSize: 1
                        to: 20
                    }
                    
                    Label {
                        id: captureTimerEdit1
                        height: 48
                        text: displayTimerSlider.value + " s"
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 24
                    }
                }
                
                RowLayout {
                    id: rowLayout
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    spacing: 20
                    
                    Label {
                        id: label
                        text: qsTr("Directory")
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 24
                    }
                    
                    TextField {
                        id: directoryField
                        text: qsTr("")
                        font.pointSize: 12
                        Layout.fillWidth: true
                        placeholderText: "Choose a save folder..."
                    }
                    
                    
                    Button {
                        id: button
                        text: qsTr("...")
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.fillWidth: false
                        onClicked: {
                            folderDialog.open()
                        }
                        
                        FolderDialog {
                            id: folderDialog
                            title: "Please select save directory"
                            onAccepted: {
                                directoryField.text = folder
                            }
                        }
                        
                    }
                    
                    
                    
                }
                
                RowLayout {
                    id: rowLayout6
                    width: 100
                    height: 100
                    
                    Switch {
                        id: element1
                        text: qsTr("Auto Trigger Camera")
                        Layout.fillWidth: true
                    }
                }
                
                RowLayout {
                    id: rowLayout9
                    width: 100
                    height: 100
                    
                    Switch {
                        id: element6
                        text: qsTr("Live Video During Countdown")
                    }
                }
                
                RowLayout {
                    id: rowLayout3
                    width: 100
                    height: 100
                    
                    Switch {
                        id: element2
                        text: qsTr("Show Live Video on Start")
                        Layout.fillWidth: true
                    }
                }
                
                RowLayout {
                    id: rowLayout7
                    width: 100
                    height: 100
                    
                    Switch {
                        id: element3
                        text: qsTr("Mirror Live Video")
                        Layout.fillWidth: true
                    }
                }
                
                RowLayout {
                    id: rowLayout8
                    width: 100
                    height: 100
                    
                    Dial {
                        id: dial
                        value: 0
                        stepSize: 90
                        from: 0.0
                        to: 270
                        
                        Label {
                            text: Math.round(dial.value)
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    Label {
                        id: label1
                        text: qsTr("Live Video Rotation")
                    }
                }
                
                
                RowLayout {
                    id: rowLayout10
                    width: 100
                    height: 100
                }
                
                
                
            }
            
            
        }
        
        
        
    }
}
