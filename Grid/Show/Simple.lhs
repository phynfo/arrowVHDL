> module Grid.Show.Simple
> ( showCircuit
> , showEdge
> )
> where

> import Grid.Core

> showCircuit :: Circuit -> String
> showCircuit g =  "\n"
>             ++ (show.compID) g
>             ++ "(" ++ (show.label) g ++ "): "
>             ++ (prtInOuts.sinks) g ++ "] "
>             ++ (showEdges.edges) g
>             ++ " [" ++ (prtInOuts.sources) g
>             ++ (showNode.nodes) g
>          where showNode [] = ""
>                showNode n  = concat $ map showCircuit n
>                prtInOuts [] = "_"
>                prtInOuts x  = foldl1 (\x y -> x ++ ',':y) $ map show x


> showEdge :: Edge -> String
> showEdge ed = (prtConnection.sourceInfo) ed ++ "->" ++ (prtConnection.sinkInfo) ed
>       where prtConnection (Just cid, pid) = show (cid, pid)
>             prtConnection (Nothing,  pid) = "(_," ++ show pid ++ ")"


> showEdges :: [Edge] -> String
> showEdges = concat . (map showEdge)
