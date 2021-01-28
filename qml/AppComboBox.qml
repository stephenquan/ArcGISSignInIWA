import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Frame {
    id: appComboBox

    property var source
    property string role
    //property string text: source ? source[role] : ""
    property alias model: comboBox.model
    /*
    property alias echoMode: textInput.echoMode
    property alias selectByMouse: textInput.selectByMouse
    property string placeholderText
    property url iconSource
    */

    activeFocusOnTab: true
    padding: 0

    Layout.fillWidth: true

    signal accepted()

    RowLayout {
        width: parent.width

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: comboBox.height

            ComboBox {
                id: comboBox

                width: parent.width
                property bool loading: true

                /*
                onTextChanged: {
                    source[role] = text;
                }

                onAccepted: {
                    source[role] = text;
                    text = Qt.binding( () => appTextInput.text );
                    appTextInput.accepted();
                }
                */
                onCurrentTextChanged: {
                    if (loading) {
                        return;
                    }

                    source[role] = currentText;
                }

                Component.onCompleted: {
                    let text = source ? source[role] : "";
                    console.log("model: ", JSON.stringify(model));
                    console.log("text: ", text);
                    console.log("currentIndex: ", currentIndex);
                    currentIndex = model.indexOf(text);
                    loading = false;
                }
            }
        }
    }
}
