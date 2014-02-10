{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Haste
import Haste.Foreign
import Haste.Prim
import Unsafe.Coerce

type Object a = [(JSString, a)]

instance Marshal JSAny where
    pack = toPtr . unsafeCoerce
    unpack = unsafeCoerce . fromPtr
    
foreign import ccall jsSet :: JSAny -> JSString -> JSString -> IO () 

cameraType :: JSAny -> JSString -> IO ()
cameraType cam typ = jsSet cam "type" typ

prod :: Int -> IO Int
prod n = return $ product [1 .. n]

main = do
    export "prod" prod
    export "cameraType" cameraType

