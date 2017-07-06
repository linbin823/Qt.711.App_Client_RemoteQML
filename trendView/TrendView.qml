import QtQuick 2.7
import "Module"
import "../public"

Rectangle {
    id:viewerRoot
    clip: true

    signal parentWindowClose

    TrendSettings{ id: settings}

    Rectangle{
        id: viewerContentWrapper
        color: "transparent"
        width: viewerRoot.height
        height: viewerRoot.width
        x: viewerRoot.width
        y: 0
        transformOrigin: Item.TopLeft
        rotation: 90

        TrendViewerContent {
            id: content
            anchors.fill: parent
            trendSettings: settings
        }
    }


    Rectangle {
        id: viewerToolBarWrapper
        color: "transparent"
        clip: true
        width:  viewerRoot.width * 0.9
        height: viewerRoot.height * 0.9
        x:(viewerRoot.width -width)*0.5
        y: 0

        property bool isToolbarShow: false
        opacity: 0.7

        TrendViewerToolBar{
            id: viewerToolBar
            anchors.fill: parent
            onKeyPressed: {
                if(viewerToolBarWrapper.isToolbarShow === false){
                    toolbarShow()
                }
                else{
                    toolbarHide()
                }
            }
            trendSettings: settings
        }
        YAnimator {
            id: viewerToolBar_flyIn
            target: viewerToolBarWrapper
            from: viewerToolBarWrapper.y
            to:   0
            duration: 500
            running: false
        }

        YAnimator {
            id: viewerToolBar_flyOut
            target: viewerToolBarWrapper
            from: viewerToolBarWrapper.y
            to:   -viewerToolBarWrapper.height* viewerToolBar.toolsRatio
            duration: 500
            running: true
        }

        Timer {
            id:fade_delay
            repeat: false
            running: false
            interval: 5000
            onTriggered:{
                toolbarHide()
            }
        }

        OpacityAnimator {
            id: tools_fade
            target: viewerToolBarWrapper
            from:viewerToolBarWrapper.opacity
            to:0.7
            duration: 1000
            running: false
        }
    }

    function toolbarHide(){
        if(viewerToolBarWrapper.isToolbarShow){
            tools_fade.start()
            viewerToolBar_flyOut.start()
            viewerToolBarWrapper.isToolbarShow = false
            content.requestPaint()
        }
    }

    function toolbarShow(){
        viewerToolBarWrapper.opacity = 1.0
        viewerToolBar_flyIn.start()
        viewerToolBarWrapper.isToolbarShow = true
        content.requestPaint()
    }
}
