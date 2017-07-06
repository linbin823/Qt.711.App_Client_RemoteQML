import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1


Rectangle {

    property real toolsRatio: 0.5
    property string mimicTitle
    signal keyPressed(string target)
    color: "grey"

    RowLayout {
        id: pbs
        width: parent.width
        height: parent.height * toolsRatio
        anchors.top: parent.top
        anchors.left: parent.left
        spacing: 0

        Button {
            id:pbBack
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: "返回"
            onClicked: {
                keyPressed("back");
            }
        }
        Button {
            id:pbInit
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: "初始化"
            onClicked: {
                keyPressed("init");
            }
        }
        Button {
            id:pbPrevious
            Layout.fillHeight: true
            Layout.fillWidth: true
            text:"上一页"
            onClicked: {
                keyPressed("previous");
            }
        }
        Button {
            id:pbNext
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: "下一页"
            onClicked: {
                keyPressed("next");
            }
        }
    }

    Button {
        width: parent.width
        height: parent.height * ( 1 - toolsRatio )
        anchors.left : parent.left
        anchors.top : pbs.bottom
        flat: true
        Text{
            anchors.fill: parent
            text: mimicTitle
            color: "white"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: (height-80)
            clip: true
        }
        onClicked: {
            keyPressed("");
        }
    }
}
