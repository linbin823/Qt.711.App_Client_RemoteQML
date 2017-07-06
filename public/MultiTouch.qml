import QtQuick 2.7
/*!
 * 多点触摸区域
 *
 * 本身是一个不可见的控件，支持以下功能：
 *  1、单点单击。
 *  手指单击后发出clicked信号（释放事件），查询p1可以得到单击的发生位置。
 *
 *  2、单点拖动
 *	手指按下后发出pressed信号，释放后发出released信号。在两个信号之间，
 *  就是拖动状态。此时变量state等于enumStates.moving。查询p1可以得到当前手指的位置。
 *
 *	拖动位移发生后，发出updateChanging信号。同时变量addOffsetX和addOffsetY给出单次
 *  变化的offset。
 *
 *	本控件每次只输出变化值，实际的位置（初始值+变化值的积分）由外部界面收到后再进行运算和
 *  处理。外部界面必须要实现一个onUpdateChanging：{}的处理过程。
 *
 *  3、单点双击放大
 *	手指连续按下两次，发出doubleClicked信号（释放事件），查询p1可以得到最后一次点击的位置。
 *  此时变量state等于enumStates.doubleTapRatioing。
 *
 *	实际上，两次点击必有误差。程序设计为两次点击在一定误差范围内就可以认为是同一个点双击。
 *  可以设置变量__.threshold来改变这个误差范围。
 *
 *	单击会有抖动（Jitter）效应。为了防止单击的抖动被误认为双击事件，双击延时必须大于一定时间，
 *  否则不被认为是双击。可以设置变量tapJitterFilter.interval来改变这个延时时间。
 *
 *	双击间隔时间不能大于一定时间，否则也不被认为是双击。可以设置变量tapDelay.interval来改
 *  变这个延时时间。
 *
 *  双击后，自动进入放大过程。自动放大过程不会被打断。放大过程的时间长短可以设置变量
 *  doubleTapRatioingTimer.interval。放大的比例可以设置变量doubleTapRatio。
 *
 *	缩放过程发生后，发出updateChanging信号。同时变量addRatio给出缩放的比例，originX和originY
 *  给出单次放大的原点。
 *
 *	本控件每次只输出变化值，实际的比例 （初始值 *  变化值）由外部界面收到后再进行运算和处理。
 *  外部界面必须要实现一个onUpdateChanging：{}的处理过程。
 *
 *  4、双点的缩放
 *  缩放过程发生后，发出updateChanging信号。同时变量addRatio给出缩放的比例，originX和
 *  originY给出单次放大的原点。放大的原点基于两根手指连线的中点。
 *
 *  本控件每次只输出变化值，实际的比例 （初始值 *  变化值）由外部界面收到后再进行运算和处理。
 *  外部界面必须要实现一个onUpdateChanging：{}的处理过程。
 *
 *  Author: Richard Lin 13918814219@163.com
 *  Lisence: LGPL 请保留此声明
 */
