import QtQuick 2.7
import QtQuick.Controls 2.1
import "../../public"

Rectangle {
    id: viewerRoot
    clip: true
    property alias bgColor: viewerRoot.color
    property alias itemSource: content.source
    property alias  mimicTitle: viewerToolbar.mimicTitle

    signal parentWindowClose()
    signal parentNextView()
    signal parentPreviousView()

    function initScaleAndPos(){
        content.scale = 1.0
        content.x = 0
        content.y = 0
    }

    Rectangle{
        id: viewerContentWrapper
        color: "transparent"
        width: viewerRoot.height
        height: viewerRoot.width
        x: viewerRoot.width
        y: 0
        transformOrigin: Item.TopLeft
        rotation: 90

        Loader {
            id: content
            x: 0
            y: 0
            width: parent.width
            height: parent.height
            transformOrigin: Item.TopLeft

            property real ratioMax  : 3
            property real ratioMin  : 0.5
            property real xMax: (parent.width >= realWidth)?  (parent.width - realWidth) : 0
            property real xMin: (parent.width >= realWidth)?  0 : (parent.width - realWidth)
            property real yMax: (parent.height>= realHeight)? (parent.height - realHeight) : 0
            property real yMin: (parent.height >=realHeight)? 0 : (parent.height - realHeight)

            property real ratioReboundStep
            property real xReboundStep
            property real yReboundStep

            property real realWidth: width * scale
            property real realHeight: height * scale

            Timer{
                id: rebound
                interval: 200
                repeat: false
                onTriggered: {
                    reboundWorker.stop()
                    content.ratioReboundStep = 0
                    content.xReboundStep = 0
                    content.yReboundStep = 0
                }
            }
            Timer{
                id: reboundWorker
                interval: 20
                repeat: true
                onTriggered: {
                    content.scale += content.ratioReboundStep
                    content.x += content.xReboundStep
                    content.y += content.yReboundStep
                }
            }
        }

        MultiTouch{
            id: area
            anchors.fill: parent

            doubleTapRatio: 2.0
            onClicked: {
                toolbarHide()
            }
            onUpdateChanging: {
                controlledItemUpdateChanging( content )
            }
            onStateChanged: {
                if(state === enumStates.stop){
                    if( content.scale >= content.ratioMax ){
                        content.ratioReboundStep = ( content.ratioMax - content.scale ) / 9
                        rebound.start()
                        reboundWorker.start()
                    }else if( content.scale <= content.ratioMin ){
                        content.ratioReboundStep = ( content.ratioMin - content.scale ) / 9
                        rebound.start()
                        reboundWorker.start()
                    }

                    if( content.x >= content.xMax ){
                        content.xReboundStep = ( content.xMax - content.x ) / 9
                        rebound.start()
                        reboundWorker.start()
                    }else if( content.x <= content.xMin ){
                        content.xReboundStep = ( content.xMin - content.x ) / 9
                        rebound.start()
                        reboundWorker.start()
                    }

                    if( content.y >= content.yMax ){
                        content.yReboundStep = ( content.yMax - content.y ) / 9
                        rebound.start()
                        reboundWorker.start()
                    }else if( content.y <= content.yMin ){
                        content.yReboundStep = ( content.yMin - content.y ) / 9
                        rebound.start()
                        reboundWorker.start()
                    }
                }
                if(state !== enumStates.stop){
                    rebound.stop()
                    reboundWorker.stop()
                }
            }
        }
    }

    Rectangle {
        id: viewerToolbarWrapper
        color: "transparent"
        clip: true
        width: height * 0.15
        height: viewerRoot.height * 0.5

        property bool isToolbarShow: true


        x: viewerRoot.width - width
        y: (viewerRoot.height- height) * 0.5

        MimicViewerToolbar{
            id: viewerToolbar
            opacity: 0.7
            width: parent.height
            height: parent.width
            x:(parent.width - width)/2
            y:(parent.height- height)/2
            transformOrigin: Item.Center
            rotation: 90

            onKeyPressed:{
                viewerToolbar.opacity = 0.7
                fade_delay.restart()
                if(!viewerToolbarWrapper.isToolbarShow){
                    viewerToolbar_flyIn.start()
                    viewerToolbarWrapper.isToolbarShow = true
                }
                if(target === "back"){
                    parentWindowClose()
                }
                else if(target === "init"){
                    initScaleAndPos()
                }
                else if(target === "previous"){
                    parentPreviousView()
                }
                else if(target === "next"){
                    parentNextView()
                }
            }
        }
        XAnimator {
            id: viewerToolbar_flyIn
            target: viewerToolbarWrapper
            from: viewerToolbarWrapper.x
            to:   viewerRoot.width - viewerToolbarWrapper.width
            duration: 500
            running: false
        }

        XAnimator {
            id: viewerToolbar_flyOut
            target: viewerToolbarWrapper
            from: viewerToolbarWrapper.x
            to:   viewerRoot.width - viewerToolbarWrapper.width * (1-viewerToolbar.toolsRatio)
            duration: 500
            running: false
        }

        Timer {
            id:fade_delay
            repeat: false
            running: true
            interval: 5000
            onTriggered:{
                toolbarHide()
            }
        }

        OpacityAnimator {
            id: tools_fade
            target: viewerToolbar
            from:viewerToolbar.opacity
            to:0.3
            duration: 1000
            running: false
        }
    }

    function toolbarHide(){
        if(viewerToolbarWrapper.isToolbarShow){
            tools_fade.start()
            viewerToolbar_flyOut.start()
            viewerToolbarWrapper.isToolbarShow = false
        }
    }
}
