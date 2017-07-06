import QtQuick 2.7
import QtQuick.Controls 2.1


Popup{
    id:root
    clip: false
    property color pickedColor:"black"
    property real  sampleRectangleSize: root.width /4

    property var enumColor: [
        "black",Qt.darker("gray"),"gray",Qt.lighter("gray"),"white","silver",
        Qt.darker("red"),"red","crimson",Qt.lighter("red"),"deeppink","mediumvioletred",
        Qt.darker("orange"),"gold","goldenrod","darkorange",
        Qt.darker("yellow"),"yellow",Qt.lighter("yellow"),"lightsalmon","khaki",
        "yellowgreen",Qt.darker("green"),"forestgreen","green","lime",Qt.lighter("green"),
        Qt.darker("cyan"),"cyan",Qt.lighter("cyan"),
        Qt.darker("blue"),"blue",Qt.lighter("blue"),"steelblue","slateblue",
        "blueviolet","indigo","magenta","purple",

        //        "aliceblue","antiquewhite","aqua","aquamarine",
        //        "azure","beige","bisque","black","blanchedalmond",
        //        "blue","blueviolet","brown","burlywood","cadetblue",
        //        "chartreuse","chocolate","coral","cornflowerblue",
        //        "cornsilk","crimson","cyan","darkblue","darkcyan",
        //        "darkgoldenrod","darkgray","darkgreen","darkgrey",
        //        "darkkhaki","darkmagenta","darkolivegreen","darkorange",
        //        "darkorchid","darkred","darksalmon","darkseagreen",
        //        "darkslateblue","darkslategray","darkslategrey",
        //        "darkturquoise","darkviolet","deeppink","deepskyblue",
        //        "dimgray","dimgrey","dodgerblue","firebrick","floralwhite",
        //        "forestgreen","fuchsia","gainsboro","ghostwhite",
        //        "gold","goldenrod","gray","grey","green","greenyellow","honeydew",
        //        "hotpink","indianred","indigo","ivory","khaki","lavender",
        //        "lavenderblush","lawngreen","lemonchiffon","lightblue",
        //        "lightcoral","lightcyan","lightgoldenrodyellow","lightgray",
        //        "lightgreen","lightgrey",
    ]

    modal: true
    background: Rectangle{color:"transparent"}

    GridView{
        anchors.fill: parent
        model: enumColor
        cellHeight: sampleRectangleSize
        cellWidth: sampleRectangleSize
        delegate: Rectangle{

            border.width: 2
            border.color: "white"
            color: modelData
            width: sampleRectangleSize
            height: sampleRectangleSize
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    pickedColor = modelData
                    root.close()
                }
            }
        }
    }
}

