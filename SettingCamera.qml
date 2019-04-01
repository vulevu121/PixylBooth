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


ColumnLayout {
    id: root

    property alias liveVideoStartSwitch: liveVideoStartSwitch.checked
    property alias liveVideoCountdownSwitch: liveVideoCountdownSwitch.checked

    Settings {
        category: "Camera"
        property alias liveVideoStartSwitch: liveVideoStartSwitch.checked
        property alias liveVideoCountdownSwitch: liveVideoCountdownSwitch.checked
    }

    CustomPane {
        id: customPane
        title: "Camera"
        Layout.minimumWidth: 400
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        ColumnLayout {
            id: columnLayout
            anchors.fill: parent
            spacing: 20

            RowLayout {
                Switch {
                    id: liveVideoStartSwitch
                    text: qsTr("Show Live Video on Start")
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Switch {
                    id: liveVideoCountdownSwitch
                    text: qsTr("Show Live Video During Countdown")
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Switch {
                    id: autoTriggerSwitch
                    text: qsTr("Auto Trigger Camera")
                    Layout.fillWidth: true
                }
            }



            RowLayout {
                Switch {
                    id: mirrorLiveVideoSwitch
                    text: qsTr("Mirror Live Video")
                    Layout.fillWidth: true
                }
            }

            RowLayout {
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
                    text: qsTr("Live Video Rotation")
                }
            }


            RowLayout {
            }



        }
    }
}



/*##^## Designer {
    D{i:2;anchors_x:0;anchors_y:"-621"}
}
 ##^##*/
