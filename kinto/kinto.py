# -*- coding: utf-8 -*-
# autostart = true

import re
from xkeysnail.transform import *

# Use the following for testing terminal keymaps
# terminals = [ "", ... ]
# xbindkeys -mk
terminals = [
    "alacritty",
    "cutefish-terminal",
    "deepin-terminal",
    "eterm",
    "gnome-terminal",
    "guake",
    "hyper",
    "io.elementary.terminal",
    "kinto-gui.py",
    "kitty",
    "Kgx",                      # GNOME Console terminal app
    "konsole",
    "lxterminal",
    "mate-terminal",
    "org.gnome.Console",
    "qterminal",
    "st",
    "sakura",
    "station",
    "tabby",
    "terminator",
    "termite",
    "tilda",
    "tilix",
    "urxvt",
    "xfce4-terminal",
    "xterm",
]
terminals = [term.casefold() for term in terminals]
termStr = "|".join(str('^'+x+'$') for x in terminals)

mscodes = ["code","vscodium"]
codeStr = "|".join(str('^'+x+'$') for x in mscodes)

# Add remote desktop clients & VM software here
# Ideally we'd only exclude the client window,
# but that may not be easily done.
remotes = [
    "Gnome-boxes",
    "org.remmina.Remmina",
    "remmina",
    "qemu-system-.*",
    "qemu",
    "Spicy",
    "Virt-manager",
    "VirtualBox",
    "VirtualBox Machine",
    "xfreerdp",
]
remotes = [client.casefold() for client in remotes]

# Add remote desktop clients & VMs for no remapping
terminals.extend(remotes)
mscodes.extend(remotes)

# Use for browser specific hotkeys
browsers = [
    "Chromium",
    "Chromium-browser",
    "Discord",
    "Epiphany",
    "Firefox",
    "Firefox Developer Edition",
    "Navigator",
    "firefoxdeveloperedition",
    "Waterfox",
    "Google-chrome",
    "microsoft-edge",
    "microsoft-edge-dev",
    "org.deepin.browser",
]
browsers = [browser.casefold() for browser in browsers]
browserStr = "|".join(str('^'+x+'$') for x in browsers)

chromes = [
    "Chromium",
    "Chromium-browser",
    "Google-chrome",
    "microsoft-edge",
    "microsoft-edge-dev",
    "org.deepin.browser",
]
chromes = [chrome.casefold() for chrome in chromes]
chromeStr = "|".join(str('^'+x+'$') for x in chromes)

# edges = ["microsoft-edge-dev","microsoft-edge"]
# edges = [edge.casefold() for edge in edges]
# edgeStr = "|".join(str('^'+x+'$') for x in edges)

define_multipurpose_modmap(
    # {Key.ENTER: [Key.ENTER, Key.RIGHT_CTRL]   # Enter2Cmd
    # {Key.CAPSLOCK: [Key.ESC, Key.RIGHT_CTRL]  # Caps2Esc
    # {Key.LEFT_META: [Key.ESC, Key.RIGHT_CTRL] # Caps2Esc - Chromebook
    {                                         # Placeholder
})

# Fix for avoiding modmapping when using Synergy keyboard/mouse sharing.
# Synergy doesn't set a wm_class, so this may cause issues with other
# applications that also don't set the wm_class.
# Enable only if you use Synergy.
# define_conditional_modmap(lambda wm_class: wm_class == '', {})

