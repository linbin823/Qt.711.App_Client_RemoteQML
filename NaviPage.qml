import QtQuick 2.6
import QtQuick.Controls 2.1
import QtWebView 1.0
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import "./public"

StackView {
    id: naviRoot
    anchors.fill: parent
    clip:true
    background: Rectangle{
        anchors.fill: parent
        color: "#e2ebed"
    }

    /****************************************
     *standard interface
     ****************************************/
    property int    originPixelWidth: 720
    property int    originPixelHeight: 1184
    //quick function to caculate origin pixel x or origin pixel width to actual x or actual width
    function actualX(absX){
        return naviRoot.width/originPixelWidth*absX
    }
    //quick function to caculate origin pixel y or origin pixel height to actual y or actual height
    function actualY(absY){
        return naviRoot.height/originPixelHeight*absY
    }
    property bool canGoBack : depth > 1
    function goBack(){
        if(depth > 1){
            pop();
            titleChanged( qsTr("数据中心") )
        }
    }
    //data properties,父页面写入
    property string wholeDataUrl :"http://127.0.0.1:8080"
    //to tell main page to change the title
    signal titleChanged(string title);

    ListModel{
        id:contents
        ListElement{
            name:       qsTr("实时数据")
            snapShot:   "./images/snapShot/RTTable.png"
            snapShotPressed: "./images/snapShot/RTTable_p.png"
            enterance:  "./rtTable/RTTable.qml"
        }
        //"./mimic/Mimic.qml"
        //"./public/ListViewEx/example/TestListViewEx_Toolbar.qml"
        ListElement{
            name:       qsTr("MIMIC")
            snapShot:   "./images/snapShot/Mimic.png"
            snapShotPressed: "./images/snapShot/Mimic_p.png"
            enterance:  "./mimic/Mimic.qml"
        }
        ListElement{
            name:       qsTr("历史数据")
            snapShot:   "./images/snapShot/HDTable.png"
            snapShotPressed: "./images/snapShot/HDTable_p.png"
            enterance:  ""
        }
        ListElement{
            name:       qsTr("报警数据")
            snapShot:   "./images/snapShot/Alarm.png"
            snapShotPressed: "./images/snapShot/Alarm_p.png"
            enterance:  ""
        }
        ListElement{
            name:       qsTr("数据趋势")
            snapShot:   "./images/snapShot/Trend.png"
            snapShotPressed: "./images/snapShot/Trend_p.png"
            enterance:  "./trendView/TrendView.qml"
        }
    }

    initialItem: Item{
        width: naviRoot.width
        height: naviRoot.height

        GridView {
            id: naviContent
            width: parent.width * 0.8
            height: parent.height * 0.95
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            model: contents
            clip:true

            cellWidth:  width * 0.5
            cellHeight: width * 0.45
            snapMode: GridView.SnapToRow
            delegate: Rectangle{
                id:delegateRoot
                color: "transparent"
                width:  naviContent.width * 0.5
                height: naviContent.width * 0.45
                Image{
                    id: snapShotPic
                    height: delegateRoot.height * 0.8
                    width:  delegateRoot.height * 0.8
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: snapShot
                    fillMode : Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment:   Image.AlignVCenter
                }
                Text{
                    id: snapShotText
                    width: snapShotPic.width
                    height: snapShotPic.height * 0.3
                    anchors.horizontalCenter: snapShotPic.horizontalCenter
                    anchors.verticalCenter: snapShotPic.verticalCenter
                    anchors.verticalCenterOffset: snapShotPic.height * 0.35
                    font.pixelSize: height * 0.5
                    text: name
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:   Text.AlignTop
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        moduleLoader.setSource(enterance, {"wholeDataUrl" : wholeDataUrl})
                        naviRoot.push(moduleLoader)
                        titleChanged( name )
                    }
                }
            }//end of rectangle
        }//end of item
    }

    Loader {
        id: moduleLoader
        width: naviRoot.width
        height: naviRoot.height
    }
}//end of StackView
