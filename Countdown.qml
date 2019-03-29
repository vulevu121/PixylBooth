import QtQuick 2.0

Rectangle {
    id: root
    property real timer: 5
    property real count: 5
    property string textColor: "#ffffff"
    property alias countLabelShow: countLabel.visible
    color: "transparent"

//    function start(time) {
//        timer = time
//        count = time
//        countLabel.visible = true
//        captureTimer.start()
//    }

    Text {
        id: countLabel
        color: root.textColor
        text: root.count
        font.family: "Arial"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        visible: true
        opacity: 0.0
        font.pixelSize: root.height * 0.8



        Behavior on text {
            ParallelAnimation {
                NumberAnimation { target: countLabel; property: "opacity"; from: 0; to: 1; duration: 400 }
                NumberAnimation { target: countLabel; property: "scale"; from: 0; to: 1; duration: 200 }
            }
        }





    }

}



















/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
