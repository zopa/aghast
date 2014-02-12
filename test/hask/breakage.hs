{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

-- Stuff that breaks, for reasons unknown. Worth investigating further.

import Control.Monad
import Haste.Ajax
import Haste.Foreign
import Haste.Prim
import Unsafe.Coerce

------------------------------------------------------------------------
-- Standard functionality; seems to work, but needed for what follows.
-- This stuff really ought to be in a library, and will be when I
-- clarify for myself the details of how Haste wraps cabal, etc.

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
foreign import ccall jsParseJSON :: JSString -> IO JSAny

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


-----------------------------------------------------------------------
-- This seems to end up assigning the Haste representation of an array
-- of objects to scope.phones, rather than the literal array.
--
-- My suspicion is that my instance breaks down for structures more than 
-- one level deep. It seems to work if you cross the boundary "one level
-- at a time"; but here we're creating a whole big structure in 
-- JS-land, and trying to pull it across. Doing one level at a time
-- probably enforces that we have pointers within pointers, rather 
-- than a value within a pointer.
setPhones :: JSAny -> JSAny -> IO ()
setPhones scope _ = do
    textRequest_ GET "/phones/phones.json" [] $ maybe (return ())
        $ jsParseJSON >=> jsObjSet scope "phones"
    jsStrSet scope "orderProp" "age"

main = do
    export "setPhones" setPhones

