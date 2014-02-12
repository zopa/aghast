{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Applicative
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server

main :: IO ()
main = quickHttpServe site

site :: Snap ()
site =
    ifTop (writeBS "Aghast server") <|>
    route [ ("app", serveDirectory "app")
          , ("phones", serveDirectory "app/phones")
          ]
