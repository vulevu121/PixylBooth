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
            title: "Camera"
            anchors.fill: parent
            
            ColumnLayout {
                id: columnLayout
                anchors.fill: parent
                spacing: 20
                
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