# [Global modemap] Change modifier keys as in xmodmap
define_conditional_modmap(lambda wm_class: wm_class.casefold() not in terminals,{

    # Key.CAPSLOCK: Key.RIGHT_CTRL,   # Caps2Cmd
    # Key.LEFT_META: Key.RIGHT_CTRL,  # Caps2Cmd - Chromebook

    # - IBM
    # Key.LEFT_ALT: Key.RIGHT_CTRL,   # IBM
    # Key.LEFT_CTRL: Key.LEFT_ALT,    # IBM
    # Key.CAPSLOCK: Key.LEFT_META,    # IBM
    # Key.RIGHT_ALT: Key.RIGHT_CTRL,  # IBM - Multi-language (Remove)
    # Key.RIGHT_CTRL: Key.RIGHT_ALT,  # IBM - Multi-language (Remove)

    # - Chromebook
    # Key.LEFT_ALT: Key.RIGHT_CTRL,   # Chromebook
    # Key.LEFT_CTRL: Key.LEFT_ALT,    # Chromebook
    # Key.RIGHT_ALT: Key.RIGHT_CTRL,  # Chromebook - Multi-language (Remove)
    # Key.RIGHT_CTRL: Key.RIGHT_ALT,  # Chromebook - Multi-language (Remove)

    # - Default Mac/Win
    # -- Default Win
    Key.LEFT_ALT: Key.RIGHT_CTRL,   # WinMac
    Key.LEFT_META: Key.LEFT_ALT,    # WinMac
    Key.LEFT_CTRL: Key.LEFT_META,   # WinMac
    Key.RIGHT_ALT: Key.RIGHT_CTRL,  # WinMac - Multi-language (Remove)
    Key.RIGHT_META: Key.RIGHT_ALT,  # WinMac - Multi-language (Remove)
    Key.RIGHT_CTRL: Key.RIGHT_META, # WinMac - Multi-language (Remove)

    # - Mac Only
    # Key.LEFT_META: Key.RIGHT_CTRL,  # Mac
    # Key.LEFT_CTRL: Key.LEFT_META,   # Mac
    # Key.RIGHT_META: Key.RIGHT_CTRL, # Mac - Multi-language (Remove)
    # Key.RIGHT_CTRL: Key.RIGHT_META, # Mac - Multi-language (Remove)
})

# [Conditional modmap] Change modifier keys in certain applications
define_conditional_modmap(re.compile(termStr, re.IGNORECASE), {
    # - IBM
    # Key.LEFT_ALT: Key.RIGHT_CTRL,     # IBM
    # # Left Ctrl Stays Left Ctrl
    # Key.CAPSLOCK: Key.LEFT_ALT,       # IBM
    # Key.RIGHT_ALT: Key.RIGHT_CTRL,    # IBM - Multi-language (Remove)
    # Key.RIGHT_CTRL: Key.RIGHT_ALT,    # IBM
    # # Right Meta does not exist on chromebooks

    # Key.RIGHT_ALT: Key.RIGHT_CTRL,  # IBM - Multi-language (Remove)
    # Key.RIGHT_CTRL: Key.RIGHT_ALT,  # IBM - Multi-language (Remove)

    # - Chromebook
    # Key.LEFT_ALT: Key.RIGHT_CTRL,     # Chromebook
    # # Left Ctrl Stays Left Ctrl
    # Key.LEFT_META: Key.LEFT_ALT,      # Chromebook
    # Key.RIGHT_ALT: Key.RIGHT_CTRL,    # Chromebook - Multi-language (Remove)
    # Key.RIGHT_CTRL: Key.RIGHT_ALT,    # Chromebook
    # # Right Meta does not exist on chromebooks

    # - Default Mac/Win
    # -- Default Win
    Key.LEFT_ALT: Key.RIGHT_CTRL,   # WinMac
    Key.LEFT_META: Key.LEFT_ALT,    # WinMac
    Key.LEFT_CTRL: Key.LEFT_CTRL,   # WinMac
    Key.RIGHT_ALT: Key.RIGHT_CTRL,  # WinMac - Multi-language (Remove)
    Key.RIGHT_META: Key.RIGHT_ALT,  # WinMac - Multi-language (Remove)
    Key.RIGHT_CTRL: Key.LEFT_CTRL,  # WinMac - Multi-language (Remove)

    # - Mac Only
    # Key.LEFT_META: Key.RIGHT_CTRL,  # Mac
    # # Left Ctrl Stays Left Ctrl
    # Key.RIGHT_META: Key.RIGHT_CTRL, # Mac - Multi-language (Remove)
    # Key.RIGHT_CTRL: Key.LEFT_CTRL,  # Mac - Multi-language (Remove)
})

##############################################
### START OF FILE MANAGER GROUP OF KEYMAPS ###
##############################################

# Keybindings overrides for Caja
# (overrides some bindings from general file manager code block below)
define_keymap(re.compile("caja", re.IGNORECASE),{
    # K("RC-Super-o"): K("RC-Shift-Enter"),       # Open in new tab
    K("RC-Super-o"):    K("RC-Shift-W"),        # Open in new window
},"Overrides for Caja - Finder Mods")

