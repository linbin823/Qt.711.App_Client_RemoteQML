import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

Rectangle {
    color: "black"
    RowLayout{
        anchors.fill: parent

        Button{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Button{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Button{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        Button{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
