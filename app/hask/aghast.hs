{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Main where

import Control.Applicative
import Control.Monad
import Haste
import Haste.Ajax
import Haste.Foreign
import Haste.JSON
import Haste.Prim
import Unsafe.Coerce

instance Marshal JSAny where
    pack = toPtr . unsafeCoerce
    unpack = unsafeCoerce . fromPtr

foreign import ccall jsStrSet :: JSAny -> JSString -> JSString -> IO () 
foreign import ccall jsObjSet :: JSAny -> JSString -> JSAny -> IO ()
foreign import ccall jsNumSet :: JSAny -> JSString -> Double -> IO ()
foreign import ccall jsBoolSet :: JSAny -> JSString -> Bool -> IO ()
foreign import ccall jsStrArrayPush :: JSAny -> JSString -> IO () 
foreign import ccall jsNumArrayPush :: JSAny -> Double -> IO () 
foreign import ccall jsBoolArrayPush :: JSAny -> Bool -> IO () 
foreign import ccall jsObjArrayPush :: JSAny -> JSAny -> IO () 
foreign import ccall jsNewArray :: IO JSAny
foreign import ccall jsNewObject :: IO JSAny
foreign import ccall jsCallMethod :: JSAny -> JSString -> JSString -> IO JSAny
foreign import ccall jsCallCBMethod :: JSAny -> JSString -> JSFun a -> IO JSAny

foreign import ccall jsSetFun :: JSAny -> JSString -> JSFun a -> IO () 

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

assignJSON :: JSON -> IO JSAny -- See Note: [Traversable JSON?]
assignJSON = \case 
    Arr jsons -> do
        arr <- jsNewArray
        go arr `mapM_` jsons
        return arr
    Dict jsons -> do
        o <- jsNewObject
        goObj o `mapM_` jsons
        return o
    _ -> error "The top level JSON must be an array or an object" 
  where
    go a (Num n) = jsNumArrayPush a n
    go a (Str s) = jsStrArrayPush a s
    go a (Bool b) = jsBoolArrayPush a b
    go a (Arr xs) = do
        a' <- jsNewArray
        forM_ xs $ go a'
        jsObjArrayPush a a'
    go a (Dict ls) = do
        o <- jsNewObject 
        forM_ ls $ goObj o
        jsObjArrayPush a o
    
    goObj :: JSAny -> (JSString, JSON) -> IO ()
    goObj o (k, Num n)  = jsNumSet o k n
    goObj o (k, Str s)  = jsStrSet o k s
    goObj o (k, Bool b) = jsBoolSet o k b
    goObj o (k, Arr vs) = do
        a'' <- jsNewArray
        forM_ vs $ go a''
        jsObjSet o k a''
    goObj o (k, Dict vs) = do
        o'  <- jsNewObject
        forM_ vs $ goObj o'
        jsObjSet o k o'
    
--------------------------------------------------------------------
-- Note: Traversable JSON ?
--------------------------------------------------------------------
-- The by-hand treewalking in assignJSON is a bit painful.
-- It seems like it ought to be Traversable, but of course it's not:
-- it's not paramterized by anything.
--
-- But we might be able to make it one, if we separate out the
-- data-structure part from the value part. We'd have a type
--
-- data JSPrimitive = Num n | Str s | Bool b | Null
-- 
-- representing pure values. Then the data structure bit is
-- just a tree with two sorts of branches, tagged and untagged:
--
-- data JSTree a = Arr [JSTree a] 
--               | Dict [(JSString, JSTree a)]
--               | Val a
--
-- JSTree ought to be a Functor, Traversable, etc. A JSON value, or
-- really any Javascript value, would just be
-- 
-- type JS = JSTree JSPrimitive
-- 
-- Surely someone's done this already? If not, is there something
-- wrong with it?
--------------------------------------------------------------------

setPhones :: JSAny -> JSAny -> IO ()
setPhones scope http = do
    service <- jsCallMethod http "get" "/phones/phones.json"
  --  test <- strObj [("name", "Andromeda") ,("snippet", "A galaxy") ,("age", "1")]
    jsCallCBMethod service "success" . mkCallback $ 
         jsObjSet scope "phones"
        -- \_ -> jsObjSet scope "phones" =<< objArray [test]
    jsStrSet scope "orderProp" "age"

main = do
    export "setPhones" setPhones

