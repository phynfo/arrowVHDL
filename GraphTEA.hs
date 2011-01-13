{-# LANGUAGE Arrows, FlexibleContexts #-}
module GraphTEA where

import Control.Arrow
import Data.Bits (xor, shiftL, shiftR)

import GraphTraversal

oneNodeGraph :: String -> StructGraph
oneNodeGraph s = MkSG [(MkNode s [] [] 0)] [] [] []

aId :: (Arrow a) => TraversalArrow a b b
aId = augment_f_SG (id) (oneNodeGraph "ID")

-- aId :: (Arrow a, Augment (b -> b) StructGraph a b b) => TraversalArrow a (b) (b)
-- aId =  augment ((id) :: b -> b) def
--     where def = oneNodeGraph "ID"

-- aXor :: (Arrow a) => TraversalArrow a (Int, Int) (Int)
-- aXor =  augment def (uncurry xor)
--     where def = oneNodeGraph "XOR"
-- 
-- aShiftL :: (Arrow a) => TraversalArrow a (Int, Int) (Int)
-- aShiftL =  augment def (uncurry shiftL)
--     where def = oneNodeGraph "SHIFT_L"
-- 
-- aShiftR :: (Arrow a) => TraversalArrow a (Int, Int) (Int)
-- aShiftR =  augment def (uncurry shiftR)
--     where def = oneNodeGraph "SHIFT_R"
-- 
-- aAdd :: (Arrow a) => TraversalArrow a (Int, Int) (Int)
-- aAdd =  augment def (uncurry (+))
--     where def = oneNodeGraph "ADD"
-- 
-- aFlip :: (Arrow a) => TraversalArrow a (b, c) (c, b)
-- aFlip =  augment def (\(x, y) -> (y, x))
--     where def = oneNodeGraph "FLIP"


-- aShiftL4addKey :: (Arrow a) => TraversalArrow a (ValChunk, KeyChunk) Int
-- aShiftL4addKey =  augment def f 
--     where def = emptyGraph { name = "SHIFT_L4_ADD_KEY" }
--           (TR shiftL) = aShiftL
--           (TR add)    = aAdd
--           f           = TR $ proc ((v, k), t) -> do
--                                (x_shl, t') <- shiftL -< ((v, 4), t)
--                                (x', t'')   <- add    -< ((k, x_shl), t')
--                                returnA               -< (x', t'')
-- 
-- 
-- aShiftR5addKey :: (Arrow a) => TraversalArrow a (ValChunk, KeyChunk) Int
-- aShiftR5addKey =  augment def f
--     where def         = emptyGraph { name = "SHIFT_R5_ADD_KEY" }
--           (TR shiftR) = aShiftR
--           (TR add)    = aAdd
--           f           = TR $ proc ((v, k), t) -> do
--                                (x_shr, t') <- shiftR -< ((v, 5), t)
--                                (x', t'')   <- add    -< ((k, x_shr), t')
--                                returnA               -< (x', t'')
-- 
-- aAddMagic :: (Arrow a) => TraversalArrow a ValChunk Int
-- aAddMagic =  augment def f
--     where def      = emptyGraph { name = "ADD_MAGIC" }
--           (TR add) = aAdd
--           f        = TR $ proc (x, t) -> do
--                             (z, t') <- add -< ((x, 2654435769), t)
--                             returnA        -< (z, t')
-- 
-- 
-- type KeyChunk = Int
-- type ValChunk = Int
-- type Key   = (KeyChunk, KeyChunk, KeyChunk, KeyChunk)
-- type KeyHalf = (KeyChunk, KeyChunk)
-- type Value = (ValChunk, ValChunk)
-- 
-- -- feistelRound_a :: (Arrow arr) => arr ((ValChunk, ValChunk), (KeyChunk, KeyChunk)) (ValChunk, ValChunk)
-- -- feistelRound_a =  
-- --     arr (\((p0, p1), (k0, k1)) 
-- --          -> ( p0
-- --             , ( ( ( shiftL4addKey_a (p1, k0)
-- --                   , addMagic_a p1
-- --                   )
-- --                 , shiftR5addKey_a (p1, k1)
-- --                 )
-- --               , p1
-- --               )
-- --             )
-- --         )
-- --     >>> arr id *** ((xor_a *** arr id) *** arr id) 
-- --     >>> arr id ***  (xor_a             *** arr id) 
-- --     >>> arr (\(p0, (tmp, p1)) -> ((p0, tmp), p1))
-- --     >>> add_a                          *** arr id
-- 
-- -- cycle_a :: (Arrow arr) => arr (Key, Value) (Value)
-- -- cycle_a =  
-- --     arr (\((k0, k1, k2, k3), (p0, p1)) 
-- --         -> (((p0, p1), (k0, k1)), (k2, k3)))
-- --     >>> feistelRound_a *** arr id
-- --     >>> feistelRound_a
-- -- 
-- -- feistelRound :: (Arrow a) => a (Value, KeyHalf) Value
-- -- feistelRound = proc ((p0, p1), (k0, k1)) -> do
-- --     tmp1 <- shiftL4addKey_a -< (p1, k0)
-- --     tmp2 <- addMagic_a     -< p1
-- --     tmp3 <- shiftR5addKey_a -< (p1, k1)
-- -- 
-- --     tmp4 <- xor_a -< (tmp1, tmp2)
-- --     tmp5 <- xor_a -< (tmp4, tmp3)
-- -- 
-- --     erg0 <- returnA -< p1
-- --     erg1 <- add_a -< (p0, tmp5)
-- -- 
-- --     returnA -< (erg0, erg1)
--    
-- aFeistelRound :: (Arrow a) => TraversalArrow a ((ValChunk, ValChunk), (KeyChunk, KeyChunk)) (ValChunk, ValChunk)
-- aFeistelRound = augment def feistelRound
--     where def = emptyGraph { name = "FEISTEL_ROUND" }
--           
-- feistelRound :: (Arrow a) => TraversalArrow a ((ValChunk, ValChunk), (KeyChunk, KeyChunk)) (ValChunk, ValChunk)
-- feistelRound = TR $ proc (((p0, p1), (k0, k1)), t0) -> do
--                       (tmp1, t1) <- _shiftL4addKey -< ((p1, k0), t0)
--                       (tmp2, t2) <- _addMagic      -< (p1, t1)
--                       (tmp3, t3) <- _shiftR5addKey -< ((p1, k1), t2)
--                     
--                       (tmp4, t4) <- _xor           -< ((tmp1, tmp2), t3)
--                       (tmp5, t5) <- _xor           -< ((tmp4, tmp3), t4)
--                      
--                       (erg0, t6) <- returnA        -< (p1, t5)
--                       (erg1, t7) <- _add           -< ((p0, tmp5), t6)
--                      
--                       returnA                     -< ((erg0, erg1), t7)
--     where def = emptyGraph { name = "FEISTEL_ROUND" }
--           (TR _shiftL4addKey) = aShiftL4addKey
--           (TR _shiftR5addKey) = aShiftR5addKey
--           (TR _addMagic)      = aAddMagic
--           (TR _xor)           = aXor
--           (TR _add)           = aAdd
--           
-- -- cycle :: (Arrow a) => a (Key, Value) Value
-- -- cycle = proc ((k0, k1, k2, k3), (p0, p1)) -> do
-- --     tmp <- feistelRound -< ((p0, p1), (k0, k1))
-- --     erg <- feistelRound -< (tmp     , (k2, k3))
-- --     returnA -< erg
--     
