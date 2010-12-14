{-# LANGUAGE Arrows #-}
{-# OPTIONS_GHC -fglasgow-exts #-}

module Traversal.Traversal 
    ( runTraversal
    , runTraversal_
    , TraversalArrow (..)
    , saugment
    , saugmentStruct
    , saugmentStructFunct
    , saugmentTraversal
    , saugmentSubcomponent

    , emptyStructure
    )
where

import Prelude hiding (id, (.))

import Control.Category
import Control.Arrow
import Control.Arrow.Transformer

import Traversal.Structure
import Traversal.Auxillary


newtype TraversalArrow a b c = TR (a (b, Structure) (c, Structure))

instance (Category a, Arrow a) => Category (TraversalArrow a) where
    id              = TR id
    (TR f) . (TR g) = TR $ proc (x, t) -> do
                             (x', t_g) <- g -< (x,  t)
                             (y,  t_f) <- f -< (x', t_g `with_predecessor` t  )
                             returnA        -< (y,  t_f `with_predecessor` t_g)

instance (Arrow a) => Arrow (TraversalArrow a) where
    arr f        = TR (arr (\(x, _) -> (f x, emptyStructure)))
    first (TR f) = TR (arr swapsnd >>> first f >>> arr swapsnd)
     where swapsnd ((x, y), t) = ((x, t), y)
    (TR f) *** (TR g) = TR $ proc ((x, y), t) -> do
                            (x', t_f) <- f -< (x,    t)
                            (y', t_g) <- g -< (y,    t) 
                            returnA        -< ((x', y'), outroStructure `with_predecessors` ([t_g, t_f]))
                        
instance (Arrow a) => ArrowTransformer (TraversalArrow) a where
    lift f = TR (first f)

runTraversal :: (Arrow a) => TraversalArrow a b c -> a (b, Structure) (c, Structure)
runTraversal (TR f) = f

--runTraversal_ f x = runTraversal f (x, finalStructure)
runTraversal_ f x = runTraversal f (x, emptyStructure)



saugment  :: (Arrow a) => a () Structure -> a b c -> TraversalArrow a b c
saugment aT aA 
    = TR $ proc (x, t) -> do 
        t' <- aT -< ()
        x' <- aA -< x
        returnA  -< (x', t')

saugmentStruct :: (Arrow a) => Structure -> a b c -> TraversalArrow a b c
saugmentStruct t  
    = saugment $ arr (\_ -> t)

saugmentStructFunct :: (Arrow a) => Structure -> (b -> c) -> TraversalArrow a b c
saugmentStructFunct t f  
    = saugmentStruct t $ (arr f)

saugmentTraversal :: (Arrow a) => Structure -> TraversalArrow a b c -> TraversalArrow a b c
saugmentTraversal s (TR f) 
    = TR $ proc (x, t) -> do
        (x', _) <- f -< (x,  t)
        returnA      -< (x', s)

saugmentSubcomponent :: (Arrow a) => Structure -> TraversalArrow a b c -> TraversalArrow a b c
saugmentSubcomponent s@(Annotate { predecessor = Left p }) (TR f)
    = TR $ proc (x, t) -> do
        (x', t') <- f -< (x,  t)
        returnA       -< (x', s { predecessor = Right p } `with_predecessor` t')



-- do i really need this older version ??? 
saug  :: (Arrow a) => a b Structure -> a b c -> TraversalArrow a b c
saug t a =   (lift a) &&& (lift t >>> store)
         >>> drop_second
    where store = TR (arr(\(t, _) -> ((), t)))






testStructure = emptyStructure { name = " " }

outroStructure = emptyStructure { name         = "Outro"
                                , formatstring = "%o1, %o2 <= %i1" 
                                , inputs       = [ "pin" ]
                                , output       = "out"
                                }

finalStructure = emptyStructure { name         = "Final"
                                , formatstring = "%i1" 
                                , inputs       = [ "pin" ]
                                }

emptyStructure = Annotate { name         = ""
                          , returnvalue  = Nothing
                          , formatstring = "" 
                          , inputs       = []
                          , output       = ""
                          , predecessor  = Left []
                          }


