import QtQuick 2.7

Item {
    id: delegateRoot
    clip: true
    property bool isDetailShow: false
    property Component mainBarContent
    property Component detailBarContent
    //should not restrict height or width,
    //auto generated from the size of "mainBarContent" and "detailBarContent"


    Rectangle {
        id: mainBarWrapper
        z: 1//always on top
        clip: true
        x: 0
        y: 0
        color: "transparent"
        Loader{
            id:mainBarLoader
            anchors.left: parent.left
            anchors.top: parent.top
            sourceComponent:  mainBarContent
            onLoaded:{
                mainBarWrapper.height = height
                mainBarWrapper.width = width

                delegateRoot.width = Math.max(mainBarWrapper.width, detailBarWrapper.width)
                delegateRoot.height =mainBarWrapper.height
            }
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(isDetailShow){
                    isDetailShow = false
                    detailBar_up.start()
                }
                else{
                    isDetailShow = true
                    detailBar_down.start()
                }
            }
        }

    }
    Rectangle {
        id: detailBarWrapper
        clip: true
        x: 0
        color: "transparent"
        Component.onCompleted :{
            //initial
            y = mainBarWrapper.height - detailBarWrapper.height
        }
        Loader{
            id:detailBarLoader
            sourceComponent:  detailBarContent
            onLoaded:{
                detailBarWrapper.height = height
                detailBarWrapper.width = width

                delegateRoot.width = Math.max(mainBarWrapper.width, mainBarWrapper.width)
            }
        }
    }
    YAnimator {
        id: detailBar_down
        target: detailBarWrapper
        easing.type:Easing.OutQuad
        easing.amplitude: 0.2;
        from: detailBarWrapper.y
        to:   mainBarWrapper.height
        duration: 100
        running: false
        onStarted: {
            delegateRoot.height = mainBarWrapper.height + detailBarWrapper.height
        }
    }
    YAnimator {
        id: detailBar_up
        target: detailBarWrapper
        easing.type:Easing.OutQuad
        easing.amplitude: 0.2;
        from: detailBarWrapper.y
        to:   mainBarWrapper.height - detailBarWrapper.height
        duration: 100
        running: false
        onStopped: {
            delegateRoot.height = mainBarWrapper.height
        }
    }
}
