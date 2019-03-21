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
    id: root
    signal bgColorSelected(string color)
    signal fgColorSelected(string color)

    Pane {
        id: colorsPane
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth: 600
        Material.elevation: 4
        
        
        GroupBox {
            font.pointSize: 24
            title: "Colors"
            anchors.fill: parent
            
            
            ColumnLayout {
                id: columnLayout3
                width: 100
                height: 100
                
                RowLayout {
                    id: rowLayout4
                    width: 100
                    height: 100
                    
                    Label {
                        id: element4
                        height: 48
                        text: qsTr("Background Color")
                        Layout.minimumWidth: 200
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 24
                    }
                    
                    Rectangle {
                        id: bgColorRectangle
                        width: 48
                        height: 48
                        color: "#000000"
                        radius: 8
                        border.color: "#999"
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                bgColorDialog.color = bgColorRectangle.color
                                bgColorDialog.open()
                            }
                            
                        }
                    }
                    
                    ColorDialog {
                        id: bgColorDialog
                        title: "Please choose a background color"
                        
                        onAccepted: {
                            bgColorRectangle.color = color
                            bgColorSelected(color)
                        }
                    }
                    
                    Label {
                        id: bgColorHex
                        height: 48
                        text: bgColorRectangle.color
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 24
                    }
                }
                
                RowLayout {
                    id: rowLayout5
                    width: 100
                    height: 100
                    
                    Label {
                        id: element5
                        height: 48
                        text: qsTr("Text Color")
                        Layout.minimumWidth: 200
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 24
                    }
                    
                    Rectangle {
                        id: fgColorRectangle
                        width: 48
                        height: 48
                        color: "#ffffff"
                        radius: 8
                        border.color: "#555555"
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                fgColorDialog.color = fgColorRectangle.color
                                fgColorDialog.open()

                            }
                            
                        }
                        
                        
                    }
                    
                    ColorDialog {
                        id: fgColorDialog
                        title: "Please choose a foreground color"
                        
                        onAccepted: {
                            fgColorRectangle.color = color
                            fgColorSelected(color)
                        }
                    }
                    
                    Label {
                        id: fgColorHex
                        height: 48
                        text: fgColorRectangle.color
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 24
                    }
                    
                    
                    
                    
                    
                }
            }
            
        }
    }
}