MultiPointTouchArea {
    id: root
    //public
    //区域单手指单击，发出该信号。第二根手指不发信号
    signal clicked
    //区域单手指按下，发出该信号。第二根手指不发信号
    signal pressed
    //区域单手指放开，发出该信号。第二根手指不发信号
    signal released
    //区域双击，发出该信号。第二根手指不发信号
    signal doubleClicked

    /*!
     * 比例/位置更新信号
     * 外部程序收到该信号后，更新一次被移动物体的位置和缩放比例
     * 注意：缩放的时候，还要使用缩放参考点：originX，originY
     */
    signal updateChanging
    //(只读输出参数)增加的比例（默认为1.0，即不增加也不减小）
    property real addRatio: 1.0
    //(只读输出参数)增加的位移X（默认为0，即不移动）
    property real addOffsetX: 0
    //(只读输出参数)增加的位移Y（默认为0，即不移动）
    property real addOffsetY: 0
    //(只读输出参数)缩放时的参考点（即缩放时该点完全不动）的X坐标
    property real originX
    //(只读输出参数)缩放时的参考点（即缩放时该点完全不动）的Y坐标
    property real originY

    //(只读输出参数)区域状态，参见enumStates定义
    property int  state
    property var  enumStates : {"stop":0, "moving":1, "ratioing":2, "doubleTapRatioing":3}

    //(只读输出参数)第一个按下点和第二个按下点（如果有）
    property alias p1: point1
    property alias p2: point2

    //(可写输入参数)双击后放大的比例
    property real doubleTapRatio: 2.0


    //private
    Item{
        id: __
        property real lastXPos
        property real lastYPos
        property real lastDistance

        property real ratioAddStep

        property real firstTapX
        property real firstTapY
        property real threshold
    }

    Component.onCompleted:{
        state = enumStates.stop
        __.threshold = 10//(root.width + root.height ) / 20
    }

    touchPoints:[
        TouchPoint{id:point1},
        TouchPoint{id:point2}
    ]


    onTouchUpdated:{
        switch(touchPoints.length){
        case 0:
            //exit ratioing
            //exit moving
            if( state === enumStates.moving ){
                released();
                clicked();
                state = enumStates.stop;
            }else if ( state === enumStates.ratioing ){
                released();
                state = enumStates.stop;
            }
            break
        case 1:
            if(state === enumStates.ratioing){
                //exit ratioing
                state = enumStates.stop
            }
            else if(state === enumStates.moving){
                //continue moving
                addOffsetX = p1.x - __.lastXPos
                addOffsetY = p1.y - __.lastYPos
                addRatio = 1.0
                __.lastXPos = p1.x
                __.lastYPos = p1.y
                updateChanging()
            }
            else if(state === enumStates.stop){
                //start doubleTapRatioing
                if(tapDelay.running && !tapJitterFilter.running &&
                        ( (Math.abs(point1.x - __.firstTapX) + Math.abs(point1.y - __.firstTapY)) < __.threshold ) )
                {
                    state = enumStates.doubleTapRatioing
                    originX = point1.x
                    originY = point1.y
                    __.ratioAddStep = Math.pow( doubleTapRatio, 1/25)
                    zoomInWorker.start()
                    doubleTapRatioingTimer.start()
                    return
                }
                //start tap delay
                __.firstTapX = point1.x
                __.firstTapY = point1.y
                tapDelay.start()
                tapJitterFilter.start()
                //start moving
                __.lastXPos = p1.x
                __.lastYPos = p1.y
                addOffsetX = 0
                addOffsetY = 0
                addRatio = 1.0
                state = enumStates.moving

                pressed();
            }
            break
        case 2:
            var distance = dist()
            if(state === enumStates.ratioing){
                //continue ratioing
                addRatio = distance / __.lastDistance
                __.lastDistance = distance
                addOffsetX = 0
                addOffsetY = 0
                updateChanging()
            }
            else{
                //start ratioing
                if( distance <= __.threshold)
                    return
                __.lastDistance =  distance
                originX = ( point1.x + point2.x ) / 2
                originY = ( point1.y + point2.y ) / 2
                state = enumStates.ratioing
                addOffsetX = 0
                addOffsetY = 0
                addRatio = 1.0
                updateChanging()
            }
            break
        }
    }

    function dist(){
        return Math.sqrt(Math.pow( (point1.x - point2.x),2) + Math.pow( (point1.y - point2.y), 2) )
    }

    Timer{
        id: tapDelay
        interval: 800
        repeat: false
    }
    Timer{
        id: tapJitterFilter
        interval: 200
        repeat: false
    }

    Timer{
        id: doubleTapRatioingTimer
        interval: 500
        repeat: false
        onTriggered:  {
            //exit doubleTapRatioing
            state = enumStates.stop
            zoomInWorker.stop()
        }
    }
    Timer{
        id: zoomInWorker
        interval: 20
        repeat: true
        onTriggered: {
            //continue doubleTapRatioing
            addRatio = __.ratioAddStep
            addOffsetX = 0
            addOffsetY = 0
            updateChanging()
        }
    }
}
