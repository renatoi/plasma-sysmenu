# System Menu (com.nerdstrike.sysmenu)

A KDE Plasma 6 panel widget that mimics the macOS Apple menu: a single icon in
the panel (top-left) that opens a dropdown with system actions.

## Menu entries

| Entry | Backed by |
| --- | --- |
| About This Computer | `kinfocenter` |
| System Settings… | `systemsettings` |
| Discover… | `plasma-discover` |
| Force Quit a Window… | `org.kde.KWin /KWin killWindow` (click a window to kill it, Esc cancels) |
| Sleep | `systemctl suspend` |
| Restart… | `org.kde.LogoutPrompt promptReboot` (shows the normal confirmation dialog) |
| Shut Down… | `org.kde.LogoutPrompt promptShutDown` |
| Lock Screen | `loginctl lock-session` |
| Log Out… | `org.kde.LogoutPrompt promptLogout` |

Entries live in the `menuModel` list at the top of `contents/ui/main.qml` —
add/remove/reorder actions there; a `"|"` string renders a separator.

## Install / update

```sh
make install    # first time
make upgrade    # after changes (also restarts plasmashell)
```

Then right-click the panel → *Add Widgets…* → *System Menu* and drag it to the
far left.

The panel icon is configurable (right-click the widget → *Configure…*):
*Choose…* opens KDE's icon dialog (theme icons plus Browse… for custom
PNG/SVG files), or type an icon name / file path directly. Default is
`start-here-kde-symbolic`.
