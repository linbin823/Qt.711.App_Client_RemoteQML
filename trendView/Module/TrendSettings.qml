import QtQuick 2.7

Item {
    property date  dateStart:{
        var ret = new Date()
        return ret
    }

    property date  dateSelect

    property int   updateInterv: 2
    property int   updateInterv__MS: 5000
    property int   xSpan: 0
    property int   xSpan__MS: 24 * 60 * 60 * 1000

    property int   style: 0
    property int   brushPixelSize: 0
    property int   brushPixelSize__: 10
    property color colorBackground: "black"
    property color colorTitle: "white"
    property color colorAxis: "white"
    property color colorCurrentLine: "red"

    property var   enumUpdateInterv:    ["高","中","低"]
    property var   enumXSpan:           ["1天  ","1小时","1分钟","1秒钟"]
    property var   enumStyle:           ["点  ","折线", "曲线"]
    property var   enumBrushPixelSize:  ["大","中","小"]

    onUpdateIntervChanged: {
        switch(updateInterv){
        case 0:
            updateInterv__MS = 500
            break
        case 1:
            updateInterv__MS = 1500
            break
        case 2:
            updateInterv__MS = 5000
            break
        default:
            updateInterv__MS = 5000
        }
    }
    onXSpanChanged: {
        switch(xSpan){
        case 0:
            xSpan__MS = 24 * 60 * 60 * 1000
            break
        case 1:
            xSpan__MS = 60 * 60 * 1000
            break
        case 2:
            xSpan__MS = 60 * 1000
            break
        case 3:
            xSpan__MS = 1000
            break
        default:
            xSpan__MS = 24 * 60 * 60 * 1000
        }
    }
    onBrushPixelSizeChanged: {
        switch(brushPixelSize){
        case 0:
            brushPixelSize__ = 10
            break
        case 1:
            brushPixelSize__ = 20
            break
        case 2:
            brushPixelSize__ = 50
            break
        default:
            brushPixelSize__ = 10
        }
    }


    property bool  y1Enable: false
    property int   y1DataID : -1
    property color y1Color : Qt.darker("yellow")
    property bool  y1RangeAuto : true
    property real  y1RangeMax: 100.0
    property real  y1RangeMin: 0.0
    property color y1MarkColor : Qt.darker("yellow")
    property string y1ErrorMsg : ""

    property bool  y2Enable: false
    property int   y2DataID : -1
    property color y2Color : Qt.darker("red")
    property bool  y2RangeAuto : true
    property real  y2RangeMax: 100.0
    property real  y2RangeMin: 0.0
    property color y2MarkColor : Qt.darker("red")
    property string y2ErrorMsg : ""

    property bool  y3Enable: false
    property int   y3DataID : -1
    property color y3Color : "green"
    property bool  y3RangeAuto : true
    property real  y3RangeMax: 100.0
    property real  y3RangeMin: 0.0
    property color y3MarkColor : "green"
    property string y3ErrorMsg : ""

    property bool  y4Enable: false
    property int   y4DataID : -1
    property color y4Color : Qt.darker("blue")
    property bool  y4RangeAuto : true
    property real  y4RangeMax: 100.0
    property real  y4RangeMin: 0.0
    property color y4MarkColor : Qt.darker("blue")
    property string y4ErrorMsg : ""

}
