\long\def\ignore#1{}

\ignore{
\begin{code}
  {-# LANGUAGE Arrows,
               OverlappingInstances, 
               UndecidableInstances,
               IncoherentInstances,
               NoMonomorphismRestriction,
               MultiParamTypeClasses,
               FlexibleInstances,
               RebindableSyntax #-}
\end{code}
}

\subsection{Instanzdefinitionen für Grid}
\label{mod:Circuit.Grid.Instance}

Das Modul \hsSource{Circuit.Grid.Instance} beschreibt, wie die Arrow-Instanzen des Grid-Datentypes implementiert werden.

\begin{code}
  module Circuit.Grid.Instance
  where
\end{code}


\par
Folgenden Module werden benötigt, um die Arrows definieren zu können:

\begin{code}
  import Circuit.Grid.Datatype

  import Circuit.Descriptor
  import Circuit.Graphs
  import Circuit.Workers (flatten)
  import Circuit.ShowType

  import Prelude hiding (id, (.))
  import qualified Prelude as Pr
  
  import Control.Category 

  import Circuit.Arrow

  import Circuit.Splice
\end{code}


\subsection{Grid ist eine Kategorie}
Bevor für den Typ \hsSource{Grid} eine Arrow-Instanz implementiert werden kann, muss \hsSource{Grid} Mitglied der Typklasse
\hsSource{Category} sein. 

\begin{code}
  instance (Arrow a) => Category (Grid a) where
    id              
      = id

    GR (f, cd_f) . GR (g, cd_g) 
      = GR $ (f . g, cd_g `connect` cd_f)
\end{code}


\par
Im nächsten Schritt wird dann die Arrow-Instanz von \hsSource{Grid} implementiert. Laut Definition ist ein Arrow vollständig definiert durch
die Funktionen \hsSource{arr} und \hsSource{first}. Alle weiteren Funktion lassen sich aus diesen beiden ableiten. Da hier aber die
Kontrolle über die Implementierung jeder Funktion behalten werden soll, ist hier eine Implementation für alle einzel-Funktionen gegeben.

\begin{code}
  instance (Arrow a) => Arrow (Grid a) where
    arr   f       
      = GR $ (arr f, showType f)
  
    first (GR (f, cd_f))
      = GR ( first f
           , cd_f `combine` idCircuit
           )
  
    second (GR (g, cd_g))
      = GR ( second g
           , idCircuit `combine` cd_g
           )
  
    GR (f, cd_f) &&& GR (g, cd_g) 
      = GR ( f &&& g
           , cd_f `combine` cd_g
           )
  
    GR (f, cd_f) *** GR (g, cd_g) 
      = GR ( f *** g
           , cd_f `combine` cd_g
           )
\end{code}


\par
Die Definition von \hsSource{ArrowLoop} ist dann notwendig, wenn Schleifen abgebildet werden sollen. Hierzu ist die Implementation einer
einzigen Funktion notwendig, nämlich der \hsSource{loop :: a (b, d) (c, d) -> a b c} notwendig.

%%% TODO : Ersetzte diese Hardcoding version in eine, die vielleicht ein wenig vergebender ist ;) 

\begin{code}
  instance (ArrowLoop a) => ArrowLoop (Grid a) where
    loop (GR (f, cd_f)) = GR (loop f, loopWithRegister cd_f)
\end{code}


%%% \par 
%%% Um den \hsSource{Grid}-Arrow zu \hsSource{ArrowChoice} hinzufüge, so ist die Implementierung von \hsSource{ArrowChoice} für \hsSource{Grid}
%%% notwendig. 
%%% 
%%% \begin{code}
%%%   instance (Arrow a) => ArrowChoice (Grid a) where
%%%       left  f = f      +++ arr id
%%%       right g = arr id +++ g 
%%%       f +++ g = (Left . f) ||| (Right . g)
%%%       f ||| g = either
%%% \end{code}


\par
Zu dem \hsSource{Grid}-Arrow gehört außerdem noch eine Funktion, die den \hsSource{Grid}-Typ auspacken kann und dann ``ausführen'' kann.

\begin{code}
  runGrid :: (Arrow a) => Grid a b c -> a b c
  runGrid (GR (f, _)) = f
\end{code}