# Keybindings overrides for DDE (Deepin) File Manager
# (overrides some bindings from general file manager code block below)
define_keymap(re.compile("dde-file-manager", re.IGNORECASE),{
    K("RC-i"):                  K("RC-i"),          # File properties dialog (Get Info)
    K("RC-comma"):              None,               # Disable preferences shortcut (no shortcut available)
    K("RC-Up"):                 K("RC-Up"),         # Go Up dir
    K("RC-Shift-Left_Brace"):   K("C-Shift-Tab"),           # Go to prior tab
    K("RC-Shift-Right_Brace"):  K("C-Tab"),                 # Go to next tab
    K("RC-Shift-Left"):         K("C-Shift-Tab"),           # Go to prior tab
    K("RC-Shift-Right"):        K("C-Tab"),                 # Go to next tab
},"Overrides for DDE File Manager - Finder Mods")

# Keybindings overrides for Dolphin
# (overrides some bindings from general file manager code block below)
define_keymap(re.compile("dolphin", re.IGNORECASE),{
    K("RC-KEY_2"):      K("C-KEY_3"),           # View as List (Detailed)
    K("RC-KEY_3"):      K("C-KEY_2"),           # View as List (Compact)
    ##########################################################################################
    ### "Open in new window" requires manually setting custom shortcut of Ctrl+Shift+o
    ### in Dolphin's keyboard shortcuts. There is no default shortcut set for this function.
    ##########################################################################################
    ### "Open in new tab" requires manually setting custom shortcut of Ctrl+Shift+o in
    ### Dolphin's keyboard shortcuts. There is no default shortcut set for this function.
    ##########################################################################################
    K("RC-Super-o"):    K("RC-Shift-o"),        # Open in new window (or new tab, user's choice, see above)
    K("RC-Shift-N"):    K("F10"),               # Create new folder
    K("RC-comma"):      K("RC-Shift-comma"),    # Open preferences dialog
},"Overrides for Dolphin - Finder Mods")

# Keybindings overrides for elementary OS Files (Pantheon)
# (overrides some bindings from general file manager code block below)
define_keymap(re.compile("io.elementary.files", re.IGNORECASE),{
    # K("RC-Super-o"):    K("Shift-Enter"),       # Open folder in new tab
    K("RC-comma"): None,                        # Disable preferences shortcut since none available
},"Overrides for Pantheon - Finder Mods")

# Keybindings overrides for Nautilus
# (overrides some bindings from general file manager code block below)
define_keymap(re.compile("org.gnome.nautilus|nautilus", re.IGNORECASE),{
    # K("RC-N"): K("C-M-Space"), # macOS Finder search window shortcut Cmd+Option+Space
    # For this ^^^^^^^^^^^ to work, a custom shortcut must be set up in the Settings app in GNOME
    # to run command: "nautilus --new-window /home/USER" [ replace "USER" ]
    K("RC-KEY_1"):      K("C-KEY_2"),           # View as Icons
    K("RC-KEY_2"):      K("C-KEY_1"),           # View as List (Detailed)
    K("RC-Super-o"):    K("Shift-Enter"),       # Open in new window
    # K("RC-Super-o"):    K("RC-Enter"),          # Open in new tab
    K("RC-comma"):      K("RC-comma"),          # Overrides "Open preferences dialog" shortcut below
},"Overrides for Nautilus - Finder Mods")

# Keybindings overrides for PCManFM and PCManFM-Qt
# (overrides some bindings from general file manager code block below)
define_keymap(re.compile("pcmanfm|pcmanfm-qt", re.IGNORECASE),{
    K("RC-KEY_2"):      K("C-KEY_4"),               # View as List (Detailed) [Not in PCManFM-Qt]
    K("RC-Backspace"):  [K("Delete"),K("Enter")],   # Move to Trash (delete, bypass dialog)
},"Overrides for PCManFM - Finder Mods")

