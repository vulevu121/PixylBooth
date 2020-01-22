import QtQuick 2.0
import Qt.labs.folderlistmodel 2.0
import QtGraphicalEffects 1.12
import QtMultimedia 5.12

Rectangle {
    id: fileBrowser
    color: "transparent"

    property string folder

    property int itemHeight: Math.min(parent.width, parent.height) / 15
    property int buttonHeight: Math.min(parent.width, parent.height) / 12
    property Playlist playlist

    signal fileSelected(string file)
    signal browserClosed()

    function selectFile(file) {
        if (file !== "") {
            folder = loader.item.folders.folder
            fileBrowser.fileSelected(file)
            playlist.addItem(file)
        }
        loader.sourceComponent = undefined
        browserClosed()
    }

    Loader {
        id: loader
    }

    function show() {
        loader.sourceComponent = fileBrowserComponent
        loader.item.parent = fileBrowser
        loader.item.anchors.fill = fileBrowser
        loader.item.folder = fileBrowser.folder
    }

    Component {
        id: fileBrowserComponent

        Rectangle {
            id: root
            color: "black"
            property bool showFocusHighlight: false
            property variant folders: folders1
            property variant view: view1
            property alias folder: folders1.folder
            property color textColor: "white"

            FolderListModel {
                id: folders1
                folder: folder
                nameFilters: [ "*.mp4", "*.avi" ]
                showDirsFirst: true
            }

            FolderListModel {
                id: folders2
                folder: folder
                nameFilters: [ "*.mp4", "*.avi" ]
                showDirsFirst: true
            }

            SystemPalette {
                id: palette
            }

            Component {
                id: folderDelegate

                Rectangle {
                    id: wrapper
                    function launch() {
                        var path = "file://";
                        if (filePath.length > 2 && filePath[1] === ':') // Windows drive logic, see QUrl::fromLocalFile()
                            path += '/';
                        path += filePath;
                        if (folders.isFolder(index))
                            down(path);
                        else
                            fileBrowser.selectFile(path)
                    }
                    width: root.width
                    height: folderImage.height
                    color: "transparent"

                    Rectangle {
                        id: highlight
                        visible: false
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        color: "#212121"
                    }

                    Item {
                        id: folderImage
                        width: itemHeight
                        height: itemHeight
                        Image {
                            id: folderPicture
                            source: folders.isFolder(index) ? "qrc:/icons/photo" : "qrc:/icons/folder"
                            width: itemHeight * 0.9
                            height: itemHeight * 0.9
                            anchors.left: parent.left
                            anchors.margins: 5
                        }


                    }

                    Text {
                        id: nameText
                        anchors.fill: parent;
                        verticalAlignment: Text.AlignVCenter
                        text: fileName
                        anchors.leftMargin: itemHeight + 10
                        color: (wrapper.ListView.isCurrentItem && root.showFocusHighlight) ? palette.highlightedText : textColor
                        elide: Text.ElideRight

                    }

                    MouseArea {
                        id: mouseRegion
                        anchors.fill: parent
                        onPressed: {
                            root.showFocusHighlight = false;
                            wrapper.ListView.view.currentIndex = index;
                        }
                        onClicked: { if (folders === wrapper.ListView.view.model) launch() }
                    }

                    states: [
                        State {
                            name: "pressed"
                            when: mouseRegion.pressed
                            PropertyChanges { target: highlight; visible: true }
                            PropertyChanges { target: nameText; color: palette.highlightedText }
                        }
                    ]
                }
            }

            ListView {
                id: view1
                anchors.top: titleBar.bottom
                anchors.bottom: cancelButton.top
                width: parent.width
                model: folders1
                delegate: folderDelegate
                highlight: Rectangle {
                    color: "#212121"
                    visible: root.showFocusHighlight && view1.count != 0
                    width: view1.currentItem == null ? 0 : view1.currentItem.width
                }
                highlightMoveVelocity: 1000
                pressDelay: 100
                focus: true
                state: "current"
                states: [
                    State {
                        name: "current"
                        PropertyChanges { target: view1; x: 0 }
                    },
                    State {
                        name: "exitLeft"
                        PropertyChanges { target: view1; x: -root.width*1.2 }
                    },
                    State {
                        name: "exitRight"
                        PropertyChanges { target: view1; x: root.width*1.2 }
                    }
                ]
                transitions: [
                    Transition {
                        to: "current"
                        SequentialAnimation {
                            NumberAnimation { properties: "x"; duration: 250 }
                        }
                    },
                    Transition {
                        NumberAnimation { properties: "x"; duration: 250 }
                        NumberAnimation { properties: "x"; duration: 250 }
                    }
                ]
                Keys.onPressed: root.keyPressed(event.key)
            }

            ListView {
                id: view2
                anchors.top: titleBar.bottom
                anchors.bottom: cancelButton.top
                x: root.width*1.2
                width: parent.width
                model: folders2
                delegate: folderDelegate
                highlight: Rectangle {
                    color: "#212121"
                    visible: root.showFocusHighlight && view2.count != 0
                    width: view1.currentItem == null ? 0 : view1.currentItem.width
                }
                highlightMoveVelocity: 1000
                pressDelay: 100
                states: [
                    State {
                        name: "current"
                        PropertyChanges { target: view2; x: 0 }
                    },
                    State {
                        name: "exitLeft"
                        PropertyChanges { target: view2; x: -root.width*1.2 }
                    },
                    State {
                        name: "exitRight"
                        PropertyChanges { target: view2; x: root.width*1.2 }
                    }
                ]
                transitions: [
                    Transition {
                        to: "current"
                        SequentialAnimation {
                            NumberAnimation { properties: "x"; duration: 250 }
                        }
                    },
                    Transition {
                        NumberAnimation { properties: "x"; duration: 250 }
                    }
                ]
                Keys.onPressed: root.keyPressed(event.key)
            }

            Rectangle {
                width: parent.width
                height: buttonHeight + 10
                anchors.bottom: parent.bottom
                color: "black"
            }

            Rectangle {
                id: cancelButton
                width: parent.width
                height: buttonHeight
                color: "#212121"
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 5
                radius: buttonHeight / 15

                Text {
                    anchors.fill: parent
                    text: "Cancel"
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        fileBrowser.selectFile("")
                    }
                }
            }

            Keys.onPressed: {
                root.keyPressed(event.key);
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Select || event.key === Qt.Key_Right) {
                    view.currentItem.launch();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left) {
                    up();
                }
            }


            Rectangle {
                id: titleBar
                width: parent.width
                height: buttonHeight + 10
                anchors.top: parent.top
                color: "black"

                Rectangle {
                    width: parent.width;
                    height: buttonHeight
                    color: "#212121"
                    anchors.margins: 5
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    radius: buttonHeight / 15

                    Rectangle {
                        id: upButton
                        width: buttonHeight
                        height: buttonHeight
                        color: "transparent"
                        Image {
                            width: itemHeight
                            height: itemHeight
                            anchors.centerIn: parent
                            source: "qrc:/icons/back"
                        }
                        MouseArea { id: upRegion; anchors.centerIn: parent
                            width: buttonHeight
                            height: buttonHeight
                            onClicked: up()
                        }
                        states: [
                            State {
                                name: "pressed"
                                when: upRegion.pressed
                                PropertyChanges { target: upButton; color: palette.highlight }
                            }
                        ]
                    }

                    Text {
                        anchors.left: upButton.right; anchors.right: parent.right; height: parent.height
                        anchors.leftMargin: 5; anchors.rightMargin: 5
                        text: folders.folder
                        color: "white"
                        elide: Text.ElideLeft;
                        horizontalAlignment: Text.AlignLeft;
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            function down(path) {
                if (folders == folders1) {
                    view = view2
                    folders = folders2;
                    view1.state = "exitLeft";
                } else {
                    view = view1
                    folders = folders1;
                    view2.state = "exitLeft";
                }
                view.x = root.width*1.2;
                view.state = "current";
                view.focus = true;
                folders.folder = path;
            }

            function up() {
                var path = folders.parentFolder;
                if (path.toString().length === 0 || path.toString() === 'file:')
                    return;
                if (folders == folders1) {
                    view = view2
                    folders = folders2;
                    view1.state = "exitRight";
                } else {
                    view = view1
                    folders = folders1;
                    view2.state = "exitRight";
                }
                view.x = -root.width*1.2;
                view.state = "current";
                view.focus = true;
                folders.folder = path;
            }

            function keyPressed(key) {
                switch (key) {
                case Qt.Key_Up:
                case Qt.Key_Down:
                case Qt.Key_Left:
                case Qt.Key_Right:
                    root.showFocusHighlight = true;
                    break;
                default:
                    // do nothing
                    break;
                }
            }
        }
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
