import QtQuick 2.0


Rectangle{
    property bool lightState
    property color lightOffColor: Qt.darker(lightOnColor, 3.0)
    property color lightOnColor : "green"

    radius: 180
    color: lightOffColor

    onLightStateChanged: {
        if(lightState === false){
            color = lightOffColor
        }
        else{
            color = lightOnColor
        }
    }
}