# Keybindings overrides for SpaceFM
# (overrides some bindings from general file manager code block below)
define_keymap(re.compile("spacefm", re.IGNORECASE),{
    K("RC-Page_Up"):            K("C-Shift-Tab"),           # Go to prior tab
    K("RC-Page_Down"):          K("C-Tab"),                 # Go to next tab
    K("RC-Shift-Left_Brace"):   K("C-Shift-Tab"),           # Go to prior tab
    K("RC-Shift-Right_Brace"):  K("C-Tab"),                 # Go to next tab
    K("RC-Shift-Left"):         K("C-Shift-Tab"),           # Go to prior tab
    K("RC-Shift-Right"):        K("C-Tab"),                 # Go to next tab
    K("RC-Shift-N"):            K("RC-F"),	                # Create new folder is Ctrl+F by default
    K("RC-Backspace"):          [K("Delete"),K("Enter")],   # Move to Trash (delete, bypass dialog)
    K("RC-comma"):              [K("M-V"),K("p")],          # Overrides "Open preferences dialog" shortcut below
    # This shortcut ^^^^^^^^^^^^^^^ is not fully working in SpaceFM. Opens "View" menu but not Preferences.
    # SpaceFM seems to be doing some nasty binding that blocks things like Alt+Tab while the menu is open.
},"Overrides for SpaceFM - Finder Mods")

# Keybindings overrides for Thunar
# (overrides some bindings from general file manager code block below)
define_keymap(re.compile("thunar", re.IGNORECASE),{
    K("RC-Super-o"):    K("RC-Shift-P"),            # Open in new tab
    K("RC-comma"):      [K("M-E"),K("E")],          # Overrides "Open preferences dialog" shortcut below
},"Overrides for Thunar - Finder Mods")

filemanagers = [
    "caja",
    "cutefish-filemanager",
    "dde-file-manager",
    "dolphin",
    "io.elementary.files",
    "nautilus",
    "nemo",
    "org.gnome.nautilus",
    "pcmanfm",
    "pcmanfm-qt",
    "spacefm",
    "thunar",
]
filemanagers = [filemanager.casefold() for filemanager in filemanagers]
filemanagerStr = "|".join(str('^'+x+'$') for x in filemanagers)

# Currently supported Linux file managers (file browsers):
#
# Caja File Browser (MATE file manager, fork of Nautilus)
# DDE File Manager (Deepin Linux file manager)
# Dolphin (KDE file manager)
# Nautilus (GNOME file manager, may be named "Files")
# Nemo (Cinnamon file manager, fork of Nautilus, may be named "Files")
# Pantheon Files (elementary OS file manager, may be named "Files")
# PCManFM (LXDE file manager)
# PCManFM-Qt (LXQt file manager)
# SpaceFM (Fork of PCManFM file manager)
# Thunar File Manager (Xfce file manager)
#
# Keybindings for general Linux file managers group:
define_keymap(re.compile(filemanagerStr, re.IGNORECASE),{
    ###########################################################################################################
    ###  Show Properties (Get Info) | Open Settings/Preferences | Show/Hide hidden files                    ###
    ###########################################################################################################
    K("RC-i"):                  K("M-Enter"),       # File properties dialog (Get Info)
    K("RC-comma"):              [K("M-E"),K("N")],  # Open preferences dialog
    K("RC-Shift-dot"):          K("RC-H"),          # Show/hide hidden files ("dot" files)
    ###########################################################################################################
    ###  Navigation                                                                                         ###
    ###########################################################################################################
    K("RC-Left_Brace"):         K("M-Left"),        # Go Back
    K("RC-Right_Brace"):        K("M-Right"),       # Go Forward
    K("RC-Left"):               K("M-Left"),        # Go Back
    K("RC-Right"):              K("M-Right"),       # Go Forward
    K("RC-Up"):                 K("M-Up"),          # Go Up dir
    # K("RC-Down"):               K("M-Down"),        # Go Down dir (only works on folders) [not universal]
    # K("RC-Down"):               K("RC-O"),          # Go Down dir (open folder/file) [not universal]
    K("RC-Down"):               K("Enter"),         # Go Down dir (open folder/file) [universal]
    K("RC-Shift-Left_Brace"):   K("C-Page_Up"),     # Go to prior tab
    K("RC-Shift-Right_Brace"):  K("C-Page_Down"),   # Go to next tab
    K("RC-Shift-Left"):         K("C-Page_Up"),     # Go to prior tab
    K("RC-Shift-Right"):        K("C-Page_Down"),   # Go to next tab
    ###########################################################################################################
    ###  Open in New Window | Move to Trash | Duplicate file/folder                                         ###
    ###########################################################################################################
    K("RC-Super-o"):    K("RC-Shift-o"),        # Open in new window (or tab, depends on FM setup) [not universal]
    K("RC-Backspace"):  K("Delete"),	        # Move to Trash (delete)
    # K("RC-D"):          [K("RC-C"),K("RC-V")],  # Duplicate file/folder (Copy, then Paste) [conflicts with "Add Bookmark"]
    ###########################################################################################################
    ###  To enable renaming files with the Enter key, uncomment the two keymapping lines just below this.   ###
    ###  Use Ctrl+Shift+Enter to escape or activate text fields such as "[F]ind" and "[L]ocation" fields.   ###
    ###########################################################################################################
    # K("Enter"):             K("F2"),            # Rename with Enter key
    # K("RC-Shift-Enter"):    K("Enter"),         # Remap alternative "Enter" key to easily activate/exit text fields
    # K("RC-Shift-Enter"):    K("F2"),            # Rename with Cmd+Shift+Enter
},"General File Managers - Finder Mods")

