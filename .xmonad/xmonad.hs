import qualified Data.Map                     as M
import           Graphics.X11.ExtraTypes.XF86
import           System.Exit
import           System.IO
import           XMonad
import           XMonad.Actions.CycleWS
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import qualified XMonad.StackSet              as W
import           XMonad.Util.EZConfig
import           XMonad.Util.Run              (spawnPipe)

import           XMonad.Prompt
import           XMonad.Prompt.Shell

import           XMonad.Actions.MouseResize
import           XMonad.Hooks.UrgencyHook
import           XMonad.Layout.WindowArranger

myManageHook = composeAll
  [ title =? "Authy" --> doFloat
  --, className =? "jetbrains-studio" --> doFloat
  --, className =? "sun-awt-X11-XFramePeer" --> doFloat
  , manageDocks
  ]

myLayouts = Full ||| tiled ||| Mirror tiled
  where
    tiled = Tall nmaster delta ratio
    -- Default number of windows in the master pane
    nmaster = 1
    -- Percent of screen to increment by when resizing panes
    delta = 3/100
    -- Default portion of the screen occupied by master pane
    ratio = 1/2

myKeys c = mkKeymap c $
    [ ("<XF86AudioRaiseVolume>", spawn "amixer -D pulse set Master 2%+ unmute")
    , ("<XF86AudioLowerVolume>", spawn "amixer -D pulse set Master 2%- unmute")
    , ("<XF86AudioMute>", spawn "amixer -D pulse set Master toggle")
    , ("M-c", spawn "sleep 0.2; maim -s ~/capture-$(date +%s).png")
    , ("M-x", spawn "slock")
    ]

main = do
  xmproc <- spawnPipe "xmobar ~/.xmobarrc"
  xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig
    { terminal = "urxvt"
    , modMask = mod4Mask
    , keys = \c -> myKeys c `M.union` keys defaultConfig c
    , manageHook = myManageHook <+> manageHook defaultConfig
    , layoutHook = mouseResize $ windowArrange $ avoidStruts $ myLayouts
    , handleEventHook = mconcat
                      [ docksEventHook
                      , handleEventHook defaultConfig ]
    , logHook = dynamicLogWithPP $ xmobarPP { ppOutput = hPutStrLn xmproc }
    }
