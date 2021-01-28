import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import ArcGIS.AppFramework.Testing 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("ArcGIS Sign In (IWA)")

    property NetworkRequest networkRequest

    SignInApp {
        anchors.fill: parent
    }
}
