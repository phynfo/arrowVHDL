\section{Standard Schaltkreise}
\label{src:Circuit.Graphs}

Dieser Abschnitt stellt einige Standard-Schaltkreise vor. Diese können als Grundlage für komplexere Schaltkreise herangezogen werden. 

\begin{code}
  module Circuit.Graphs
  where
\end{code} 

\par 
Verwendet wird ausschließlich das Modul \ref{mod:Circuit.Graphs} (\hsSource{Circuit.Descriptor}).


\begin{code}
  import Circuit.Descriptor
\end{code} 

\subsection{Leerer Schaltkreis}
Zunächst wird ein leerer Schaltkreis definiert, also ein Datum des Types \hsSource{CircuitDescriptor}. Dieses Datum enthält zwar die
korrekte Struktur, aber keine Nutzdaten. \hsSource{String}s sind leer \footnote{der \hsSource{String} ``...'' ist für das Debugging bewusst
nicht leer}, \hsSource{Integer} werden auf $0$ gesetzt und Listen sind jeweils leere Listen.

\par 
Da ein \hsSource{CircuitDescriptor} auch aus einem \hsSource{NodeDescriptor} aufgebaut ist, liegt es auf der Hand, auch einen leeren
\hsSource{NodeDescriptor} zu definieren. 


\begin{code}
  emptyNodeDesc :: NodeDescriptor
  emptyNodeDesc 
    = MkNode { label   = "..."
             , nodeId  = 0
             , sinks   = []
             , sources = []
             }
\end{code} 


\par
Der leere Schaltkreis lässt sich jetzt über den leeren \hsSource{NodeDescriptor} beschreiben.

\begin{code}
  emptyCircuit :: CircuitDescriptor
  emptyCircuit 
    = MkCombinatorial
      { nodeDesc = emptyNodeDesc
      , nodes   = []
      , edges   = []
      , cycles  = 0
      , space   = 0
      }
\end{code} 

\subsection{Schaltkreis Modifikatoren}
Neben der leeren Schaltung werden weitere Schaltungen benötigt, die größtenteils Unterschiede im Namen und in der Anzahl der Ein- und
Ausgängen haben. Diese könnte man definieren, indem die Beschreibung der leeren Schaltung an den entsprechenden Stellen überschrieben wird.
Schöner ist es allerdings, wenn man hier auf Modifikatoren zurückgreifen kann, welche die Aufgabe übernehmen. Bei Änderungen an der
\hsSource{CircuitDescriptor} Struktur müssen dann nur die Modifikatoren verändert werden, nicht aber sämtliche Schaltungsdefinitionen. 


\begin{code}
  withLabel :: String -> CircuitDescriptor -> CircuitDescriptor
  withLabel l cd   = cd { nodeDesc = nd { label = l } }
    where nd = nodeDesc cd

  sinkCount :: Int -> CircuitDescriptor -> CircuitDescriptor
  sinkCount i cd   = cd { nodeDesc = nd { sinks = [0..(i-1)] } }
    where nd = nodeDesc cd

  sourceCount :: Int -> CircuitDescriptor -> CircuitDescriptor
  sourceCount i cd = cd { nodeDesc = nd { sources = [0..(i-1)] } }
    where nd = nodeDesc cd
\end{code} 

\par
Mithilfe der Modifikatoren lassen sich nun die weiteren Schaltkreise definieren: 

\begin{code}
  arrCircuit 
    = withLabel "-ARR-" . sinkCount 1 . sourceCount 1 $ emptyCircuit

  throughCircuit 
    = withLabel "(-)"   . sinkCount 1 . sourceCount 1 $ emptyCircuit

  idCircuit 
    = withLabel "-ID-"  . sinkCount 1 . sourceCount 1 $ emptyCircuit

  leftCircuit
    = withLabel "(L)"   $ emptyCircuit

  rightCircuit
    = withLabel "(R)"   $ emptyCircuit
\end{code} 
