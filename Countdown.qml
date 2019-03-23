import QtQuick 2.0

Text {
    id: countdownEdit
    color: textColor
    text: count
    font.family: "Tahoma"
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    font.pixelSize: textSize
    visible: false
    opacity: 0.0

    property real timer: 5
    property real count: 5
    property real maxOpacity: 0.7
    property real textSize: 400
    property string textColor: "#ffffff"

    function start(time) {
        timer = time
        count = time
        countdownEdit.visible = true
        captureTimer.start()
    }

    Behavior on text {
        ParallelAnimation {
            NumberAnimation { target: countdownEdit; property: "opacity"; from: 0; to: maxOpacity; duration: 400 }
            NumberAnimation { target: countdownEdit; property: "scale"; from: 0.5; to: 1; duration: 200 }
        }
    }
    

    Timer {
        id: captureTimer
        running: false
        repeat: true
        interval: 1000

        onTriggered: {
            if (countdownEdit.count <= 0) {
                countdownEdit.count = timer
                captureTimer.stop()
                countdownEdit.visible = false
            }
            else {
                countdownEdit.count--
            }
        }
    }

}








/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