############################################
### END OF FILE MANAGER GROUP OF KEYMAPS ###
############################################

# Open preferences in browsers
define_keymap(re.compile("Firefox", re.IGNORECASE),{
    K("C-comma"): [
        K("C-T"),K("a"),K("b"),K("o"),K("u"),K("t"),
        K("Shift-SEMICOLON"),K("p"),K("r"),K("e"),K("f"),
        K("e"),K("r"),K("e"),K("n"),K("c"),K("e"),K("s"),K("Enter")
    ],
    K("RC-Shift-N"):    K("RC-Shift-P"),        # Open private window with Ctrl+Shift+N like other browsers
})

define_keymap(re.compile(chromeStr, re.IGNORECASE),{
    K("C-comma"): [K("M-e"), K("s"),K("Enter")],    # Open preferences
    K("RC-q"):              K("M-F4"),              # Quit Chrome(s) browsers with Cmd+Q
    # K("RC-Left"):           K("M-Left"),            # Page nav: Back to prior page in history (conflict with wordwise)
    # K("RC-Right"):          K("M-Right"),           # Page nav: Forward to next page in history (conflict with wordwise)
    K("RC-Left_Brace"):     K("M-Left"),            # Page nav: Back to prior page in history
    K("RC-Right_Brace"):    K("M-Right"),           # Page nav: Forward to next page in history
}, "Chrome Browsers")
# Opera C-F12

# Keybindings for General Web Browsers
define_keymap(re.compile(browserStr, re.IGNORECASE),{
    K("RC-Q"): K("RC-Q"),           # Close all browsers Instances
    K("M-RC-I"): K("RC-Shift-I"),   # Dev tools
    K("M-RC-J"): K("RC-Shift-J"),   # Dev tools
    K("RC-Key_1"): K("M-Key_1"),    # Jump to Tab #1-#8
    K("RC-Key_2"): K("M-Key_2"),
    K("RC-Key_3"): K("M-Key_3"),
    K("RC-Key_4"): K("M-Key_4"),
    K("RC-Key_5"): K("M-Key_5"),
    K("RC-Key_6"): K("M-Key_6"),
    K("RC-Key_7"): K("M-Key_7"),
    K("RC-Key_8"): K("M-Key_8"),
    K("RC-Key_9"): K("M-Key_9"),    # Jump to last tab
    # Enable Cmd+Shift+Braces for tab navigation
    K("RC-Shift-Left_Brace"):   K("C-Page_Up"),     # Go to prior tab
    K("RC-Shift-Right_Brace"):  K("C-Page_Down"),   # Go to next tab
    # Enable Cmd+Option+Left/Right for tab navigation
    K("RC-M-Left"):             K("C-Page_Up"),     # Go to prior tab
    K("RC-M-Right"):            K("C-Page_Down"),   # Go to next tab
    # Enable Ctrl+PgUp/PgDn for tab navigation
    K("Super-Page_Up"):         K("C-Page_Up"),     # Go to prior tab
    K("Super-Page_Down"):       K("C-Page_Down"),   # Go to next tab
    # Use Cmd+Braces keys for tab navigation instead of page navigation
    # K("C-Left_Brace"): K("C-Page_Up"),
    # K("C-Right_Brace"): K("C-Page_Down"),
}, "General Web Browsers")

