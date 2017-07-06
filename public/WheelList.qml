import QtQuick 2.7
  
Rectangle {  
    property alias currentIndex: list.currentIndex
    property alias model: list.model
    property bool bZeroFlags: false
    property bool bTextFlags: true
    property int currentItemFontSize: 35
    property int otherItemFontSize: 24
    property int selectItemNumber: 3
    property color currentItemTextColor:"black"
    property color otherItemTextColor:  "grey"
    property string unitString: ""

    function setCurrentIndex(index){
        if( index < 0 || index > ( model.length -1 ) ) return
        list.currentIndex = index
    }
  
    color:  "transparent"
    border.color: "white"
    clip: true

    Rectangle{  
        id: wheelList
        anchors.fill: parent
        color: "transparent"
        clip: true
  
        ListView {  
            id: list
            anchors.fill: parent
            clip: true
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: height / 3
            preferredHighlightEnd: height / 3

            delegate:Rectangle {  
                id: modelRect
                color: "transparent"
                width: list.width
                height: ListView.isCurrentItem ? list.height / selectItemNumber : list.height / (selectItemNumber + 1)
                Text {  
                    id: modelText
                    anchors.centerIn: parent
                    color: modelRect.ListView.isCurrentItem ? currentItemTextColor : otherItemTextColor
                    font.pixelSize: modelRect.ListView.isCurrentItem ? currentItemFontSize : otherItemFontSize
                    text:{
                        if(bTextFlags){
                            return model.modelData
                        }else{  
                            if(bZeroFlags){  
                                return (index + unitString)
                            }else {  
                                return ((index + 1) + unitString)
                            }  
                        }  
                    }  
                }  
                MouseArea {  
                    anchors.fill: parent
                    onClicked: {  
                        setCurrentIndex(index)
                    }  
                }  
            }  
        }  
    }  
}  
