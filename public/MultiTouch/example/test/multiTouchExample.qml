import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    MultiTouch{
        id: area
        anchors.fill: parent
        onUpdateChanging: {

        }
    }

//    MultiTouch{
//        id: area
//        anchors.fill: parent
//        onUpdateChanging: {
//            target.x += area.addOffsetX

//            target.y += area.addOffsetY

//            targetScale.xScale  += area.addRatio
//            targetScale.realX    = targetScale.realX - targetScale.origin.x * area.addRatio
//            targetScale.origin.x = targetScale.origin.x * ( 1 + area.addRatio )

//            targetScale.yScale  += area.addRatio
//            targetScale.realY    = targetScale.realY - targetScale.origin.y * area.addRatio
//            targetScale.origin.y = targetScale.origin.y * ( 1 + area.addRatio )
//        }
//        onOriginXChanged: {
//            targetScale.origin.x = area.originX - target.x
//        }
//        onOriginYChanged: {
//            targetScale.origin.y = area.originY - target.y
//        }
//    }

    Rectangle{
        id:target
        color:  "green"
        x: 0
        y: 0
        width:  100
        height: 100
        transformOrigin: Item.TopLeft
    }

    Rectangle{
        id :center
        x: area.originX
        y: area.originY
        radius: 90
        color: "red"
        width: 10
        height: 10
        opacity: 0.4
    }

    Column{
        anchors.fill: parent
        spacing: 20
        Text{
            text: "target.x:   " + target.x
        }
        Text{
            text: "target.y:   " + target.y
        }
        Text{
            text: "state:   " + area.state
        }
        Text{
            text: "ratio:   " + target.scale
        }
        Text{
            text: "ratio_origin_x:   " + area.originX
        }
        Text{
            text: "ratio_origin_y:   " + area.originY
        }
        Text{
            text: "offset_x:   " + area.addOffsetX
        }
        Text{
            text: "offset_y:   " + area.addOffsetY
        }
        Text{
            text: "ratio_add:   " + area.addRatio
        }
    }
}
