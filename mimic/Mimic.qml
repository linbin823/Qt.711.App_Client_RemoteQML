import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtWebView 1.0
import "../public"
import "Module"



Item {
    property alias canGoBack : gisView.canGoBack
    function goBack() {
        gisView.goBack();
    }

    visible: true
    //anchors.fill: parent

    WebView {
        id: gisView
        anchors.fill: parent
        url: "http://qydl.csic711.net/admin.php?m=dcrealdata&f=T1"
    }
}