define_keymap(re.compile("ulauncher", re.IGNORECASE),{
    K("RC-Key_1"):      K("M-Key_1"),      # Remap Ctrl+[1-9] and Ctrl+[a-z] to Alt+[1-9] and Alt+[a-z]
    K("RC-Key_2"):      K("M-Key_2"),
    K("RC-Key_3"):      K("M-Key_3"),
    K("RC-Key_4"):      K("M-Key_4"),
    K("RC-Key_5"):      K("M-Key_5"),
    K("RC-Key_6"):      K("M-Key_6"),
    K("RC-Key_7"):      K("M-Key_7"),
    K("RC-Key_8"):      K("M-Key_8"),
    K("RC-Key_9"):      K("M-Key_9"),
    K("RC-Key_0"):      K("M-Key_0"),
    # K("RC-a"):          K("M-a"),
    K("RC-b"):          K("M-b"),
    # K("RC-c"):          K("M-c"),
    K("RC-d"):          K("M-d"),
    K("RC-e"):          K("M-e"),
    K("RC-f"):          K("M-f"),
    K("RC-g"):          K("M-g"),
    K("RC-h"):          K("M-h"),
}, "Ulauncher")

# Note: terminals extends to remotes as well
define_keymap(lambda wm_class: wm_class.casefold() not in terminals,{
    K("RC-Dot"): K("Esc"),                        # Mimic macOS Cmd+dot = Escape key (not in terminals)
})

# Tab navigation overrides for apps that use Ctrl+Shift+Tab/Ctrl+Tab instead of Ctrl+PgUp/PgDn
define_keymap(re.compile("org.gnome.Console|Kgx|deepin-terminal|Angry*IP*Scanner|jDownloader", re.IGNORECASE),{
    ### Tab navigation
    K("RC-Shift-Left_Brace"):   K("C-Shift-Tab"),       # Tab nav: Go to prior tab (left)
    K("RC-Shift-Right_Brace"):  K("C-Tab"),             # Tab nav: Go to next tab (right)
    K("RC-Shift-Left"):         K("C-Shift-Tab"),       # Tab nav: Go to prior tab (left)
    K("RC-Shift-Right"):        K("C-Tab"),             # Tab nav: Go to next tab (right)
},"Tab Navigation for apps that want Ctrl+Shift+Tab/Ctrl+Tab")

