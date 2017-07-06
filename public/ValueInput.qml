import QtQuick 2.7


TextInput{
    id: textInput

    property int validtorType
    readonly property var enumValidtorType: {"disable":0,"int":1,"double":2}
    property real validtorTop
    property real validtorBottom
    property bool isEncrpy: false

    function setText(target){
        textInput.text = target
    }
    IntValidator{
        id: intValid
    }

    DoubleValidator{
        id: doubleValid
        notation: DoubleValidator.StandardNotation
    }

    Component.onCompleted: {
        switch(validtorType){
        case 0:
            break
        case 1:
            validator = intValid
            break
        case 2:
            validator = doubleValid
            break
        }
    }
    onFocusChanged: {
        if(focus)
            Qt.inputMethod.show()
    }
    onValidtorBottomChanged: {
        intValid.bottom = validtorBottom
        doubleValid.bottom = validtorBottom
    }
    onValidtorTopChanged: {
        intValid.top = validtorTop
        doubleValid.top = validtorTop
    }
    onIsEncrpyChanged: {
        if(isEncrpy){
            echoMode = TextInput.Password
        }else{
            echoMode = TextInput.Normal
        }
    }
}

