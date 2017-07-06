import QtQuick 2.7
import QtQuick.Controls 2.1

Popup{
    id: root
    clip: true
    property int minYear : 2015
    property alias color: bg.color
    property alias radius: bg.radius
    property int currentDateFontSize: root.width / 17
    property int otherDateFontSize: root.width / 17 / 1.5
    property color currentDateTextColor:"black"
    property color otherDateTextColor:  "grey"
    property int selectDateNumber: 3
    property date pickedDate


    function toCurrentTime( target ){
        var ret = isDate(target)
        var temp
        if(ret === true){
            temp = target
        }else{
            temp = new Date() // to current time
        }
        years.setCurrentIndex( temp.getFullYear() - minYear )
        months.setCurrentIndex( temp.getMonth() )
        dates.setCurrentIndex( temp.getDate() -1 )
        hours.setCurrentIndex( temp.getHours() )
        minutes.setCurrentIndex( temp.getMinutes() )
        seconds.setCurrentIndex( temp.getSeconds() )
    }

    function isDate( target ){
        if(!target instanceof Date) return false;
        var intYear = target.getFullYear()
        var intMonth =  target.getMonth() + 1
        var intDate = target.getDate()
        if(isNaN(intYear)||isNaN(intMonth)||isNaN(intDate)) return false;
        if(intMonth>12||intMonth<1) return false;
        if ( intDate<1||intDate>31)return false;
        if((intMonth==4||intMonth==6||intMonth==9||intMonth==11)&&(intDate>30)) return false;
        if(intMonth==2){
            if(intDate>29) return false;
            if((((intYear%100==0)&&(intYear%400!=0))||(intYear%4!=0))&&(intDate>28))return false;
        }
        return true;
    }

    Component.onCompleted: {
        var curr = new Date()
        var temp = []
        for(var i = 0; i < 60; i++){
            temp.push(i + "秒")
        }
        seconds.model = temp
        var temp1 = []
        for(i = 0; i < 60; i++){
            temp1.push(i + "分")
        }
        minutes.model = temp1
        var temp2 = []
        for(i = 0; i < 24; i++){
            temp2.push(i + "时")
        }
        hours.model = temp2

        var maxDay = root.maxDays[0]
        var temp3 = []
        for (i = 0; i < maxDay; ++i) {
            temp3.push(i + 1 + "日")
        }
        dates.model = temp3

        var temp4 = []
        for (i = 0; i <= 11; i++) {
            temp4.push(i + 1 + "月")
        }
        months.model = temp4

        var temp5 = []
        for (i = minYear; i <= curr.getFullYear(); ++i) {
            temp5.push(i + "年")
        }
        years.model = temp5
    }

    modal: true
    background:Rectangle{
        id:bg
        color: "azure"
    }

    property real widthFact: width / ( 0.5+ 6 + 4 + 4 + 4 + 4 + 4 + 0.5)
    readonly property var maxDays: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    Row{
        id: picker
        height: parent.height * 0.9
        anchors{
            top: parent.top
            left: parent.left
            right:parent.right
        }

        WheelList {
            id: years
            width: widthFact * 6
            height: parent.height
            currentItemFontSize: currentDateFontSize
            otherItemFontSize: otherDateFontSize
            currentItemTextColor:currentDateTextColor
            otherItemTextColor:  otherDateTextColor
            selectItemNumber: selectDateNumber
            onCurrentIndexChanged: {
                months.updateModel()
            }
        }
        WheelList {
            id: months
            width: widthFact * 4
            height: parent.height
            currentItemFontSize: currentDateFontSize
            otherItemFontSize: otherDateFontSize
            currentItemTextColor:currentDateTextColor
            otherItemTextColor:  otherDateTextColor
            selectItemNumber: selectDateNumber
            function updateModel() {
                var previousIndex = months.currentIndex
                var currDate = new Date()
                var currYear  = currDate.getFullYear()
                var currMonth = currDate.getMonth()
                var array = []
                var diff = (years.currentIndex + minYear) === currYear? model.length - 1 - currMonth : model.length - 12
                if ( diff > 0 ) {
                    array = model
                    array.splice( - diff, diff)
                    model = array
                    months.setCurrentIndex( currMonth)
                } else if( diff < 0 ){
                    array = model
                    for (var i = model.length; i < model.length - diff; i++) {
                        array.push(i + 1 + "月")
                    }
                    model = array
                    months.setCurrentIndex( previousIndex )
                }
            }
            onCurrentIndexChanged: {
                dates.updateModel()
            }
        }
        WheelList {
            id: dates
            width: widthFact * 4
            height: parent.height
            currentItemFontSize: currentDateFontSize
            otherItemFontSize: otherDateFontSize
            currentItemTextColor:currentDateTextColor
            otherItemTextColor:  otherDateTextColor
            selectItemNumber: selectDateNumber
            function updateModel() {
                var previousIndex = dates.currentIndex
                var currDate = new Date()
                var currYear  = currDate.getFullYear()
                var currMonth = currDate.getMonth() + 1
                var maxDay = maxDays[months.currentIndex]
                if(currMonth === 2){
                    if( ((currYear%400===0) && (currYear%100===0)) || ((currYear%4===0) && (currYear%100!==0)) )
                        maxDay = maxDay + 1
                }
                var array = []
                var diff = model.length - maxDay
                if ( diff > 0 ) {
                    array = model
                    array.splice( - diff, diff)
                    model = array
                    dates.setCurrentIndex( maxDay - 1 )
                } else if( diff < 0 ){
                    var lastDay = model.length
                    array = model
                    for (var i = lastDay; i < lastDay - diff; i++) {
                        array.push(i + 1 + "日")
                    }
                    model = array
                    dates.setCurrentIndex( previousIndex )
                }
            }
        }
        WheelList {
            id: hours
            width: widthFact * 4
            height: parent.height
            currentItemFontSize: currentDateFontSize
            otherItemFontSize: otherDateFontSize
            currentItemTextColor:currentDateTextColor
            otherItemTextColor:  otherDateTextColor
            selectItemNumber: selectDateNumber
        }
        WheelList {
            id: minutes
            width: widthFact * 4
            height: parent.height
            currentItemFontSize: currentDateFontSize
            otherItemFontSize: otherDateFontSize
            currentItemTextColor:currentDateTextColor
            otherItemTextColor:  otherDateTextColor
            selectItemNumber: selectDateNumber
        }

        WheelList {
            id: seconds
            width: widthFact * 4
            height: parent.height
            currentItemFontSize: currentDateFontSize
            otherItemFontSize: otherDateFontSize
            currentItemTextColor:currentDateTextColor
            otherItemTextColor:  otherDateTextColor
            selectItemNumber: selectDateNumber
        }
    }

    Button{
        id: pbOk
        flat: true
        text: "ok"
        width: parent.width / 3
        anchors{
            top:picker.bottom
            topMargin: 5
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            var tempDate = new Date()
            tempDate.setFullYear( years.currentIndex + minYear )
            tempDate.setMonth( months.currentIndex)
            tempDate.setDate( dates.currentIndex + 1)
            tempDate.setHours(hours.currentIndex)
            tempDate.setMinutes(minutes.currentIndex)
            tempDate.setSeconds(seconds.currentIndex)
            pickedDate = tempDate
            root.close()
        }
    }

}