define_keymap(re.compile(termStr, re.IGNORECASE),{
    K("LC-RC-f"): K("M-F10"),                       # Toggle window maximized state
    # K("RC-Grave"): K("Super-Tab"),                # xfce4 Switch within app group
    # K("RC-Shift-Grave"): K("Super-Shift-Tab"),    # xfce4 Switch within app group
    # K("LC-Right"):K("C-M-Right"),                 # Default SL - Change workspace (budgie)
    # K("LC-Left"):K("C-M-Left"),                   # Default SL - Change workspace (budgie)
    # K("LC-Left"):K("C-M-End"),                    # SL - Change workspace xfce4
    # K("LC-Left"):K("Super-Left"),                 # SL - Change workspace eos
    # K("LC-Right"):K("C-M-Home"),                  # SL - Change workspace xfce4
    # K("LC-Right"):K("Super-Right"),               # SL - Change workspace eos
    # K("LC-Right"):K("Super-Page_Up"),             # SL - Change workspace (ubuntu/fedora)
    # K("LC-Left"):K("Super-Page_Down"),            # SL - Change workspace (ubuntu/fedora)
    # K("LC-Right"):K("Super-C-Up"),                # SL - Change workspace (popos)
    # K("LC-Left"):K("Super-C-Down"),               # SL - Change workspace (popos)
    # Ctrl Tab - In App Tab Switching
    K("LC-Tab") : K("LC-PAGE_DOWN"),
    K("LC-Shift-Tab") : K("LC-PAGE_UP"),
    K("LC-Grave") : K("LC-PAGE_UP"),
    K("M-Tab"): pass_through_key,                 # Default - Cmd Tab - App Switching Default
    K("RC-Tab"): K("M-Tab"),                      # Default - Cmd Tab - App Switching Default
    K("RC-Shift-Tab"): K("M-Shift-Tab"),          # Default - Cmd Tab - App Switching Default
    # Converts Cmd to use Ctrl-Shift
    K("RC-MINUS"): K("C-MINUS"),
    K("RC-EQUAL"): K("C-Shift-EQUAL"),
    K("RC-BACKSPACE"): K("C-Shift-BACKSPACE"),
    K("RC-W"): K("C-Shift-W"),
    K("RC-E"): K("C-Shift-E"),
    K("RC-R"): K("C-Shift-R"),
    K("RC-T"): K("C-Shift-t"),
    K("RC-Y"): K("C-Shift-Y"),
    K("RC-U"): K("C-Shift-U"),
    K("RC-I"): K("C-Shift-I"),
    K("RC-O"): K("C-Shift-O"),
    K("RC-P"): K("C-Shift-P"),
    K("RC-LEFT_BRACE"): K("C-Shift-LEFT_BRACE"),
    K("RC-RIGHT_BRACE"): K("C-Shift-RIGHT_BRACE"),
    K("RC-Shift-Left_Brace"):   K("C-Shift-Left"),     # Go to prior tab (Left)
    K("RC-Shift-Right_Brace"):  K("C-Shift-Right"),   # Go to next tab (Right)
    K("RC-A"): K("C-Shift-A"),
    K("RC-S"): K("C-Shift-S"),
    K("RC-D"): K("C-Shift-D"),
    K("RC-F"): K("C-Shift-F"),
    K("RC-G"): K("C-Shift-G"),
    K("RC-H"): K("C-Shift-H"),
    K("RC-J"): K("C-Shift-J"),
    K("RC-K"): K("C-Shift-K"),
    K("RC-L"): K("C-Shift-L"),
    K("RC-SEMICOLON"): K("C-Shift-SEMICOLON"),
    K("RC-APOSTROPHE"): K("C-Shift-APOSTROPHE"),
    K("RC-GRAVE"): K("C-Shift-GRAVE"),
    K("RC-Z"): K("C-Shift-Z"),
    K("RC-X"): K("C-Shift-X"),
    K("RC-C"): K("C-Shift-C"),
    K("RC-V"): K("C-Shift-V"),
    K("RC-B"): K("C-Shift-B"),
    K("RC-N"): K("C-Shift-N"),
    K("RC-M"): K("C-Shift-M"),
    K("RC-COMMA"): K("C-Shift-COMMA"),
    K("RC-Dot"): K("LC-c"),
    K("RC-SLASH"): K("C-Shift-SLASH"),
    K("RC-KPASTERISK"): K("C-Shift-KPASTERISK"),
}, "terminals")

