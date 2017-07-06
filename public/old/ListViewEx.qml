import QtQuick 2.7

/*!
下拉刷新和上拉分页逻辑（用gif标志）
    /下拉刷新
    /上拉更多
    /滚动栏
    /工具栏半拉显隐

优化
    简化headerComponent写法
    下拉时图标需要调整
    loading效果无效
    自定义加载栏

BUG
    无法实现：下拉后上拉取消刷新

Author: surfsky.cnblogs.com
Lisence: MIT 请保留此声明
History:
    init. surfsky.cnblogs.com, 2015-01
    add initPosition property. 2015-01
*/
ListView {
    id: lv;
    z: 1;
    width: 320;
    height: 480;


    //-------------------------------------
    // public
    //-------------------------------------
    //一页数据的数量
    property int pageSize       : 20;
    //当前的页数
    property int currentPage    : 0;
    //最顶部的窗口，如搜索框等
    property var headerComponent;
    //是否吸附头部
    //true自定义头部要么全部显示，要么全部隐藏
    //false自定义头部可以停留在任意位置
    property bool snapHeader    : true;
    //初始化时的定位：first,header
    //first     初始化时以第一行数据为首
    //header    初始化时以自定义头部为首
    property string initPosition: 'first';

    //数据加载信号，由用户实现。第一参数：模型
    signal load(var model);
    //加载更多信号，由用户实现。第一参数：模型，第二参数：当前的页数
    signal loadMore(var model, int page);

    //Notice! ListViewEx控件内置model，不能再指定model

    //-------------------------------------
    // private
    //-------------------------------------
    property bool pressed       : false;
    property bool needReflesh   : false;
    property bool needLoadMore  : false;
    function moveToHeader(){
        contentY = -headerItem.loader.height;
    }
    function moveToFirst(){
        contentY = 0;
    }

    //-------------------------------------
    // 数据模型
    //-------------------------------------
    model: ListModel{
        function reflesh(){
            console.log('load');
            //This holds the header item created from the header component.
            if (lv.headerItem != null)
                lv.headerItem.setState('load');
            //clear();
            lv.load(this);
            lv.onModelChanged();
            moveToHeader();
            currentPage = 0;
        }
        function loadMore(){
            console.log('load more');
            currentPage++;
            lv.loadMore(this, currentPage);
            lv.onModelChanged();
        }
    }


    //-------------------------------------
    // 下拉刷新区域
    //-------------------------------------
    header : Column{
        width: parent.width
        property alias indicator:  headerIndicator
        property alias loader   :  headerLoader
        function setState(name){
            if (name === '')           {imgHead.source = './ListViewEx/images/arrow-down-24.png';       txt.text='下拉可以刷新';}
            else if (name === 'ready') {imgHead.source = './ListViewEx/images/arrow-up-24.png';   txt.text='放开即可刷新';}
            else if (name === 'load')  {imgHead.source = './ListViewEx/images/loading-32.gif';    txt.text='加载中';}
            else if (name === 'ok')    {imgHead.source = './ListViewEx/images/ok-24.png';         txt.text='下拉刷新'; txtDt.text=getDateString();}
        }
        function getDateString(){
            return Qt.formatTime(new Date(), 'HH:mm:ss');
        }

        // 下拉指示器
        // 顶部的下拉刷新字样
        Item{
            id: headerIndicator
            width: 130
            height: 30
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            AnimatedImage {
                id: imgHead; x: 7; y: 1;
                source: "../images/icons/arrow-down-24.png"
                playing: true
                visible: true
            }
            Text{
                id: txt; x: 54; y: 2
                color: "#c0c0c0"
                text: '下拉可以刷新'
            }
            Text{
                id: txtDt; x: 54; y: 18
                color: "#c0c0c0"
                text: qsTr("Last Update:")
            }
        }
        // 用户自定义的头部组件（如新闻头条图片列表、工具栏）
        Loader{
            id: headerLoader
            sourceComponent: headerComponent;
        }
    }


    //-------------------------------------
    // 下拉刷新和上拉分页逻辑
    //-------------------------------------
    onMovementEnded: {
        //console.log("movementEnded: originY:" + originY + ", contentY:" + contentY + ", reflesh:" + needReflesh + ", more:" + needLoadMore);
        // 刷新数据
        if (needReflesh){
            lv.headerItem.setState('load');
            model.reflesh();
            needReflesh = false;
        }
        // 加载新数据
        else if (needLoadMore){
            model.loadMore();
            needLoadMore = false;
        }
        else {
            var h1 = lv.headerItem.loader.height;
            var h2 = lv.headerItem.indicator.height;

            // 头部区自动显隐（拖动过小隐藏头部，反之显示）
            if (snapHeader){
                if (contentY >= -h1/3 && contentY < 0)
                    moveToFirst();
                if (contentY >= -h1 && contentY < -h1/3)
                    moveToHeader();
            }
            // 刷新区自动显隐
            if (contentY >=-(h1+h2) && contentY < -h1)
                moveToHeader();
        }
    }
    onContentYChanged: {
        // 下拉刷新判断逻辑：已经到头了，还下拉一定距离
        var dy;
        if (contentY < originY){
            dy = contentY - originY;
            if (dy < -10){
                lv.headerItem.setState('ready');
                needReflesh = true;
            }
            else {
                if (pressed){
                    //console.log(pressed);
                    //needReflesh = false;   // 如何判断当前鼠标是否按下？如果是按下状态才能取消刷新
                    lv.headerItem.setState('');
                }
            }
        }
        // 上拉加载判断逻辑：已经到底了，还上拉一定距离
        if (contentHeight>height && contentY-originY > contentHeight-height){
            dy = (contentY-originY) - (contentHeight-height);
            //console.log("y: " + contentY + ", dy: " + dy);
            if (dy > 40){
                needLoadMore = true;
                //console.log("originY:" + originY + ", contentY:" + contentY + ", height:" + height + ", contentheight:" + contentHeight);
            }
        }
    }

    // 模型修改后更改状态
    onModelChanged: {
        if (lv.headerItem != null)
            lv.headerItem.setState('ok');
    }

    // 定位到第一个元素（不显示header）
    Component.onCompleted: {
        model.reflesh();
        if (initPosition=='header')
            moveToHeader();
        else
            moveToFirst();
    }

    // 动画
    Behavior on contentY{
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    // 滚动轴
    FlickableScrollBar {
        target: lv
        orientation: Qt.Vertical
    }
}
