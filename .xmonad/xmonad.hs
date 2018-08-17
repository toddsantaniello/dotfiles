-------------------------------------------------------------------------------
-- xmonad.hs for xmonad-darcs
-------------------------------------------------------------------------------
-- Compiler flags --
{-# LANGUAGE NoMonomorphismRestriction #-}

-- Imports --
-- stuff
import XMonad
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import System.Exit
import XMonad.Util.Run (safeSpawn)
import Graphics.X11.ExtraTypes.XF86

-- actions
import XMonad.Actions.GridSelect
import XMonad.Actions.CycleWS

-- hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ICCCMFocus

-- layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Renamed
import XMonad.Layout.Tabbed

-------------------------------------------------------------------------------
-- Main --
-- main :: IO ()
main = do
  xmonad $ defaultConfig {
         terminal = "urxvt"
         }

