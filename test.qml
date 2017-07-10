import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.0
import QtQuick.Window 2.1
import QtWebView 1.0
import Qt.labs.settings 1.0

ApplicationWindow {
    id: appWindow
    visible: true
    width:  720
    height: 1184
    color: "white"
    title: qsTr("QYY")

    property string currentProjectName: qsTr("船舶数据中心")

    NaviPage{
        anchors.fill: parent
    }
}
