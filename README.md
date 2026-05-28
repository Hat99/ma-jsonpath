# JSONPath-Schnittstelle für NoSQL-Datenbanken
## Masterarbeit von Paul Mayr (77868) an der Hochschule Aalen

Dieses Repository enthält den im Rahmen meiner Masterarbeit erarbeiteten JSONPath-Compiler (flex + Bison) und die Ausarbeitung. 

Um den Compiler zu verwenden, kann dieser über das Makefile compiliert werden und ist anschließend als "exec" ausführbar.

# Kurzanleitung Compiler

Der Aufruf des Compilers erfolgt über `./exec` und kann als Parameter Flags und JSONPath-Ausdrücke annehmen.

Es können beliebig viele JSONPath-Ausdrücke im Aufruf angegeben werden, die der Reihe nach geparsed werden. Wird kein Ausdruck mitgegeben, startet der Compiler interaktiv mit einer Eingabemaske, die über `quit` oder `exit` verlassen werden kann.

Flags:
    `-debug` oder `-d`:         Aktiviert Bison-Debug-Ausgaben
    `-run-tests` oder `-rt`:    Führt automatisierte Compiler-Tests aus und beendet den Compiler anschließend
    `-verbose` oder `-v`:       Aktiviert Bison parserVerbose Option
    `-visualize` oder `-vis`:   Erstellt über Bison-Syntaxtree-Hack-Visualisierung PDFs der geparsten Syntaxbäume



# Repository Aufbau

Das Repository enthält das C++-Projekt `JSONPath-Compiler` (als XCode Ordner, für die Ausführung kann der Umordner ignoriert werden), die Ausarbeitung als PDF und als LaTeX-Quelle `Dokumentation`, eine Aufführung der verwendeten Code-Quellen und diese Readme-Datei.
