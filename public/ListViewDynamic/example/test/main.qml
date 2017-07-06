import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    ListViewDynamic{
        id: view
        width: parent.width
        height: parent.height - 100
        snap: true
        initPosition: 'header'
        clip:true
        headerIndicatorEnable: false
        footerIndicatorEnable: true
        // 顶部新闻图片栏
        headerComponent: Component{
            Rectangle{
                id: pv
                width: view.width
                height: 100
                clip: true
                Rectangle{width:pv.width; height:pv.height; color: 'green'}
                Rectangle{width:pv.width; height:pv.height; color: 'yellow'}
                Rectangle{width:pv.width; height:pv.height; color: 'blue'}
            }
        }
//        footerComponent: Component{
//            Rectangle{
//                id: fv
//                width: view.width
//                height: 100
//                clip: true
//                Rectangle{width:fv.width; height:fv.height; color: 'green'}
//                Rectangle{width:fv.width; height:fv.height; color: 'yellow'}
//                Rectangle{width:fv.width; height:fv.height; color: 'blue'}
//            }
//        }

        // 行UI代理
        delegate: Text {
            id: wrapper;
            width: parent.width;
            height: 32;
            font.pointSize: 15;
            verticalAlignment: Text.AlignVCenter;
            horizontalAlignment: Text.AlignHCenter;
            text: content;
            //color: ListView.view.currentIndex == index ? "white" : "#505050";
            MouseArea {
                anchors.fill: parent;
                onClicked:  wrapper.ListView.view.currentIndex = index;
            }
        }

        // 高亮
        highlight: Rectangle {
            width: parent.width
            color: "steelblue";
            opacity: 0.5
        }



        //-----------------------------------------
        // 数据加载事件
        //-----------------------------------------
        onHeaderTriger:{

        }
        onFooterTriger:{
            for (var i = 0 ; i < 20 ; ++i)
                model.append({"index": i, "content": "Item " + i})
            page = 1
            hideCallback();
        }
    }

    property int page: 1

    Grid{

        anchors.top: view.bottom
        anchors.left: parent.left
        anchors.bottom: parent.botton
        Text{
            text: "contentY: "+view.contentY
        }
        Text{
            text: "  contentHeight: "+view.contentHeight
        }
        Text{
            text: "  originY: "+view.originY
        }
        Text{
            text: "  headerHeight: "+view.headerItem.loader.height
        }
        Text{
            text: "  footerHeight: "+view.footerItem.loader.height
        }

    }

}
