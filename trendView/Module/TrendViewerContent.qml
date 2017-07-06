import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import "../../public"

Canvas {
    id: root

    property real contentX : width * 0.05
    property real contentY : height * 0.05
    property real contentWidth : width * 0.8
    property real contentHeight : height * 0.8
    property var  trendSettings: null
    onTrendSettingsChanged: {
        if(!trendSettings) return
        configInit()
        checkForAutoUpdate.interval = trendSettings.updateInterv
        checkForAutoUpdate.restart()
    }


    function configInit(){
        var nowDate = new Date()
        var now = nowDate.getTime()
        __.dateStop__MS = Math.min((trendSettings.dateStart.getTime() + trendSettings.xSpan__MS), now )
        __.dateStart__MS = __.dateStop__MS - trendSettings.xSpan__MS
        __.xRatio = 1.0

        __.y1Max = Math.max(trendSettings.y1RangeMax, trendSettings.y1RangeMin)
        __.y1Min = trendSettings.y1RangeMin
        __.y1Ratio = 1.0
    }

    Item{
        //private
        id:__
        property int  gridSize: 4
        property real gridStep: gridSize ? (width - root.tickMargin) / gridSize : root.xGridStep
        property int  pixelSkip: 1
        property int  numPoints: 1
        property int  tickMargin: 34
        property real xGridStep: (width - tickMargin) / numPoints
        property real yGridOffset: height / 26

        property real minorTickLen: 8

        property bool autoUpdate: false//when time is close to currentTime

        property var  y1trendModel
        property var  y2trendModel
        property var  y3trendModel
        property var  y4trendModel

        property real dateStart__MS :-1  //ms int
        property real dateStop__MS  :-1  //ms int
        property real dateMinStart_MS:-1 //ms int
        property real xRatio : 1.0

        property real y1Max
        property real y1Min
        property real y1Ratio : 1.0
        property real y2Max
        property real y2Min
        property real y3Max
        property real y3Min
        property real y4Max
        property real y4Min

        property real labelOffset: 40
        property string fontPixelSize : "44px"
        property string fontFamily    : " sans-serif"//  not support android!! Open Sans   Verdana

        function updateAxisXConfig(addOffsetX,addRatio,originX){
            //update axis X's offset
            //init dateStop__MS & dateStart__MS
            if(dateStart__MS < 0 || isNaN(dateStart__MS) ){
                root.configInit()
            }
            var nowDate = new Date()
            var now = nowDate.getTime()
            var oldSpan = trendSettings.xSpan__MS * xRatio
            //caculate offset
            var addOffsetTime = addOffsetX / root.contentWidth * oldSpan
            if( dateMinStart_MS )
            dateStop__MS = Math.min( (dateStop__MS - addOffsetTime) , now )
            dateStart__MS = dateStop__MS - oldSpan
            //caculate ratio
            if(addRatio !== 1.0 && addRatio !==0.0){
                xRatio /= addRatio
                var newSpan = trendSettings.xSpan__MS * xRatio
                var originTime = originX / root.contentWidth * oldSpan + dateStart__MS
                dateStop__MS = Math.min( (originTime + (dateStop__MS - originTime) / addRatio), now )
                dateStart__MS = dateStop__MS - newSpan
            }
            //judge whether auto update enable
            var nowDiff = now - dateStop__MS
            if(nowDiff <= 1000){
                autoUpdate = true
            }
            else{
                autoUpdate = false
            }
            root.requestPaint()
        }

        function updateAxisYConfig(addOffsetY,addRatio,originY){
            //init y1Max & y1Min
            if(isNaN(y1Max) || y1Max< y1Min){
                root.configInit()
            }
            //whether auto is enabled
            if( trendSettings.y1RangeAuto ){

            }

            var y1OldSpan = y1Max - y1Min
            //caculate offset
            var addOffsetValue = addOffsetY / root.contentHeight * y1OldSpan
            y1Max = y1Max + addOffsetValue
            y1Min = y1Max - y1OldSpan
            //caculate ratio
            if(addRatio !== 1.0 && addRatio !==0.0){
                y1Ratio /= addRatio
                var y1NewSpan = y1OldSpan / addRatio
                var originValue = y1Max - originY / root.contentHeight * y1OldSpan
                y1Max = originValue + (y1Max - originValue) / addRatio
                y1Min = y1Max - y1NewSpan
            }
            root.requestPaint()
        }

        function drawCurrentDate(x){

        }

        Timer{
            id: checkForAutoUpdate
            running: true
            interval: 5000
            repeat: true
            onTriggered: {
                __.autoUpdateProcess()
            }
        }

        function autoUpdateProcess(){
            if(!autoUpdate) return
            var nowDate
            nowDate = new Date()
            var now = nowDate.getTime()
            var offset__MS = now - dateStop__MS
            if(dateStop__MS !== dateStart__MS){
                var offset = offset__MS / (dateStop__MS - dateStart__MS) * root.contentWidth
                __.updateAxisXConfig(-offset,1.0,0)
            }
        }


    }

    TrendSettings{id:settings}
    //using 3 areas, for X-axis scale, Y-axis scale and current Date
    //selection respectively.
    MultiTouch{
        id: multiTouchX
        x: 0
        y: contentHeight
        width: contentWidth
        height: root.height - contentHeight
        onUpdateChanging: {
            __.updateAxisXConfig(addOffsetX,addRatio,originX)
        }
    }
    MultiTouch{
        id: multiTouchY
        x: contentWidth
        y: 0
        width: root.width - contentWidth
        height: contentHeight
        onUpdateChanging: {
            __.updateAxisYConfig(addOffsetY,addRatio,originY)
        }
    }
    MultiTouch{
        id: centerMultiTouch
        x: 0
        y: 0
        width: contentWidth
        height: contentHeight
        onUpdateChanging: {
            __.updateAxisXConfig(addOffsetX,1.0,0)
            __.updateAxisYConfig(addOffsetY,1.0,0)
        }
        onClicked: {
            __.drawCurrentDate(p1)
        }
    }
    Column{
        id:debug
        x:0
        y:0
        width: contentWidth
        height: contentHeight
        Text{
            color: "white"
            text: __.y1Max
        }
        Text{
            color: "white"
            text:__.y1Min
        }
        Text{
            color: "white"
            text: __.y1Ratio
        }
    }


    Connections{
        target: trendSettings
        onXSpan__MSChanged:{
            //  改变密度: 1.清空所有曲线缓存 2.初始化y轴移动 3.重算密度并查询 4.重新绘图
            dataSource.clearAllHistoryTags()
            root.configInit()
        }
        onDateStartChanged:{
            root.configInit()
        }

        onUpdateInterv__MSChanged:{
            checkForAutoUpdate.interval = trendSettings.updateInterv__MS
            checkForAutoUpdate.restart()
        }
    }



    function drawBackground(ctx){
        ctx.save();
        ctx.fillStyle = trendSettings.colorBackground
        ctx.fillRect(0, 0, root.width, root.height);//绘制“被填充”的矩形
        // vertical grid lines
        var verticalPos
        var label, subLabel
        var i__Date = new Date()
        var timeSpan = __.xRatio * trendSettings.xSpan__MS
        //绘制x轴
        ctx.strokeStyle = trendSettings.colorAxis
        ctx.beginPath();
        ctx.moveTo(0, root.contentHeight)
        ctx.lineTo(root.contentWidth, root.contentHeight)
        ctx.closePath()
        ctx.stroke()
        if( timeSpan >= 24*60*60*1000){
            //more than one day: 6hour/MajorTick & grid line, 1hour/MinorTick
            var start__Hr = Math.ceil( __.dateStart__MS / (60*60*1000) )
            var stop__Hr =  Math.floor( __.dateStop__MS / (60*60*1000) )
            for(var i = start__Hr; i <= stop__Hr; i++){
                //绘制刻度和垂直辅助线
                i__Date.setTime(i*60*60*1000)
                ctx.strokeStyle = trendSettings.colorAxis
                ctx.beginPath();
                verticalPos = (i*60*60*1000 - __.dateStart__MS ) / timeSpan * root.contentWidth
                ctx.moveTo(verticalPos, root.contentHeight - __.minorTickLen)
                ctx.lineTo(verticalPos, root.contentHeight)
                if(i__Date.getHours() % 6 === 0){
                    ctx.moveTo(verticalPos, 0 )
                    ctx.lineTo(verticalPos, root.contentHeight)
                }
                ctx.closePath()
                ctx.stroke()
                //绘制数值标签
                if(i__Date.getHours() % 6 === 0){
                    label = i__Date.getHours() + "时"
                    ctx.fillStyle = trendSettings.colorTitle
                    ctx.font = __.fontPixelSize + __.fontFamily
                    ctx.textAlign =  "center"
                    ctx.beginPath()
                    ctx.fillText(label, verticalPos,root.contentHeight + __.labelOffset)
                    if( i__Date.getHours() === 0){
                        subLabel = i__Date.getFullYear()+ "年" + (i__Date.getMonth()+1) + "月" + i__Date.getDate() + "日"
                        ctx.fillText(subLabel, verticalPos,root.contentHeight + 3 * __.labelOffset)
                    }
                    ctx.closePath()
                    ctx.stroke()
                }
            }
        }else if( timeSpan >= 60*60*1000 ){
            //more than one hour: 30min/MajorTick & grid line, 1min/MinorTick
            var start__Min = Math.ceil( __.dateStart__MS / (60*1000) )
            var stop__Min =  Math.floor( __.dateStop__MS / (60*1000) )
            for(i = start__Min; i <= stop__Min; i++){
                //绘制刻度和垂直辅助线
                i__Date.setTime(i*60*1000)
                if(i__Date.getMinutes() % 5 === 0){
                    ctx.strokeStyle = trendSettings.colorAxis
                    ctx.beginPath();
                    verticalPos = (i*60*1000 - __.dateStart__MS ) / timeSpan * root.contentWidth
                    ctx.moveTo(verticalPos, root.contentHeight - __.minorTickLen)
                    ctx.lineTo(verticalPos, root.contentHeight)
                    if(i__Date.getMinutes() % 30 === 0){
                        ctx.moveTo(verticalPos, 0 )
                        ctx.lineTo(verticalPos, root.contentHeight)
                    }
                    ctx.closePath()
                    ctx.stroke()
                }
                //绘制数值标签
                if(i__Date.getMinutes() === 0){
                    label = i__Date.getHours() + "时"
                    ctx.fillStyle = trendSettings.colorTitle
                    ctx.font = __.fontPixelSize + __.fontFamily
                    ctx.textAlign =  "center"
                    ctx.beginPath()
                    ctx.fillText(label, verticalPos,root.contentHeight + __.labelOffset)
                    if( i__Date.getHours() === 0){
                        subLabel = i__Date.getFullYear()+ "年" + (i__Date.getMonth()+1) + "月" + i__Date.getDate() + "日"
                        ctx.fillText(subLabel, verticalPos,root.contentHeight + 3 * __.labelOffset)
                    }
                    ctx.closePath()
                    ctx.stroke()
                }
            }
        }else if( timeSpan >= 60*1000 ){
            //more than one minute: 60sec/MajorTick & grid line, 10sec/MinorTick
            var start__Sec = Math.ceil( __.dateStart__MS / 1000 )
            var stop__Sec =  Math.floor( __.dateStop__MS / 1000 )
            for(i = start__Sec; i <= stop__Sec; i++){
                //绘制刻度和垂直辅助线
                i__Date.setTime(i*1000)
                if(i__Date.getSeconds() % 10 === 0){
                    ctx.strokeStyle = trendSettings.colorAxis
                    ctx.beginPath();
                    verticalPos = (i*1000 - __.dateStart__MS ) / timeSpan * root.contentWidth
                    ctx.moveTo(verticalPos, root.contentHeight - __.minorTickLen)
                    ctx.lineTo(verticalPos, root.contentHeight)
                    if(i__Date.getSeconds() === 0){
                        ctx.moveTo(verticalPos, 0 )
                        ctx.lineTo(verticalPos, root.contentHeight)
                    }
                    ctx.closePath()
                    ctx.stroke()
                }
                //绘制数值标签
                if(i__Date.getSeconds() === 0 && i__Date.getMinutes() % 5 === 0){
                    label = + i__Date.getMinutes() + "分"
                    ctx.fillStyle = trendSettings.colorTitle
                    ctx.font = __.fontPixelSize + __.fontFamily
                    ctx.textAlign =  "center"
                    ctx.beginPath()
                    ctx.fillText(label, verticalPos,root.contentHeight + __.labelOffset)
                    if( i__Date.getMinutes() === 0 ){
                        subLabel = i__Date.getFullYear()+ "年" + (i__Date.getMonth()+1) + "月" + i__Date.getDate() + "日" + i__Date.getHours() + "时"
                        ctx.fillText(subLabel, verticalPos,root.contentHeight + 3 * __.labelOffset)
                    }
                    ctx.closePath()
                    ctx.stroke()
                }
            }
        }else{
                //less than one minute: 10sec/MajorTick & grid line, 1sec/MinorTick, label on every 5sec
                start__Sec = Math.ceil( __.dateStart__MS / 1000 )
                stop__Sec =  Math.floor( __.dateStop__MS / 1000 )
                for(i = start__Sec; i <= stop__Sec; i++){
                    //绘制刻度和垂直辅助线
                    i__Date.setTime(i*1000)
                    ctx.strokeStyle = trendSettings.colorAxis
                    ctx.beginPath();
                    verticalPos = (i*1000 - __.dateStart__MS ) / timeSpan * root.contentWidth
                    ctx.moveTo(verticalPos, root.contentHeight - __.minorTickLen)
                    ctx.lineTo(verticalPos, root.contentHeight)
                    if(i__Date.getSeconds() % 10 === 0){
                        ctx.moveTo(verticalPos, 0 )
                        ctx.lineTo(verticalPos, root.contentHeight)
                    }
                    ctx.closePath()
                    ctx.stroke()
                    //绘制数值标签
                    if(i__Date.getSeconds() % 5 ===0 ){
                        label = + i__Date.getSeconds() + "秒"
                        ctx.fillStyle = trendSettings.colorTitle
                        ctx.font = __.fontPixelSize + __.fontFamily
                        ctx.textAlign =  "center"
                        ctx.beginPath()
                        ctx.fillText(label, verticalPos,root.contentHeight + __.labelOffset)
                        if( i__Date.getSeconds() === 0 ){
                            subLabel = i__Date.getFullYear()+ "年" + (i__Date.getMonth()+1) + "月" + i__Date.getDate() + "日" + i__Date.getHours() + "时" + i__Date.getSeconds() + "分"
                            ctx.fillText(subLabel, verticalPos,root.contentHeight + 3 * __.labelOffset)
                        }
                        ctx.closePath()
                        ctx.stroke()
                    }
                }
            }
        //绘制y轴
        ctx.strokeStyle = trendSettings.colorAxis
        ctx.beginPath();
        ctx.moveTo(root.contentWidth, 0)
        ctx.lineTo(root.contentWidth, root.contentHeight)
        ctx.closePath()
        ctx.stroke()
        // horizontal grid lines
        var y1Diff = __.y1Max - __.y1Min
        if(y1Diff === 0){
            y1Diff = 0.00001
        }
        var horizontalPos
        //转换为科学计数
        var y1Power = 1.0
        while( y1Diff * y1Power < 1.0 || y1Diff * y1Power >= 10.0){
            if( y1Diff * y1Power < 1.0 ){
                y1Power *= 10.0
            }else{
                y1Power /= 10.0
            }
        }
        var y1GridMax = Math.floor( __.y1Max * y1Power * 10.0 )
        var y1GridMin = Math.ceil(__.y1Min * y1Power * 10.0 )
        for( i = y1GridMin; i <= y1GridMax; i++ ){
            //绘制刻度和水平辅助线
            ctx.strokeStyle = trendSettings.colorAxis
            ctx.beginPath();
            horizontalPos = ( __.y1Max - i / y1Power /10 ) / y1Diff * root.contentHeight
            ctx.moveTo(root.contentWidth - __.minorTickLen, horizontalPos)
            ctx.lineTo(root.contentWidth, horizontalPos)
            if(i % 10 === 0){
                ctx.moveTo(0, horizontalPos )
                ctx.lineTo(root.contentWidth, horizontalPos)
            }
            ctx.closePath()
            ctx.stroke()
            //绘制数值标签
            if(i % 10 === 0){
                label = i / 10
                ctx.fillStyle = trendSettings.y1MarkColor
                ctx.font = __.fontPixelSize + __.fontFamily
                ctx.textAlign =  "left"
                ctx.beginPath()
                ctx.fillText(label, root.contentWidth + __.labelOffset, horizontalPos)
                ctx.closePath()
                ctx.stroke()
            }
        }
        //绘制总标签
        subLabel = "Y1  " + "x" + 1/y1Power
        ctx.fillStyle = trendSettings.y1MarkColor
        ctx.font = __.fontPixelSize + __.fontFamily
        ctx.textAlign ="left"
        ctx.beginPath()
        ctx.fillText(subLabel, root.contentWidth + __.labelOffset,  root.contentHeight + __.labelOffset)
        ctx.closePath()
        ctx.stroke()
        ctx.restore()//返回之前保存过的路径状态和属性
    }

    // Returns a shortened, readable version of the potentially
    // large volume number.
//    function volumeToString(value) {
//        if (value < 1000)
//            return value;
//        var exponent = parseInt(Math.log(value) / Math.log(1000));
//        var shortVal = parseFloat(parseFloat(value) / Math.pow(1000, exponent)).toFixed(1);

//        // Drop the decimal point on 3-digit values to make it fit
//        if (shortVal >= 100.0) {
//            shortVal = parseFloat(shortVal).toFixed(0);
//        }
//        return shortVal + "KMBTG".charAt(exponent - 1);
//    }

//    function drawScales(ctx, high, low, vol){
//        ctx.save();
//        ctx.strokeStyle = "#888888";
//        ctx.font = "10px Open Sans"
//        ctx.beginPath();//起始一条路径，或重置当前路径

//        // prices on y-axis
//        var x = root.width - tickMargin + 3;
//        var priceStep = (high - low) / 9.0;
//        for (var i = 0; i < 10; i += 2) {
//            var price = parseFloat(high - i * priceStep).toFixed(1);//parseFloat() 函数可解析一个字符串，并返回一个浮点数。
//            //该函数指定字符串中的首个字符是否是数字。如果是，则对字符串进行解析，直到到达数字的末端为止，然后以数字返回该数字，而不是作为字符串。
//            ctx.text(price, x, root.yGridOffset + i * yGridStep - 2);
//        }

//        // volume scale
//        for (i = 0; i < 3; i++) {
//            var volume = volumeToString(vol - (i * (vol/3)));
//            ctx.text(volume, x, root.yGridOffset + (i + 9) * yGridStep + 10);
//        }

//        ctx.closePath();
//        ctx.stroke();
//        ctx.restore();
//    }

//    function drawPrice(ctx, from, to, color, price, points, highest, lowest){
//        ctx.save();
//        ctx.globalAlpha = 0.7;
//        ctx.strokeStyle = color;
//        ctx.lineWidth = 3;
//        ctx.beginPath();

//        var end = points.length;

//        var range = highest - lowest;
//        if (range == 0) {
//            range = 1;
//        }

//        for (var i = 0; i < end; i += pixelSkip) {
//            var x = points[i].x;
//            var y = points[i][price];
//            var h = 9 * yGridStep;

//            y = h * (lowest - y)/range + h + yGridOffset;

//            if (i == 0) {
//                ctx.moveTo(x, y);
//            } else {
//                ctx.lineTo(x, y);
//            }
//        }
//        ctx.stroke();
//        ctx.restore();
//    }

//    function drawVolume(ctx, from, to, color, price, points, highest){
//        ctx.save();
//        ctx.fillStyle = color;
//        ctx.globalAlpha = 0.8;
//        ctx.lineWidth = 0;
//        ctx.beginPath();

//        var end = points.length;
//        var margin = 0;

//        if (activeChart === "month" || activeChart === "week") {
//            margin = 8;
//            ctx.shadowOffsetX = 4;
//            ctx.shadowBlur = 3.5;
//            ctx.shadowColor = Qt.darker(color);
//        }

//        // To match the volume graph with price grid, skip drawing the initial
//        // volume of the first day on
//        for (var i = 1; i < end; i += pixelSkip) {
//            var x = points[i - 1].x;
//            var y = points[i][price];
//            y = root.height * (y / highest);
//            y = 3 * y / 12;
//            ctx.fillRect(x, root.height - y + yGridOffset,
//                         root.xGridStep - margin, y);
//        }

//        ctx.stroke();
//        ctx.restore();
//    }

//    function drawError(ctx, msg){
//        ctx.save(); //保存当前环境的状态
//        ctx.strokeStyle = "#888888"; //设置或返回用于笔触的颜色、渐变或模式
//        ctx.font = "24px Open Sans"
//        ctx.textAlign = "center"
//        ctx.shadowOffsetX = 4;//设置或返回阴影距形状的水平距离
//        ctx.shadowOffsetY = 4;//设置或返回阴影距形状的垂直距离
//        ctx.shadowBlur = 1.5;//设置或返回用于阴影的模糊级别
//        ctx.shadowColor = "#aaaaaa";//设置或返回用于阴影的颜色
//        ctx.beginPath();//起始一条路径，或重置当前路径

//        ctx.fillText(msg, root.width / 2,
//                          root.height/ 2);

//        ctx.closePath();//创建从当前点回到起始点的路径
//        ctx.stroke();//绘制已定义的路径
//        ctx.restore();//返回之前保存过的路径状态和属性  !!just path and property
//    }

    // Uncomment below lines to use OpenGL hardware accelerated rendering.
    // See Canvas documentation for available options.
    // renderTarget: root.FramebufferObject
    // renderStrategy: root.Threaded

    onPaint: {

        var ctx = root.getContext("2d");
        ctx.globalCompositeOperation = "source-over";//设置或返回新图像如何绘制到已有的图像上。默认。在目标图像上显示源图像。
        ctx.lineWidth = 1;

        drawBackground(ctx);//背景



        //        if (!stockModel.ready) {
        //        drawError(ctx, "No data available.");
        //            return;
        //        }

        if(trendSettings.y1Enable){
            //找到范围内最大、最小。作为后续绘图的范围
        }


//        var highestPrice = 0;
//        var highestVolume = 0;
//        var lowestPrice = -1;
//        var points = [];
//        //找到范围内最大价格、最小价格、最大成交量和最小成交量。作为后续绘图的范围
//        //numPoints is the startData's index during all background data
//        //pixelSkip is the data skip. default is 1(no skip)
//        for (var i = numPoints, j = 0; i >= 0 ; i -= pixelSkip, j += pixelSkip) {
//            var price = stockModel.get(i);
//            if (parseFloat(highestPrice) < parseFloat(price.high))//parseFloat() 函数可解析一个字符串，并返回一个浮点数。
//                //该函数指定字符串中的首个字符是否是数字。如果是，则对字符串进行解析，直到到达数字的末端为止，然后以数字返回该数字，而不是作为字符串。
//                highestPrice = price.high;
//            if (parseInt(highestVolume, 10) < parseInt(price.volume, 10))
//                highestVolume = price.volume;
//            if (lowestPrice < 0 || parseFloat(lowestPrice) > parseFloat(price.low))
//                lowestPrice = price.low;
//            points.push({
//                            x: j * xGridStep,
//                            open: price.open,
//                            close: price.close,
//                            high: price.high,
//                            low: price.low,
//                            volume: price.volume
//                        });
//        }

//        //价格
//        if (settings.drawHighPrice)
//            drawPrice(ctx, 0, numPoints, settings.highColor, "high", points, highestPrice, lowestPrice);
//        if (settings.drawLowPrice)
//            drawPrice(ctx, 0, numPoints, settings.lowColor, "low", points, highestPrice, lowestPrice);
//        if (settings.drawOpenPrice)
//            drawPrice(ctx, 0, numPoints,settings.openColor, "open", points, highestPrice, lowestPrice);
//        if (settings.drawClosePrice)
//            drawPrice(ctx, 0, numPoints, settings.closeColor, "close", points, highestPrice, lowestPrice);
//        //成交量
//        drawVolume(ctx, 0, numPoints, settings.volumeColor, "volume", points, highestVolume);
//        //坐标值
//        drawScales(ctx, highestPrice, lowestPrice, highestVolume);
    }
}
