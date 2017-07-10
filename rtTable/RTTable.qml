import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import "../public"
import "./Module/dataSource.js" as DataFunctions

ListViewDynamic{
    id: realtimeDataTable
    anchors.fill: parent
    clip: true

    /****************************************
     *standard interface
     ****************************************/
    property int    originPixelWidth: 720
    property int    originPixelHeight: 1184
    //quick function to caculate origin pixel x or origin pixel width to actual x or actual width
    function actualX(absX){
        return realtimeDataTable.width/originPixelWidth*absX
    }
    //quick function to caculate origin pixel y or origin pixel height to actual y or actual height
    function actualY(absY){
        return realtimeDataTable.height/originPixelHeight*absY
    }
    property bool canGoBack : false
    function goBack(){
        return false
    }
    //data properties,父页面写入
    property string wholeDataUrl

    /****************************************
     *数据辅助参数
     ****************************************/
    //一页20个数据点
    property int pageSize: 20
    //已经加载的数据点数
    property int loadedSize: 0
    //最大数据量
    property int maxSize : 0
    //分系统筛选名称
    property string systemName

    /****************************************
     *ListViewDynamic 的参数
     *!Notice!ListViewEx控件内置model，不能再指定model
     ****************************************/
    //是否吸附
    //true自定义头部要么全部显示，要么全部隐藏
    //false自定义头部可以停留在任意位置
    snap: true
    //头部Indicator是否显示
    headerIndicatorEnable : false
    //底部Indicator是否显示
    footerIndicatorEnable : true
    //数据定时器发送的间隔时间（ms）
    updateInterv: 10000
    //初始化时的定位：first,header
    //first     初始化时以第一行数据为首
    //header    初始化时以自定义头部为首
    initPosition: 'first';
    //头部用户自己定义窗口，如搜索框等
    headerComponent: Component{
        //topside control bar
        Rectangle{
            width: actualX(720)
            height: actualY(100)
            color: '#e2ebed'
            Rectangle{
                id: controlBar
                anchors.left: parent.left
                anchors.right: parent.right
                height: actualY(60)
                anchors.leftMargin: actualY(10)
                anchors.rightMargin: actualY(10)
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                border.color: '#d0d0d0'
                border.width: 1
                radius: height/2

                Text{
                    id: selectorId
                    text: qsTr("筛选:")
                    anchors.left: parent.left
                    anchors.leftMargin: actualX(10)
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: actualY(26)
                    color: "#333333"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBox{
                    id:systemSelector
                    height: actualY(60)
                    //editable: true
                    flat: true
                    anchors.left: selectorId.right
                    anchors.leftMargin: actualX(10)
                    anchors.right: parent.right
                    anchors.rightMargin: actualX(5)
                    anchors.verticalCenter: selectorId.verticalCenter
                    font.pixelSize: actualY(26)
                    textRole: "text"
                    model: ListModel{
                        id:systemSelectorModel
                        dynamicRoles: true
                    }
                    Component.onCompleted: {
                        DataFunctions.subSystemsName(wholeDataUrl,
                            //process received data
                            function(res){//res is json object contains data
                                var i;
                                for(i=1; i<res.length; i++){
                                    systemSelectorModel.append(
                                        {
                                            text: res[i].class_name,
                                            number: res[i].class_pointnum,
                                            description: res[i].description
                                        })
                                }
                                realtimeDataTable.systemName = systemSelectorModel.get(0).text;
                                realtimeDataTable.maxSize =  systemSelectorModel.get(0).number;
                                realtimeDataTable.loadedSize = 0;
                            }
                        );
                    }
                    onCurrentIndexChanged: {
                        realtimeDataTable.systemName  = textAt(currentIndex);
                        realtimeDataTable.maxSize =  systemSelectorModel.get(currentIndex).number;
                        realtimeDataTable.loadedSize = 0;
                        initLoad();
                        //console.log( systemName )
                    }
                    //初始化：在筛选菜单完成后执行
                    //读取第一个页面的数据
                    function initLoad(){
                        //init the list, load the first page
                        realtimeDataTable.model.clear();
                        var count = realtimeDataTable.maxSize<realtimeDataTable.pageSize?
                                    realtimeDataTable.maxSize:realtimeDataTable.pageSize;
                        DataFunctions.loadTagInfo(wholeDataUrl, systemName, 0, count,
                            //process received data
                            function(res){//res is json object contains data
                                if( res[0].c !== realtimeDataTable.systemName || res[0].type !== "info" ||
                                        (res[0].o+res[0].n) > realtimeDataTable.maxSize){
                                    console.log("loadTagInfo received obselete data")
                                    return;
                                }
                                var appendCount=0;
                                var found = false;
                                for(var i=1; i<res.length; i++){

                                    for(var j=0; j<realtimeDataTable.model.count; j++){
                                        if(realtimeDataTable.model.get(j).id === res[i].id){
                                            found = true;
                                            break;
                                        }
                                    }
                                    if(found){
                                        //duplicated! continue
                                        continue
                                    }
                                    realtimeDataTable.model.append(
                                    {
                                        index: i,
                                        description: res[i].description,
                                        id: res[i].id,
                                        point_name: res[i].point_name,
                                        type: res[i].type,
                                        uint: res[i].uint,
                                        value: "",
                                        lastUpdateTime: ""
                                    })
                                    appendCount++;
                                }
                                realtimeDataTable.loadedSize += appendCount;
                            } );
                    }//end of function initLoad
                }//end of ComboBox
            }
        }//end of control bar
    }//end of headerComponent
    //底部用户自己定义窗口，如数量指示器等
    footerComponent: Component{
        Column{
            width: realtimeDataTable.width
            spacing: actualY(10)
            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                text:"maxSize" + realtimeDataTable.maxSize
            }
            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                text:"loadedSize" + realtimeDataTable.loadedSize
            }
        }
    }//end of footerComponent

    //行UI代理
    delegate: FoldableBar{
        id:flodableBar
        //should not restrict height or width,
        //auto generated from the size of "mainBarContent" and "detailBarContent"
        mainBarContent: Rectangle {
            width : actualX(720)
            height : actualY(100)
            color: "white"
            Text {
                id: tagName
                text: description
                color: "#333333"
                width: actualX(255)
                wrapMode: Text.Wrap
                font.pixelSize: actualY(30)
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: actualY(30)
            }
            Rectangle{
                width: 1
                height: actualY(40)
                color: "#cccccc"
                anchors.left: tagName.right
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: tagValue
                text: value
                color: "#333333"
                width: actualX(160)
                wrapMode: Text.Wrap
                font.pixelSize: actualY(30)
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: tagName.right
                anchors.leftMargin: actualY(20)
            }
            Rectangle{
                width: 1
                height: actualY(40)
                color: "#cccccc"
                anchors.left: tagValue.right
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: unit
                text: uint
                color: "#333333"
                width: actualX(80)
                wrapMode: Text.Wrap
                font.pixelSize: actualY(30)
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: tagValue.right
                anchors.leftMargin: actualY(20)
            }
            Image {
                id: img
                source: flodableBar.isDetailShow? "../images/icons/RTTableMore.png" : "../images/icons/RTTableMore_p.png"
                width: actualX(40)
                height: actualX(32)
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: unit.right
            }
            Rectangle{
                height: 1
                color: "#cccccc"
                anchors.left: tagName.left
                anchors.right: img.right
                anchors.bottom: parent.bottom
            }
        }//end of mainBarContent
        detailBarContent: Rectangle{
            width : actualX(720)
            height : actualY(200)
            color: "#003366"
            Text {
                id: tagID
                text: "测点编号:"
                color: "#ffffff"
                width: actualX(115)
                height: actualY(65)
                y:actualY(0)
                anchors.left: parent.left
                anchors.leftMargin: actualY(50)
                font.pixelSize: actualY(24)
                horizontalAlignment: Text.AlignJustify
                verticalAlignment: Text.AlignVCenter
            }
            Text{
                text: id
                color: "#ffffff"
                width: actualX(500)
                height: actualY(65)
                font.pixelSize: actualY(24)
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                anchors.left: tagID.right
                anchors.leftMargin: actualY(15)
                anchors.top: tagID.top
            }
            Text {
                id: tagLastUpdateTime
                text: "最后更新:"
                color: "#ffffff"
                width: actualX(115)
                height: actualY(70)
                y:actualY(65)
                anchors.left: parent.left
                anchors.leftMargin: actualY(50)
                font.pixelSize: actualY(24)
                horizontalAlignment: Text.AlignJustify
                verticalAlignment: Text.AlignVCenter
            }
            Text{
                text:  lastUpdateTime
                color: "#ffffff"
                width: actualX(500)
                height: actualY(70)
                font.pixelSize: actualY(24)
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                anchors.left: tagLastUpdateTime.right
                anchors.leftMargin: actualY(15)
                anchors.top: tagLastUpdateTime.top
            }
            Text {
                id: tagDescription
                text: "描述:"
                color: "#ffffff"
                width: actualX(115)
                height: actualY(65)
                y:actualY(135)
                anchors.left: parent.left
                anchors.leftMargin: actualY(50)
                font.pixelSize: actualY(24)
                horizontalAlignment: Text.Text.AlignJustify
                verticalAlignment: Text.AlignVCenter
            }
            Text{
                text:  description
                color: "#ffffff"
                width: actualX(500)
                height: actualY(65)
                font.pixelSize: actualY(24)
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                anchors.left: tagDescription.right
                anchors.leftMargin: actualY(15)
                anchors.top: tagDescription.top
            }
        }//end of detailBarContent

    }//end of delegate


    //-----------------------------------------
    // 数据事件
    //-----------------------------------------
    //底部拉出信号，由用户实现。第一参数：模型，第二参数：隐藏底部的回调函数
    //parameters: var model, var hideCallback
    onFooterTriger: {
        //parameters: serverUrl,model,subsystem,offset,number,finished
        if(loadedSize>=maxSize){
            hideCallback()
            return;
        }
        var count = (maxSize-loadedSize)<pageSize? (maxSize-loadedSize):pageSize;
        DataFunctions.loadTagInfo(wholeDataUrl,systemName,loadedSize,count,
                //process received data
                function(res){//res is json object contains data
                    if( res[0].c !== systemName || res[0].type !== "info" ||
                            (res[0].c+res[0].t+res[0].o+res[0].n) > maxSize){
                        console.log(res[0].o+res[0].n+"loadTagInfo received obselete data")
                        hideCallback()
                        return;
                    }
                    var appendCount=0;
                    var found = false;
                    for(var i=1; i<res.length; i++){

                        for(var j=0; j<model.count; j++){
                            if(model.get(j).id === res[i].id){
                                found = true;
                                break;
                            }
                        }
                        if(found){
                            //duplicated! continue
                            hideCallback()
                            continue
                        }
                        model.append(
                        {
                            index: i,
                            description: res[i].description,
                            id: res[i].id,
                            point_name: res[i].point_name,
                            type: res[i].type,
                            uint: res[i].uint,
                            value: "",
                            lastUpdateTime: ""
                        })
                        appendCount++;
                    }
                    loadedSize += appendCount;
                    hideCallback()
                });
    }
    //底部手动停止信号,停止刷新新数据
    //none parameters
    onFooterStop: {

    }
    //数据更新脉冲信号，由用户实现。第一参数：模型。
    //parameters: var model
    onUpdateTriger: {
        //serverUrl,model,subsystem,offset,number
        DataFunctions.loadTagValue(wholeDataUrl,systemName,0,loadedSize,
            function(res){
                for(var i in res){
                    for(var j=0; j<model.count; j++){
                        if(model.get(j).id === res[i].id){
                            model.setProperty(j,"value", res[i].value)
                            model.setProperty(j,"lastUpdateTime", Date() )
                        }
                    }
                }
            });
    }
}//end of ListViewEx
