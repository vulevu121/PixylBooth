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
    id: columnLayout
    Material.elevation: 4
    signal playStartVideo()
    signal playBeforeCaptureVideo()
    signal browseStartVideo()
    signal browseBeforeCaptureVideo()

    Pane {
        id: pane
        width: 200
        height: 200
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        
        ColumnLayout {
            id: columnLayout1
            width: 100
            height: 100
            
            RowLayout {
                id: rowLayout
                width: 100
                height: 100
                
                Label {
                    id: label
                    text: qsTr("Start Video")
                }
                
                TextField {
                    id: textField
                    text: qsTr("Text Field")
                }
            }
            
            RowLayout {
                Button {
                    text: qsTr("Play Start Video")
                    onClicked: {
                        playStartVideo()
                    }
                }
                
                Button {
                    text: qsTr("Play Before Capture Video")
                    onClicked: {
                        playBeforeCaptureVideo()
                    }
                }
                
                Button {
                    text: "Choose Start Video"
                    onClicked: {
                        browseStartVideo()
                    }
                }
                
                Button {
                    text: "Choose Before Capture Video"
                    onClicked: {
                        browseBeforeCaptureVideo()
                    }
                    
                }
            }
        }
    }
}
