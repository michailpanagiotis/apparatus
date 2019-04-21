-- http://github.com/vicfryzel/xmonad-config

import System.IO
import System.Exit
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.SimpleDecoration
import XMonad.Layout.Tabbed
import XMonad.Layout.WindowNavigation
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Grid
import XMonad.Layout.IM
import Data.Ratio ((%))
import XMonad.Actions.WindowBringer
import XMonad.Actions.GridSelect
import XMonad.Actions.CycleWS
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Scratchpad
import XMonad.Util.Ungrab
import qualified XMonad.StackSet as W
import qualified Data.Map as M

myTerminal = "urxvt"
myLauncher = "$(yeganesh -x -- -fn 'Fira Code Retina-12' -nb '#000000' -nf '#d0e1f9' -sb '#000000' -sf '#4B86B4')"
myBorderWidth = 1
myModMask = mod4Mask
myWorkspaces = ["1","2","3","4","5","6","7","8","9:im"]

-- Border colors for unfocused and focused windows, respectively.
myFocusedBorderColor = "#4b86b4"
myNormalBorderColor = "black"

mySelectScreenshot = "scrot -s -z -e 'mv $f ~/Desktop/'"

myScreenshot = "scrot -z -e 'mv $f ~/Desktop/'"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modMask .|. controlMask, xK_l), spawn "xscreensaver-command -lock")
    , ((modMask, xK_p), spawn myLauncher)
    , ((modMask .|. shiftMask, xK_p), spawn myScreenshot)
    , ((modMask .|. controlMask, xK_p), unGrab >> spawn mySelectScreenshot)
    , ((modMask .|. shiftMask, xK_c), kill)
    , ((modMask, xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modMask, xK_n), refresh)

    -- Move focus to the next window
    , ((modMask, xK_Tab), windows W.focusDown)

    -- Move focus to the next window
    , ((modMask, xK_j), windows W.focusDown)

    -- Move focus to the previous window
    , ((modMask, xK_k), windows W.focusUp)

    -- Move focus to the master window
    , ((modMask, xK_m), windows W.focusMaster)

    -- Swap the focused window and the master window
    , ((modMask, xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_j), windows W.swapDown)

    -- Swap the focused window with the previous window
    , ((modMask .|. shiftMask, xK_k), windows W.swapUp)

    -- Shrink the master area
    , ((modMask, xK_h), sendMessage Shrink)

    -- Expand the master area
    , ((modMask, xK_l), sendMessage Expand)

    -- Push window back into tiling
    , ((modMask, xK_t), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modMask, xK_comma), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modMask, xK_s), toggleWS)

    -- Deincrement the number of windows in the master area
    , ((modMask, xK_period), sendMessage (IncMasterN (-1)))

    -- Spawn scratchpad
    , ((modMask, xK_s), scratchpadSpawnActionTerminal myTerminal)

    -- toggle the status bar gap
    -- TODO, update this binding with avoidStruts , ((modMask, xK_b),

    -- Open the file explorer
    , ((mod4Mask .|. shiftMask, xK_o),  spawn "pcmanfm")

    -- Toggle Fullscreen
    , ((mod4Mask .|. shiftMask, xK_f), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modMask, xK_q), restart "~/.xmonad/xmonad-x86_64-linux" True)

    -- Sound hot keys
    , ((0, 0x1008ff13), spawn "amixer set Master 2+")
    , ((0, 0x1008ff11), spawn "amixer set Master 2-")
    , ((0, 0x1008ff12), spawn "amixer set Master toggle")
    , ((0, 0x1008ff03), spawn "xbacklight -dec 10")
    , ((0, 0x1008ff02), spawn "xbacklight -inc 10")
    ]
    ++

    [ ((modMask, xK_Right), sendMessage $ Go R)
    , ((modMask, xK_Left ), sendMessage $ Go L)
    , ((modMask, xK_Up   ), sendMessage $ Go U)
    , ((modMask, xK_Down ), sendMessage $ Go D)
    , ((modMask .|. shiftMask, xK_Right), nextScreen)
    , ((modMask .|. shiftMask, xK_Left), prevScreen)
    , ((modMask .|. shiftMask, xK_Up   ), sendMessage $ Move U)
    , ((modMask .|. shiftMask, xK_Down ), sendMessage $ Move D)
    , ((modMask .|. shiftMask, xK_g ), gotoMenu)
    , ((modMask .|. shiftMask, xK_b ), bringMenu)
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    -- change greedyView to view and back
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [1,0,2]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
myTabConfig = defaultTheme { inactiveBorderColor = "#7C7C7C"
                             , inactiveTextColor = "#EEEEEE"
                             , inactiveColor     = "#000000"
                             , activeTextColor   = "#00FF00"
                             , activeColor       = "#000000" }

myLayout = windowNavigation $
  avoidStruts $
  onWorkspace "9:im" ((withIM (0.15) skypeRoster) tiled) $
    tiled |||
    Mirror tiled |||
    myTabbed |||
    Full |||
    Grid
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio = 1/2

     -- Percent of screen to increment by when resizing panes
     delta = 3/100

     myTabbed = tabbed shrinkText myTabConfig

     -- Pidgin im identification
     -- pidginRoster = (And (ClassName "Pidgin") (Role "buddy_list"))
     -- pidginRoster = (And (ClassName "Pidgin") (Title "Buddy List"))
     skypeRoster = (And (ClassName "Skype") (Title "ttkis - Skype™"))
------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
-- Allows focusing other monitors without killing the fullscreen
--  [ isFullscreen --> (doF W.focusDown <+> doFullFloat)
--
-- Single monitor setups, or if the previous hook doesn't work
--  isFullscreen                  --> doFullFloat

myManageHook = composeAll
    [ className =? "Vlc"            --> doFloat
    , className =? "Chrome"         --> doFloat
    , className =? "Gimp"           --> doFloat
    , className =? "Galculator"     --> doFloat
    , resource  =? "compose"        --> doFloat
    , className =? "Pidgin"         --> doShift "9:im"
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , resource  =? "stalonetray"    --> doIgnore
    -- , isFullscreen                  --> doFullFloat
    , scratchpadManageHook (W.RationalRect 0.125 0.25 0.75 0.5)]

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True


------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
	xmproc <- spawnPipe "xmobar ~/.xmobarrc"
	xmonad $ defaults {
		logHook = dynamicLogWithPP $ xmobarPP {
      ppOutput = hPutStrLn xmproc
      , ppTitle = xmobarColor "#b3cde0" "" . shorten 80
      , ppCurrent = xmobarColor "#CEFFAC" ""
      , ppSep = "   "
    }
		, manageHook = manageDocks <+> myManageHook
		, startupHook = setWMName "LG3D"
		, handleEventHook = docksEventHook
	}

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = defaultConfig {
      terminal           = myTerminal,
      focusFollowsMouse  = myFocusFollowsMouse,
      borderWidth        = myBorderWidth,
      modMask            = myModMask,
      workspaces         = myWorkspaces,
      normalBorderColor  = myNormalBorderColor,
      focusedBorderColor = myFocusedBorderColor,
      keys               = myKeys,
      mouseBindings      = myMouseBindings,
      layoutHook         = smartBorders $ myLayout,
      manageHook         = myManageHook,
      startupHook        = myStartupHook
    }
