import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation

    Plasmoid.icon: Plasmoid.configuration.icon
    toolTipMainText: i18n("System Menu")
    toolTipSubText: i18n("About, settings and session actions")

    // The dropdown, macOS Apple-menu order. A "|" entry renders a separator,
    // so adding/removing/reordering actions is a one-line change.
    readonly property var menuModel: [
        { label: i18n("About This Computer"), icon: "computer", cmd: "kinfocenter" },
        "|",
        { label: i18n("System Settings…"), icon: "systemsettings", cmd: "systemsettings" },
        { label: i18n("Discover…"), icon: "plasmadiscover", cmd: "plasma-discover" },
        "|",
        { label: i18n("Force Quit a Window…"), icon: "process-stop", cmd: "qdbus6 org.kde.KWin /KWin org.kde.KWin.killWindow" },
        "|",
        { label: i18n("Sleep"), icon: "system-suspend", cmd: "systemctl suspend" },
        { label: i18n("Restart…"), icon: "system-reboot", cmd: "qdbus6 org.kde.LogoutPrompt /LogoutPrompt org.kde.LogoutPrompt.promptReboot" },
        { label: i18n("Shut Down…"), icon: "system-shutdown", cmd: "qdbus6 org.kde.LogoutPrompt /LogoutPrompt org.kde.LogoutPrompt.promptShutDown" },
        "|",
        { label: i18n("Lock Screen"), icon: "system-lock-screen", cmd: "loginctl lock-session" },
        { label: i18n("Log Out…"), icon: "system-log-out", cmd: "qdbus6 org.kde.LogoutPrompt /LogoutPrompt org.kde.LogoutPrompt.promptLogout" }
    ]

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function (sourceName) {
            disconnectSource(sourceName);
        }
    }

    function run(cmd) {
        // Close the popup first so interactive actions (Force Quit's
        // click-to-kill cursor) don't land on the popup itself.
        root.expanded = false;
        executable.connectSource(cmd);
    }

    compactRepresentation: MouseArea {
        id: compact

        implicitWidth: height
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded

        Kirigami.Icon {
            // 0 = fit the panel; a fixed size is still clamped so a large
            // value can't overflow a thin panel.
            readonly property int configuredSize: Plasmoid.configuration.iconSize
            readonly property int fitSize: Math.min(compact.width, compact.height)

            anchors.centerIn: parent
            width: configuredSize > 0 ? Math.min(configuredSize, fitSize) : fitSize - Kirigami.Units.smallSpacing
            height: width
            source: Plasmoid.configuration.icon
            active: compact.containsMouse
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Math.max(menuColumn.implicitWidth, Kirigami.Units.gridUnit * 13)
        Layout.preferredHeight: menuColumn.implicitHeight + Kirigami.Units.smallSpacing * 2
        Layout.minimumWidth: Layout.preferredWidth
        Layout.minimumHeight: Layout.preferredHeight

        ColumnLayout {
            id: menuColumn
            anchors.fill: parent
            anchors.topMargin: Kirigami.Units.smallSpacing
            anchors.bottomMargin: Kirigami.Units.smallSpacing
            spacing: 0

            Repeater {
                model: root.menuModel

                delegate: Loader {
                    required property var modelData

                    Layout.fillWidth: true
                    sourceComponent: modelData === "|" ? separatorEntry : actionEntry

                    Component {
                        id: actionEntry
                        PC3.ItemDelegate {
                            text: modelData.label
                            icon.name: modelData.icon
                            icon.width: Kirigami.Units.iconSizes.small
                            icon.height: Kirigami.Units.iconSizes.small
                            onClicked: root.run(modelData.cmd)
                        }
                    }

                    Component {
                        id: separatorEntry
                        Item {
                            implicitHeight: Kirigami.Units.smallSpacing * 2 + 1
                            Kirigami.Separator {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: Kirigami.Units.smallSpacing
                                anchors.rightMargin: Kirigami.Units.smallSpacing
                            }
                        }
                    }
                }
            }
        }
    }
}
