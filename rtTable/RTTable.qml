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
    property bool canGoBack : false
    function goBack(){
        return false
    }
    //data properties,父页面写入
    property string wholeDataUrl

    /****************************************
     *数据辅助参数
     ****************************************/
    //顶部的搜索栏高度的比例
    property real controlBarRatio: 0.2
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
            width: realtimeDataTable.width
            height: realtimeDataTable.height * controlBarRatio
            color: '#f0f0f0'
            Rectangle{
                id: controlBar
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height * 0.4
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                border.color: '#d0d0d0'
                border.width: 1
                radius: height/2

                Text{
                    id: selectorId
                    height: controlBar.height * 0.8
                    text: qsTr("筛选:")
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: parent.height * 0.5
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                ComboBox{
                    id:systemSelector
                    height: controlBar.height * 0.8
                    //editable: true
                    flat: true
                    anchors.left: selectorId.right
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.verticalCenter: selectorId.verticalCenter
                    font.pixelSize: parent.height * 0.5
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
                            });
                    }
                }//end of ComboBox
            }
        }//end of control bar
    }//end of headerComponent
    //底部用户自己定义窗口，如数量指示器等
    footerComponent: Component{
        Column{
            width: realtimeDataTable.width
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
        property real unitFontSize: realtimeDataTable.height / 8 * 0.25
        mainBarContent: Rectangle {
            width : realtimeDataTable.width
            height : realtimeDataTable.height / 8
            color: "white"
            border.color: "darkgray"
            Text {
                id: tagName
                text: description
                color: "black"
                width: parent.width * 0.6
                wrapMode: Text.Wrap
                font.pixelSize: unitFontSize
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.02
            }
            Text {
                id: tagValue
                text: value
                color: "black"
                width: parent.width * 0.1
                wrapMode: Text.Wrap
                font.pixelSize: unitFontSize
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: tagName.right
                anchors.leftMargin: parent.width * 0.04
            }
            Text {
                id: unit
                text: uint
                color: "black"
                width: parent.width * 0.1
                wrapMode: Text.Wrap
                font.pixelSize: unitFontSize
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: tagValue.right
                anchors.rightMargin: parent.width * 0.02
            }
            Image {
                id: img
                source: flodableBar.isDetailShow? "../images/icons/icon-up.png" : "../images/icons/icon-down.png"
                height: parent.height * 0.20
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: unit.right
                anchors.leftMargin: parent.width * 0.02
            }
        }//end of mainBarContent
        detailBarContent: Rectangle{
            color: "grey"
            width : realtimeDataTable.width
            height : realtimeDataTable.height / 4
            border.color: "green"
            Column{
                width: parent.width * 0.6
                height: parent.height
                x:parent.width * 0.04
                y:parent.width * 0.005
                spacing: parent.width * 0.005
                Text {
                    id: tagID
                    text: "测点编号:  " + id
                    color: "black"
                    font.pixelSize: unitFontSize
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    id: tagLastUpdateTime
                    text: "最后更新:  " + lastUpdateTime
                    color: "black"
                    font.pixelSize: unitFontSize
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    id: tagDescription
                    text: "描述:  " + description
                    color: "black"
                    font.pixelSize: unitFontSize
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }//end of column

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
