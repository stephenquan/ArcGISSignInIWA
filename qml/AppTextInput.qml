import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Frame {
    id: appTextInput

    property var source
    property string role
    property string text: source[role]
    property alias echoMode: textInput.echoMode
    property alias selectByMouse: textInput.selectByMouse
    property string placeholderText
    property url iconSource

    Layout.fillWidth: true

    signal accepted()

    background: Rectangle {
        color: styles.textInputBackgroundColor
        border.color: styles.textInputBorderColor
    }

    RowLayout {
        width: parent.width

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: textInput.height

            TextInput {
                id: textInput

                width: parent.width

                text: appTextInput.text
                font.pointSize: styles.textPointSize
                selectByMouse: true

                onAccepted: {
                    source[role] = text;
                    text = Qt.binding( () => appTextInput.text );
                    appTextInput.accepted();
                }
            }

            Text {
                visible: !textInput.text

                text: appTextInput.placeholderText
                font.pointSize: styles.textPointSize
            }
        }
    }
}