# None referenced here originally
# - but remote clients and VM software ought to be set here
# These are the typical remaps for ALL GUI based apps
define_keymap(lambda wm_class: wm_class.casefold() not in remotes,{
    K("RC-Shift-Left_Brace"):   K("C-Page_Up"),         # Tab nav: Go to prior (left) tab
    K("RC-Shift-Right_Brace"):  K("C-Page_Down"),       # Tab nav: Go to next (right) tab
    K("RC-Space"): K("Alt-F1"),                   # Default SL - Launch Application Menu (gnome/kde)
    K("RC-F3"):K("Super-d"),                      # Default SL - Show Desktop (gnome/kde,eos)
    K("RC-Super-f"):K("M-F10"),                   # Default SL - Maximize app (gnome/kde)
    # K("RC-Super-f"): K("Super-Page_Up"),          # SL - Toggle maximized window state (kde_neon)
    # K("Super-Right"):K("C-M-Right"),              # Default SL - Change workspace (budgie)
    # K("Super-Left"):K("C-M-Left"),                # Default SL - Change workspace (budgie)
    K("RC-Q"): K("M-F4"),                         # Default SL - not-popos
    K("RC-H"):K("Super-h"),                       # Default SL - Minimize app (gnome/budgie/popos/fedora)
    K("M-Tab"): pass_through_key,                 # Default - Cmd Tab - App Switching Default
    K("RC-Tab"): K("M-Tab"),                      # Default - Cmd Tab - App Switching Default
    K("RC-Shift-Tab"): K("M-Shift-Tab"),          # Default - Cmd Tab - App Switching Default
    K("RC-Grave"): K("M-Grave"),                  # Default not-xfce4 - Cmd ` - Same App Switching
    K("RC-Shift-Grave"): K("M-Shift-Grave"),      # Default not-xfce4 - Cmd ` - Same App Switching
    # K("RC-Grave"): K("Super-Tab"),                # xfce4 Switch within app group
    # K("RC-Shift-Grave"): K("Super-Shift-Tab"),    # xfce4 Switch within app group
    # K("Super-Right"):K("Super-Page_Up"),          # SL - Change workspace (ubuntu/fedora)
    # K("Super-Left"):K("Super-Page_Down"),         # SL - Change workspace (ubuntu/fedora)
    # K("Super-Right"):K("Super-C-Up"),             # SL - Change workspace (popos)
    # K("Super-Left"):K("Super-C-Down"),            # SL - Change workspace (popos)
    # K("RC-Q"):K("Super-q"),                       # SL - Close Apps (popos)
    # K("RC-Space"): K("Super-Space"),              # SL - Launch Application Menu (eos)
    # K("RC-H"): K("Super-Page_Down"),              # SL - Minimize app (kde_neon)
                                                  # SL - Default SL - Change workspace (kde_neon)
    # K("RC-Space"): K("LC-Esc"),                   # SL- Launch Application Menu xfce4
    # K("RC-F3"):K("C-M-d"),                        # SL- Show Desktop xfce4
    # K("RC-LC-f"):K("Super-Up"),                   # SL- Maximize app eos
    # K("RC-LC-f"):K("Super-PAGE_UP"),              # SL- Maximize app manjaro
    # Basic App hotkey functions
    # K("RC-H"):K("M-F9"),                          # SL - Minimize app xfce4
    # K("RC-LC-f"):K("Super-PAGE_DOWN"),            # SL - Minimize app manjaro
    # In-App Tab switching
    # K("M-Tab"): K("C-Tab"),                       # Chromebook/IBM - In-App Tab switching
    # K("M-Shift-Tab"): K("C-Shift-Tab"),           # Chromebook/IBM - In-App Tab switching
    # K("M-Grave") : K("C-Shift-Tab"),              # Chromebook/IBM - In-App Tab switching
    K("Super-Tab"): K("LC-Tab"),                  # Default not-chromebook
    K("Super-Shift-Tab"): K("LC-Shift-Tab"),      # Default not-chromebook

    # Fn to Alt style remaps
    K("RM-Enter"): K("insert"),                   # Insert

    # emacs style
    K("Super-a"): K("Home"),                      # Beginning of Line
    K("Super-e"): K("End"),                       # End of Line
    K("Super-b"): K("Left"),
    K("Super-f"): K("Right"),
    K("Super-n"): K("Down"),
    K("Super-p"): K("Up"),
    K("Super-k"): [K("Shift-End"), K("Backspace")],
    K("Super-d"): K("Delete"),

    # K("M-RC-Space"): K(""),                       # Open Finder - Placeholder

    # Wordwise
    K("RC-Left"): K("Home"),                      # Beginning of Line
    K("RC-Shift-Left"): K("Shift-Home"),          # Select all to Beginning of Line
    K("RC-Right"): K("End"),                      # End of Line
    K("RC-Shift-Right"): K("Shift-End"),          # Select all to End of Line
    # K("RC-Left"): K("C-LEFT_BRACE"),              # Firefox-nw - Back
    # K("RC-Right"): K("C-RIGHT_BRACE"),            # Firefox-nw - Forward
    # K("RC-Left"): K("M-LEFT"),                    # Chrome-nw - Back
    # K("RC-Right"): K("M-RIGHT"),                  # Chrome-nw - Forward
    K("RC-Up"): K("C-Home"),                      # Beginning of File
    K("RC-Shift-Up"): K("C-Shift-Home"),          # Select all to Beginning of File
    K("RC-Down"): K("C-End"),                     # End of File
    K("RC-Shift-Down"): K("C-Shift-End"),         # Select all to End of File
    # K("RM-Backspace"): K("Delete"),               # Chromebook/IBM - Delete
    K("Super-Backspace"): K("C-Backspace"),       # Delete Left Word of Cursor
    K("Super-Delete"): K("C-Delete"),             # Delete Right Word of Cursor
    # K("LM-Backspace"): K("C-Backspace"),          # Chromebook/IBM - Delete Left Word of Cursor
    K("M-Backspace"): K("C-Backspace"),           # Default not-chromebook
    K("RC-Backspace"): K("C-Shift-Backspace"),    # Delete Entire Line Left of Cursor
    K("Alt-Delete"): K("C-Delete"),               # Delete Right Word of Cursor
    # K(""): pass_through_key,                      # cancel
    # K(""): K(""),                                 #
}, "General GUI")
