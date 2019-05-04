Wahl-o-mat Visualisierung
=========================

Wenn zwei Parteien zur gleichen Frage unterschiedliche Antworten geben,
dann könnte das ein Hinweis darauf sein, dass diese beiden Parteien
unterschiedliche Politik machen. Mithilfe des [Wahl-o-mats](http://www.wahlomat.de/), lässt sich
diese Differenz nun sehr einfach messen und als zweidimensionaler Graph visualisieren.

Schritt 1: Bestimmung des Verhältnisses zwischen Parteien
---------------------------------------------------------

Die alte Version der Visualisierung erforderte die Wahl-o-mat-Antworten der Parteien im CSV Format.

Die neue Version nutzt nun die Daten im GitHub Repository 
[qual-o-mat-data](https://github.com/gockelhahn/qual-o-mat-data/).
Wenn eine Ablehnung auf eine Zustimmung trifft, gibt es 2 Differenzpunkte;
wenn eine Antwort Neutral ist, dann 1 Differenzpunkt und bei gleicher Antwort 0.
Hierbei haben alle Antworten das gleiche Gewicht.

Schritt 2: Erstellung der zweidimensionalen Visualisierung
----------------------------------------------------------

Die Abstände im Antwortverhalten der Parteien können nunr mithilfe der Neato-Engine von
[Graphviz](http://www.graphviz.org/) visualisiert werden. Der Code zur Generierung des
Graphen ist in der Datei ``render.rb``, somit kann sich also jeder selbst seine Karte
generieren um zum Beispiel bestimmte Parteien aus der Karte zu entfernen oder sich
von der ordnungsgemäßen Durchführung zu überzeugen.

Die Parteien sind hierbei als Kreise/Graphknoten repräsentiert und die Linien spiegeln
die Beziehungen der Parteien wieder, wobei längere Linien für größere Unterschiede
im Antwortverhalten der Parteien auf Wahl-o-mat stehen.
Die Interpretation der Grafik ist jedem selbst überlassen.

Nutzung
-------

```
usage: render.py [-h] [-n NEATO] [-o OUTPUT] [-v] data

Visualize wahl-o-mat data.

positional arguments:
  data                  Path to data in github.com/gockelhahn/qual-o-mat-data
                        repository (e.g. 2019/europa)

optional arguments:
  -h, --help            show this help message and exit
  -n NEATO, --neatopath NEATO
                        Path to neato executable (default: "neato")
  -o OUTPUT, --output OUTPUT
                        Destination for generated visualization
                        (default: "wahlomat.png")
  -v, --verbose         Increase output verbosity
```
Beispiele
---------

- Bundestagswahl 2017: `./render.py 2017/deutschland`

![Bundestagswahl 2017](https://chris-schuster.net/node/330/btw2017.png)

Rechte
------

Der Code zum Bestimmen der Differenz zweier Parteien und erstellung der Visualisierung
steht unter der [MIT X11 Lizenz](http://www.opensource.org/licenses/mit-license.php).
Die Daten stammen aus
[https://github.com/gockelhahn/qual-o-mat-data/](https://github.com/gockelhahn/qual-o-mat-data/).

Referenzen
----------

Diese Visualisierung wurde 2018 Teil von *Coalizer*, was auf der ECPR vorgestellt wurde.
Siehe auch das [Paper](https://ecpr.eu/Events/PaperDetails.aspx?PaperID=41926&EventID=115)
dazu von Robin Graichen.
