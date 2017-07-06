import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Extras 1.4
import "../../public"

Rectangle {

    width: 800
    height: 600
    property real toolsRatio: 0.9
    property real rowHeight: xSettingColumn.height * 0.1
    property real rowSpacing: xSettingColumn.width * 0.05
    property real columnSpacing: xSettingColumn.height * 0.01
    property real textPixelSize: rowHeight * 0.3

    property string timeRange
    property string currTime
    property var trendSettings : null

    signal keyPressed(string target)
    color: "grey"
    onTrendSettingsChanged: {
        if(!trendSettings) return
        range.currentIndex = trendSettings.xSpan
        speed.currentIndex = trendSettings.updateInterv
        brushStyle.currentIndex = trendSettings.style
        brushSize.currentIndex = trendSettings.brushPixelSize
        y1RangeMax.text = trendSettings.y1RangeMax
        y1RangeMin.text = trendSettings.y1RangeMin
    }

    Rectangle{
        id: toolsWrapper
        height: parent.height * toolsRatio
        width: parent.width
        anchors.left : parent.left
        anchors.top : parent.top
        clip: true
        SwipeView {
            id: swipeView
            height: toolsWrapper.height * toolsRatio
            width: toolsWrapper.width
            anchors.left : parent.left
            anchors.top : tabBar.bottom
            currentIndex: tabBar.currentIndex

            Page {
                id: xSetting
                clip:true
                width: swipeView.width
                height: swipeView.height

                Column{
                    id: xSettingColumn
                    width: parent.width * 0.9
                    height: parent.height
                    x: parent.width * 0.05
                    spacing: columnSpacing

                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "起始时刻:"
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: textPixelSize
                            height: rowHeight
                        }

                        Text{
                            text: trendSettings.dateStart.getFullYear() + "年  " +
                                  (trendSettings.dateStart.getMonth()+1) + "月  " +
                                  trendSettings.dateStart.getDate() + "日  " +
                                  trendSettings.dateStart.getHours() + "时  " +
                                  trendSettings.dateStart.getMinutes() + "分  " +
                                  trendSettings.dateStart.getSeconds()+ "秒"
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: textPixelSize
                            height: rowHeight
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    inputTime.toCurrentTime(trendSettings.dateStart)
                                    inputTime.open()
                                }
                            }
                        }
                    }

                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing

                        Text{
                            text: "时间范围:"
                            font.pixelSize: textPixelSize
                            verticalAlignment: Text.AlignVCenter
                            height: rowHeight
                        }

                        ComboBox{
                            id: range
                            model: trendSettings.enumXSpan
                            height: rowHeight * 0.6
                            y: parent.height * 0.2
                            onCurrentIndexChanged: {
                                trendSettings.xSpan = currentIndex
                            }
                        }
                    }
                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "实时刷新速度:"
                            font.pixelSize: textPixelSize
                            verticalAlignment: Text.AlignVCenter
                            height: rowHeight
                        }

                        ComboBox{
                            id: speed
                            model: trendSettings.enumUpdateInterv
                            height: rowHeight * 0.6
                            y: parent.height * 0.2
                            onCurrentIndexChanged: {
                                trendSettings.updateInterv = currentIndex
                            }
                        }
                    }
                }
            }
            Page {
                id: styleSetting
                clip:true
                width: swipeView.width
                height: swipeView.height

                Column{
                    id: styleSettingColumn
                    width: parent.width * 0.9
                    height: parent.height
                    x: parent.width * 0.05
                    spacing: columnSpacing

                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "绘制风格:"
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: textPixelSize
                            height: rowHeight
                        }
                        ComboBox{
                            id: brushStyle
                            model: trendSettings.enumStyle
                            height: rowHeight * 0.6
                            y: parent.height * 0.2
                            onCurrentIndexChanged: {
                                trendSettings.style = currentIndex
                            }
                        }
                    }
                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "画笔大小:"
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: textPixelSize
                            height: rowHeight
                        }
                        ComboBox{
                            id: brushSize
                            model: trendSettings.enumBrushPixelSize
                            height: rowHeight * 0.6
                            y: parent.height * 0.2
                            onCurrentIndexChanged: {
                                trendSettings.brushPixelSize = currentIndex
                            }
                        }
                    }
                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "背景颜色:"
                            font.pixelSize: textPixelSize
                            verticalAlignment: Text.AlignVCenter
                            height: rowHeight
                        }
                        Rectangle{
                            width: parent.width * 0.5
                            height:  rowHeight * 0.6
                            y: parent.height * 0.2
                            border.width: 2
                            border.color: "white"
                            color: trendSettings.colorBackground
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    colorBackground.open()
                                }
                            }
                        }
                    }
                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "标题颜色:"
                            font.pixelSize: textPixelSize
                            verticalAlignment: Text.AlignVCenter
                            height: rowHeight
                        }
                        Rectangle{
                            width: parent.width * 0.5
                            height:  rowHeight * 0.6
                            y: parent.height * 0.2
                            border.width: 2
                            border.color: "white"
                            color: trendSettings.colorTitle
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    colorTitle.open()
                                }
                            }
                        }
                    }
                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "坐标轴颜色:"
                            font.pixelSize: textPixelSize
                            verticalAlignment: Text.AlignVCenter
                            height: rowHeight
                        }
                        Rectangle{
                            width: parent.width * 0.5
                            height:  rowHeight * 0.6
                            y: parent.height * 0.2
                            border.width: 2
                            border.color: "white"
                            color: trendSettings.colorAxis
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    colorAxis.open()
                                }
                            }
                        }
                    }
                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "当前时刻颜色:"
                            font.pixelSize: textPixelSize
                            verticalAlignment: Text.AlignVCenter
                            height: rowHeight
                        }
                        Rectangle{
                            width: parent.width * 0.5
                            height:  rowHeight * 0.6
                            y: parent.height * 0.2
                            border.width: 2
                            border.color: "white"
                            color: trendSettings.colorCurrentLine
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    colorCurrentLine.open()
                                }
                            }
                        }
                    }
                }
            }

            Page {
                id: y1Setting
                clip:true
                width: swipeView.width
                height: swipeView.height

                Column{
                    width: parent.width * 0.9
                    height: parent.height
                    x: parent.width * 0.05
                    spacing: columnSpacing

                    CheckBox{
                        width: parent.width
                        height:  rowHeight * 0.6
                        checked: trendSettings.y1Enable
                        text: "1#Y轴激活"
                        font.pixelSize: textPixelSize
                    }
                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "选择测点:"
                            font.pixelSize: textPixelSize
                            verticalAlignment: Text.AlignVCenter
                            height: rowHeight
                        }

                        ComboBox{
                            id: tagSelector
                            model: dataSource.tagNameList
                            height: rowHeight * 0.6
                            y: parent.height * 0.2
                            Component.onCompleted: {
                                dataSource.filter("净港一号", "", "" )
                                if( trendSettings.y1DataID !== -1 ){
                                    var tagName = dataSource.getTagName( trendSettings.y1DataID )
                                    console.log(tagName + "+" +trendSettings.y1DataID)
                                    if(tagName !== null){
                                        for(var i =0; i< model.length; i++){
                                            if(model[i] === tagName){
                                                tagSelector.currentIndex = i
                                                return
                                            }
                                        }
                                    }
                                }
                                tagSelector.currentIndex = 0
                            }
                            onCurrentIndexChanged: {
                                trendSettings.y1DataID = dataSource.getTagID( model[currentIndex] )
                            }
                        }
                    }

                    CheckBox{
                        width: parent.width
                        height:  rowHeight * 0.6
                        checked: trendSettings.y1RangeAuto
                        text:"自动缩放"
                        font.pixelSize: textPixelSize
                        onCheckedChanged: {
                            if(checked){
                                rangMax.visible = false
                                rangMin.visible = false
                            }else{
                                rangMax.visible = true
                                rangMin.visible = true
                            }
                        }
                    }

                    Row{
                        id:rangMax
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "上限"
                            fontSizeMode: Text.Fit
                            height: rowHeight
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: textPixelSize
                        }

                        ValueInput{
                            id: y1RangeMax
                            verticalAlignment: Text.AlignVCenter
                            height: rowHeight
                            font.pixelSize: textPixelSize
                            validtorType: enumValidtorType.int
                            onTextChanged: {
                                trendSettings.y1RangeMax = Number(text)
                            }
                        }
                    }

                    Row{
                        id:rangMin
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "下限"
                            font.pixelSize: textPixelSize
                            height: rowHeight
                            verticalAlignment: Text.AlignVCenter
                        }

                        ValueInput{
                            id:y1RangeMin
                            height: rowHeight
                            font.pixelSize: textPixelSize
                            verticalAlignment: Text.AlignVCenter
                            validtorType: enumValidtorType.int
                            onTextChanged: {
                                trendSettings.y1RangeMin = Number(text)
                            }
                        }
                    }
                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "曲线颜色"
                            font.pixelSize: textPixelSize
                            verticalAlignment: Text.AlignVCenter
                            height: rowHeight
                        }
                        Rectangle{
                            width: parent.width * 0.5
                            height:  rowHeight * 0.6
                            y: parent.height * 0.2
                            border.width: 2
                            border.color: "white"
                            color: trendSettings.y1Color
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    y1Color.open()
                                }
                            }
                        }
                    }
                    Row{
                        width: parent.width
                        height: rowHeight
                        spacing: rowSpacing
                        Text{
                            text: "刻度颜色"
                            font.pixelSize: textPixelSize
                            verticalAlignment: Text.AlignVCenter
                            height: rowHeight
                        }
                        Rectangle{
                            width: parent.width * 0.5
                            height:  rowHeight * 0.6
                            y: parent.height * 0.2
                            border.width: 2
                            border.color: "white"
                            color: trendSettings.y1MarkColor
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    y1MarkColor.open()
                                }
                            }
                        }
                    }
                }
            }
            Page {
                id: y2Setting
            }
            Page {
                id: y3Setting
            }
            Page {
                id: y4Setting
            }

            DatePicker{
                id: inputTime
                width: parent.width * 0.6
                height: parent.height * 0.4
                x:parent.width * 0.2
                y:parent.height * 0.3

                color: "azure"
                radius: 5
                onPickedDateChanged: {
                    trendSettings.dateStart = pickedDate
                }
            }
            ColorPicker{
                id: y1Color
                width: parent.width * 0.6
                height: parent.height * 0.4
                x:parent.width * 0.2
                y:parent.height * 0.3
                sampleRectangleSize: width / 10

                onPickedColorChanged: {
                    trendSettings.y1Color = pickedColor
                    trendSettings.y1MarkColor = pickedColor
                }
            }
            ColorPicker{
                id: y1MarkColor
                width: parent.width * 0.6
                height: parent.height * 0.4
                x:parent.width * 0.2
                y:parent.height * 0.3
                sampleRectangleSize: width / 10

                onPickedColorChanged: {
                    trendSettings.y1MarkColor = pickedColor
                }
            }
            ColorPicker{
                id: colorBackground
                width: parent.width * 0.6
                height: parent.height * 0.4
                x:parent.width * 0.2
                y:parent.height * 0.3
                sampleRectangleSize: width / 10

                onPickedColorChanged: {
                    trendSettings.colorBackground = pickedColor
                }
            }
            ColorPicker{
                id: colorTitle
                width: parent.width * 0.6
                height: parent.height * 0.4
                x:parent.width * 0.2
                y:parent.height * 0.3
                sampleRectangleSize: width / 10

                onPickedColorChanged: {
                    trendSettings.colorTitle = pickedColor
                }
            }
            ColorPicker{
                id: colorAxis
                width: parent.width * 0.6
                height: parent.height * 0.4
                x:parent.width * 0.2
                y:parent.height * 0.3
                sampleRectangleSize: width / 10

                onPickedColorChanged: {
                    trendSettings.colorAxis = pickedColor
                }
            }
            ColorPicker{
                id: colorCurrentLine
                width: parent.width * 0.6
                height: parent.height * 0.4
                x:parent.width * 0.2
                y:parent.height * 0.3
                sampleRectangleSize: width / 10

                onPickedColorChanged: {
                    trendSettings.colorCurrentLine = pickedColor
                }
            }
        }


        TabBar {
            id: tabBar
            height: toolsWrapper.height * ( 1 - toolsRatio )
            width:  toolsWrapper.width
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left : parent.left
            currentIndex: swipeView.currentIndex
            TabButton {
                text: qsTr("x轴")
            }
            TabButton {
                text: qsTr("风格")
            }
            TabButton {
                text: qsTr("1数轴")
            }
            TabButton {
                text: qsTr("2数轴")
            }
            TabButton {
                text: qsTr("3数轴")
            }
            TabButton {
                text: qsTr("4数轴")
            }
        }

    }

    Button {
        width: parent.width
        height: parent.height * ( 1 - toolsRatio )
        anchors.topMargin: 0
        anchors.left : parent.left
        anchors.top : toolsWrapper.bottom
        flat: true
        Row{
            spacing: parent.width * 0.2
            Text{
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: qsTr("时间范围:") + timeRange
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                clip: true
            }
            Text{
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: qsTr("当前时刻:") + currTime
                color: "white"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                clip: true
            }
        }
        onClicked: {
            keyPressed("");
        }
    }
}
