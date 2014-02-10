{-# LANGUAGE ForeignFunctionInterface #-}
module Main where

import Haste
import Haste.Foreign
import Haste.Prim

type Object a = [(JSString, a)]

foreign import ccall jsSet :: Unpacked -> JSString -> JSString -> IO ()

phoneList :: Unpacked -> IO ()
phoneList scope = jsSet scope (toJSString "phones") obj

cameraType :: Unpacked -> IO ()
cameraType cam = jsSet cam (toJSString "type") (toJSString "DSL")


prod :: Int -> IO Int
prod n = return $ product [1 .. n]

obj :: JSString
obj = toJSString $ "[{'name': 'Nexus S', 'snippet': 'Fast, says google'},"
                    ++ "{'name': 'XOOM', 'snippet': 'Tablet propaganda'}]"

main = do
    --export "phoneList" phoneList
    export "prod" prod
    export "cameraType" cameraType
