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
  , className =? "sun-awt-X11-XDialogPeer" --> doFloat
  , title =? "jetbrains-studio" --> doFloat
  , className =? "emulator" --> doFloat
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

main = do
  xmproc <- spawnPipe "xmobar ~/.xmobarrc"
  xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig
    { terminal = "urxvt"
    , manageHook = myManageHook <+> manageHook defaultConfig
    , layoutHook = mouseResize $ windowArrange $ avoidStruts $ myLayouts
    , handleEventHook = mconcat
                      [ docksEventHook
                      , handleEventHook defaultConfig ]
    , logHook = dynamicLogWithPP $ xmobarPP { ppOutput = hPutStrLn xmproc }
    }
