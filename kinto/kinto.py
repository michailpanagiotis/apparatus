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

define_keymap(re.compile(termStr, re.IGNORECASE),{
    # Converts Cmd to use Ctrl-Shift
    K("RC-MINUS"): K("C-MINUS"),
    K("RC-EQUAL"): K("C-Shift-EQUAL"),
    K("RC-BACKSPACE"): K("M-BACKSPACE"),
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

define_keymap(lambda wm_class: wm_class.casefold() not in remotes,{
    K("RC-Tab"): K("M-Tab"),                      # Default - Cmd Tab - App Switching Default
    K("C-Shift-LEFT_BRACE"):   K("C-Shift-Tab"),     # Go to prior tab (Left)
    K("C-Shift-RIGHT_BRACE"):  K("C-Tab"),   # Go to next tab (Right)
    K("C-BACKSPACE"):  K("Delete"),
}, "General GUI")
