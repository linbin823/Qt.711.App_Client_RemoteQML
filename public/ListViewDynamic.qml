import QtQuick 2.7
import QtQuick.Controls 2.2

/*!
    /下拉,工具栏半拉显隐
    头部有一个指示栏
    拉出后，由用户自己定义指示栏
    头部拉出后，产生signal headerTriger(model, hideCallback() )

    /上拉更多
    底部有一个指示栏
    拉出后，拉出到一定位置，后加载下一页。且加载完成后才隐藏
    包含一个由用户自己定义指示栏
    底部拉出后，产生signal footerTriger(model, hideCallback() )

    /滚动栏
    有一个ScollBar可以快速滑动

    /数据更新脉冲
    含有一个signal updateTriger(model)
    定时产生数据更新signal，且当头部或底部拉出时停止。
*/
ListView {
    id: listRoot;
    z: 1;


    //Notice! ListViewEx控件内置model，不能再指定model
    //-------------------------------------
    // public
    //-------------------------------------
    //头部用户自己定义窗口，如搜索框等
    property var headerComponent;
    //底部用户自己定义窗口，如数量指示器等
    property var footerComponent;
    //是否吸附
    //true自定义头部要么全部显示，要么全部隐藏
    //false自定义头部可以停留在任意位置
    property bool snap          : true;
    //头部Indicator是否显示
    property bool headerIndicatorEnable : true
    //底部Indicator是否显示
    property bool footerIndicatorEnable : true
    //数据定时器发送的间隔时间（ms）
    property int updateInterv: 5000
    //初始化时的定位：first,header
    //first     初始化时以第一行数据为首
    //header    初始化时以自定义头部为首
    property string initPosition: 'first';

    //头部拉出信号，由用户实现。第一参数：模型，第二参数：隐藏头部的回调函数
    signal headerTriger(var model, var hideCallback)
    //头部手动停止信号
    signal headerStop()
    //底部拉出信号，由用户实现。第一参数：模型，第二参数：隐藏底部的回调函数
    signal footerTriger(var model, var hideCallback)
    //底部手动停止信号
    signal footerStop()
    //数据更新脉冲信号，由用户实现。第一参数：模型。
    signal updateTriger(var model)


    //-------------------------------------
    // private
    //-------------------------------------
    Item{
        id: __
        property real listHeight    : listRoot.contentHeight - listRoot.headerItem.height - listRoot.footerItem.height
        property real topPos        : -listRoot.headerItem.height
        property real topLoaderPos  : -listRoot.headerItem.loader.height
        property real firstLinePos  : 0.0
        property real lastLinePos   : listHeight - listRoot.height
        property real bottomLoaderPos:listHeight - listRoot.height + listRoot.footerItem.loader.height
        property real bottomPos     : listHeight - listRoot.height + listRoot.footerItem.height
        property bool headerShow    : false// show the head, usr program responsible for reset
        property bool footerShow    : false// show the foot, usr program responsible for reset
        property bool headerShowPulse:false// triger the headerTriger
        property bool footerShowPulse:false// triger the footerTriger

        //显示自定义头部
        function moveToHeader(){
            listRoot.contentY = topLoaderPos;
        }
        //显示第一行
        function moveToFirst(){
            listRoot.contentY = firstLinePos;
        }
        //显示最后一行
        function moveToLast(){
            //console.log("moveToLast")
            if(listHeight >= listRoot.height)
                listRoot.contentY = lastLinePos;
        }
        //显示自定义底部
        function moveToFooter(){
            //console.log("moveToFooter")
            if(listHeight >= listRoot.height)
                listRoot.contentY = bottomLoaderPos
        }
        //头部消失
        function headerHide(){
            if(headerShow){
                if (listRoot.headerIndicatorEnable){
                    listRoot.headerItem.setState('ok');
                    headerShow = false
                    updateTimer.start()
                    //console.log("headerShow = flase")
                    moveToHeader();
                }
            }
        }
        //底部消失
        function footerHide(){
            if(footerShow){
                if (listRoot.footerIndicatorEnable){
                    listRoot.footerItem.setState('ok');
                    footerShow = false
                    updateTimer.start()
                    //console.log("footerShow = flase")
                    moveToFooter();
                }
            }
        }
    }

    //-------------------------------------
    // 数据模型
    //-------------------------------------
    model: ListModel{
        function headerTriger(){
            //console.log("headerShow = true")
            if (listRoot.headerIndicatorEnable){
                listRoot.headerItem.setState('load');
                __.headerShow = true
                updateTimer.stop()
                listRoot.headerTriger(this, __.headerHide );
            }
        }
        function footerTriger(){
            //console.log("footerShow = true")
            if (listRoot.footerIndicatorEnable){
                listRoot.footerItem.setState('load');
                __.footerShow = true
                updateTimer.stop()
            }
            listRoot.footerTriger(this, __.footerHide );
        }
    }


    //------------------------------------
    // 头部刷新区域
    //-------------------------------------
    header : Column{
        width: listRoot.width
        property alias indicator:  headerIndicator
        property alias loader   :  headerLoader
        function setState(name){
            if (name === '')           {imgHead.source = './ListViewDynamic/images/arrow-down-24.png'; imgHead.playing=true; txtHeader.text=qsTr("下拉可以刷新");}
            else if (name === 'ready') {imgHead.source = './ListViewDynamic/images/arrow-up-24.png'; imgHead.playing=true;   txtHeader.text=qsTr("放开即可刷新");}
            else if (name === 'load')  {imgHead.source = './ListViewDynamic/images/loading-32.gif'; imgHead.playing=true;    txtHeader.text=qsTr("加载中");}
            else if (name === 'ok')    {imgHead.source = './ListViewDynamic/images/ok-24.png'; imgHead.playing=true;         txtHeader.text=qsTr("下拉刷新");
                                                                                                       txtDtHeader.text = qsTr("最后更新:")+getDateString();}
        }
        function getDateString(){
            return Qt.formatTime(new Date(), 'HH:mm:ss');
        }
        Component.onCompleted: {
            setState('ok')
        }
        // 下拉指示器
        // 顶部的下拉刷新字样
        Column{
            id: headerIndicator
            visible: listRoot.headerIndicatorEnable
            width: listRoot.width
            height: listRoot.height * 0.2
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                AnimatedImage {
                    id: imgHead;
                    source: ""
                    playing: true
                    visible: true
                }
                Text{
                    id: txtHeader;
                    color: "#c0c0c0"
                    text: '下拉可以刷新'
                }
            }
            Text{
                id: txtDtHeader;
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#c0c0c0"
                text: qsTr("最后更新:")
            }
        }
        // 用户自定义的头部组件（如新闻头条图片列表、工具栏）
        Loader{
            id: headerLoader
            sourceComponent: headerComponent;
        }
    }

    //-------------------------------------
    // 底部刷新区域
    //-------------------------------------
    footer: Column{

        width: parent.width
        property alias indicator:  footerIndicator
        property alias loader   :  footerLoader
        function setState(name){
            if (name === '')           {imgFoot.source = './ListViewDynamic/images/arrow-down-24.png'; imgFoot.playing=true; txtFoot.text = qsTr("上拉可以刷新");}
            else if (name === 'ready') {imgFoot.source = './ListViewDynamic/images/arrow-up-24.png'; imgFoot.playing=true;   txtFoot.text = qsTr("放开即可刷新");}
            else if (name === 'load')  {imgFoot.source = './ListViewDynamic/images/loading-32.gif'; imgFoot.playing=true;    txtFoot.text = qsTr("加载中");}
            else if (name === 'ok')    {imgFoot.source = './ListViewDynamic/images/ok-24.png'; imgFoot.playing=true;         txtFoot.text = qsTr("上拉刷新");
                                                                                                       txtDtFoot.text = qsTr("最后更新:")+getDateString();}
        }
        function getDateString(){
            return Qt.formatTime(new Date(), 'HH:mm:ss');
        }
        Component.onCompleted: {
            setState('ok')
        }
        //用户自定义的底部组件
        Loader{
            id: footerLoader
            sourceComponent: footerComponent;
        }

        // 下拉指示器
        // 顶部的下拉刷新字样
        Column{
            id: footerIndicator
            visible: listRoot.footerIndicatorEnable
            width: listRoot.width
            height: listRoot.height * 0.2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: height * 0.2
            clip: true
            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                AnimatedImage {
                    id: imgFoot;
                    source: ""
                    playing: true
                    visible: true
                }
                Text{
                    id: txtFoot;
                    color: "#c0c0c0"
                    text: '下拉可以刷新'
                }
            }
            Text{
                id: txtDtFoot;
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#c0c0c0"
                text: qsTr("Last Update:")
            }
        }
    }

    onContentYChanged: {
        // 下拉刷新判断逻辑：已经到头了，还下拉一定距离
        var dy;
        if (contentY < __.topPos){
            dy = contentY - __.topPos;
            if (dy < -10){
                if (listRoot.headerIndicatorEnable){
                    listRoot.headerItem.setState('ready');
                    __.headerShowPulse = true;
                }
            }
        }
        // 上拉加载判断逻辑：已经到底了，还上拉一定距离
        else if( contentY > __.bottomPos ){
            dy = contentY - __.bottomPos;
            if (dy > 10){
                if (listRoot.footerIndicatorEnable){
                    listRoot.footerItem.setState('ready');
                    __.footerShowPulse = true;
                }
            }
        }
    }
    //-------------------------------------
    // 下拉刷新和上拉分页逻辑
    //-------------------------------------
    onMovementEnded: {
        // 刷新数据
        if (__.headerShowPulse){
            listRoot.headerItem.setState('load');
            model.headerTriger();
            __.headerShowPulse = false
        }
        // 加载新数据
        else if (__.footerShowPulse){
            listRoot.footerItem.setState('load');
            model.footerTriger();
            __.footerShowPulse = false
        }
        else {
            var h1 = listRoot.headerItem.loader.height;
            var h2 = listRoot.footerItem.loader.height;

            //用户定义指示栏自动吸附
            if (snap){
                if (contentY >= (__.firstLinePos - h1/3) && contentY < __.firstLinePos)
                    __.moveToFirst();
                if (contentY >= (__.firstLinePos - h1) && contentY < (__.firstLinePos - h1/3) )
                    __.moveToHeader();
                if (contentY >= __.lastLinePos && contentY < (__.lastLinePos + h2/3) )
                    __.moveToLast();
                if (contentY >= (__.lastLinePos + h2/3) && contentY < (__.lastLinePos + h2) )
                    __.moveToFooter();
            }
            //刷新指示区自动显隐
            if( contentY < __.topLoaderPos ){
                __.moveToHeader();
            }
            if( contentY > __.bottomLoaderPos ){
                __.moveToFooter()
            }
            //判断是否取消headerShow或footershow
            if( __.headerShow && contentY >= __.topPos){
                listRoot.headerStop()
                if (listRoot.headerIndicatorEnable){
                    listRoot.headerItem.setState('ok');
                    __.headerShow = false
                    updateTimer.start();
                    //console.log("headerShow = flase")
                }
            }
            if( __.footerShow && contentY <= __.bottomPos){
                listRoot.footerStop()
                if (listRoot.footerIndicatorEnable){
                    listRoot.footerItem.setState('ok');
                    __.footerShow = false
                    updateTimer.start();
                    //console.log("footerShow = flase")
                }
            }
        }
    }

    // 定位到第一个元素（不显示header）
    Component.onCompleted: {
        model.headerTriger();
        updateTimer.start();
        if (initPosition=='header')
            __.moveToHeader();
        else
            __.moveToFirst();
    }

    // 动画
    Behavior on contentY{
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    // 滚动轴
    ScrollIndicator.vertical: ScrollIndicator { id: vbar; active: listRoot.moving }

    //updateTimer
    Timer{
        id: updateTimer
        interval: listRoot.updateInterv
        repeat: true
        onTriggered: {
            listRoot.updateTriger(model)
        }
        onRunningChanged: {
            console.log("updateTimer =" + running)
        }
    }

}
