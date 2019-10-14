import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Rectangle {
    id: root
    color: "black"
    height: 64

    property bool running: false
    property var runningTimeEntry: null

    function start() {
        if (!running && description.text.length > 0) {
            var dur = duration.text === "00:00" ? "" : duration.text
            toggl.start(description.text, dur, 0, 0, "", false)
            description.text = ""
        }
    }

    Connections {
        target: toggl
        onDisplayStoppedTimerState: {
            running = false
            runningTimeEntry = null
        }
        onDisplayRunningTimerState: {
            running = true
            runningTimeEntry = view
        }
    }

    RowLayout {
        id: timerContainer
        height: parent.height
        width: parent.width - startButton.width - 6
        x: 6
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 0
            Text {
                visible: running
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                text: runningTimeEntry ? " " + runningTimeEntry.Description : ""
                color: "white"
                font.pixelSize: 12
            }
            TextField {
                id: description
                focus: true
                visible: !running
                Layout.fillWidth: true
                onAccepted: start()
                background: Item {}
                font.pixelSize: 12
                placeholderText: "Placeholder"
                placeholderTextColor: "light gray"
                color: "white"
            }
            RowLayout {
                visible: runningTimeEntry && runningTimeEntry.ProjectLabel.length > 0
                Button {
                    implicitWidth: 12
                    implicitHeight: 12
                    text: "x"
                }
                Text {
                    text: runningTimeEntry ? runningTimeEntry.ProjectLabel : ""
                    color: runningTimeEntry && runningTimeEntry.Color.length > 0 ? runningTimeEntry.Color : "white"
                    font.pixelSize: 8
                }
                Text {
                    visible: runningTimeEntry && runningTimeEntry.TaskLabel.length > 0
                    text: runningTimeEntry && runningTimeEntry.TaskLabel.length ? "• " + runningTimeEntry.TaskLabel : ""
                    color: "white"
                }
            }
            RowLayout {
                visible: runningTimeEntry && runningTimeEntry.ClientLabel.length > 0
                Button {
                    implicitWidth: 12
                    implicitHeight: 12
                    text: "x"
                }
                Text {
                    text: runningTimeEntry ? runningTimeEntry.ClientLabel : ""
                    color: "white"
                    font.pixelSize: 8
                }
            }
        }
        ColumnLayout {
            Layout.fillHeight: true
            Text {
                visible: running
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                text: runningTimeEntry ? runningTimeEntry.Duration : ""
                Timer {
                    running: root.running
                    interval: 100
                    repeat: true
                    onTriggered: {
                        parent.text = toggl.formatDurationInSecondsHHMMSS(new Date().getTime() / 1000 - runningTimeEntry.Started)
                    }
                }

                color: "white"
            }
            TextField {
                id: duration
                visible: !running
                Layout.preferredWidth: 64
                onAccepted: start()
                validator: RegExpValidator {
                    regExp: /[0-9][0-9]:[0-9][0-9]/
                }
                font.pixelSize: 12
                background: Item {}
                placeholderText: "00:00"
                placeholderTextColor: "light gray"
                color: "white"
            }
        }
    }
    Rectangle {
        id: startButton
        width: parent.height
        height: parent.height
        anchors.left: timerContainer.right
        anchors.leftMargin: 3
        color: running ? "red" : "green"
        Text {
            text: running ? "Stop" : "Start"
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (running) {
                    toggl.stop()
                }
                else {
                    start()
                }
            }
        }
    }
}
