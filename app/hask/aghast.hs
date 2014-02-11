{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Applicative
import Control.Monad
import Haste
import Haste.Foreign
import Haste.Prim
import Unsafe.Coerce

instance Marshal JSAny where
    pack = toPtr . unsafeCoerce
    unpack = unsafeCoerce . fromPtr

foreign import ccall jsStrSet :: JSAny -> JSString -> JSString -> IO () 
foreign import ccall jsObjSet :: JSAny -> JSString -> JSAny -> IO ()
foreign import ccall jsNumSet :: JSAny -> JSString -> Double -> IO ()
foreign import ccall jsStrArrayPush :: JSAny -> JSString -> IO () 
foreign import ccall jsObjArrayPush :: JSAny -> JSAny -> IO () 
foreign import ccall jsNewArray :: IO JSAny
foreign import ccall jsNewObject :: IO JSAny

-- Getters, setters, and so on.
-- These cry out for a type class. The issue is that foreign imported
-- functions must have concrete types --- so we need separate functions
--- for each type we want to set, even though they all do the same thing.
strArray :: [JSString] -> IO JSAny
strArray str = do
    arr <- jsNewArray
    forM_ str $ jsStrArrayPush arr
    return arr

objArray :: [JSAny] -> IO JSAny
objArray objs = do
    arr <- jsNewArray
    forM_ objs $ jsObjArrayPush arr
    return arr

strObj :: [(JSString, JSString)] -> IO JSAny
strObj assoc = do
    obj <- jsNewObject
    forM_ assoc $ uncurry (jsStrSet obj)
    return obj

setPhones :: JSAny -> IO ()
setPhones scope = do
    phones <- mapM strObj phoneList
    sequence . getZipList $ flip jsNumSet "age" 
        <$> ZipList phones <*> ZipList [1,2,3]
    objArray phones >>= jsObjSet scope "phones"
    jsStrSet scope "orderProp" "age"
  where
    phoneList =
        [ [("name", "Nexus S"), ("snippet", "Fast just got faster")]
        , [("name", "Motorola XOOM Wifi"),("snippet", "Next Generation")]
        , [("name", "Motorola XOOM") ,("snippet", "Next Generation")]
        ]

main = do
    export "setPhones" setPhones

