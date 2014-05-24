Wahl-o-mat Visualisierung
=========================


1. Schritt: Bestimmung des Verhältnisses zwischen Parteien
----------------------------------------------------------

Zuerst wurden die Antworten ins CSV Format gebracht, damit sie leichter weiterverarbeitet werden können. Dafür gibt es im Moment keinen automatischen Prozess. Die Ergbisdateien liegen allerdings im Repository.

Wenn zwei Parteien zur gleichen Frage unterschiedliche Antworten geben, dann könnte dies ein Hinweis darauf sein, dass diese beiden Parteien unterschiedliche Politik machen. Auf jeden Fall lässt sich die Differenz zwischen den Antwortverhalten der Parteien sehr einfach messen. Wenn eine Ablehnung auf eine Zustimmung trifft, gibt es 2 Differenzpunkte; wenn eine Antwort Neutral ist, dann 1 Differenzpunkt und bei gleicher Antwort 0. Der Code zum Bestimmen der Differenz zweier Parteien steht unter der [MIT X11 Lizenz](http://www.opensource.org/licenses/mit-license.php).

2. Schritt: Berechnen einer Karte aus den Rohdaten
--------------------------------------------------

Danach wurden die Daten mithilfe der Neato-Engine von [Graphviz](http://www.graphviz.org/) visualisiert. Der Code zur Generierung des Graphen ist in der Datei ``render.rb``, somit kann sich also jeder selbst seine Karte generieren um zum Beispiel bestimmte Parteien aus der Karte zu entfernen oder sich von der ordnungsgemäßen Durchführung zu überzeugen.

Die Kreise sind die Parteien und die Linien spiegeln die Beziehungen der Parteien wieder, wobei längere Linien für größere Unterschiede im Antwortverhalten der Parteien auf Wahl-o-mat stehen. Die Interpretation der Grafik überlasse ich jedem selbst.

3. Beispiele
------------

- Bundestagswahl 2009: `./render.rb btw2009.csv`
- Bundestagswahl 2013: `./render.rb btw2013.csv`
- Europawahl 2014: `./render.rb euro2014.csv`
