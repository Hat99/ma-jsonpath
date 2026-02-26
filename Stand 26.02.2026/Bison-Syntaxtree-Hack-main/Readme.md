# Der BISON Syntraxtree Hack

Der Hack ermöglicht ein vollautomatisches Erzeugen eines Syntaxbaums ohne dedizierten Programmcode im Parser. Die zu grunde liegende Template-Klasse tree (Datei tree.hpp) ermöglicht flexibel die Ausgestaltung des Baums. Im einfachsten Fall (Beispiel 2) wird ein Baum aus Strings aufgebaut.

Damit der Hack funktioniert muss folgendes beachtet werden:
- Es muss die richtige Version in der BISON-Direktive initial-action includiert werden!
- Es nmuss ein Datentyp "syntaxTree" existieren, egal ob per typedef aus der Templateklasse oder als echte Klasse
- Die Bison-Union muss mindestens einen syntaxTree-Zeiger mit Namen tree enthalten:
```
%union {syntaxTree * tree;}
```
- Es muss eine globale Variable root existieren
```
syntaxTree * root
```
- Es muss eine Funktion für das Epsilon-Token existieren:
```
syntaxTree * syntaxTree_epsilon_node () {
```
die einen Epsilon-Knoten oder die (falls die Epsilon-Knoten im Baum nicht existieren sollen) den Nullzeiger zurückliefert
- Der Scanner muss über die tree-Property der union einen einen Blattknotenzeiger zurückliefern. Entweder ist das originalen Scanner zu codieren oder (wegen der Wiedervendbarkeit) eine Wrapper-Funktion zwischen Parser und eigentlichem Scanner zu codieren (siehe Beispiele):
```
int yylex() {
	int rc = yylex_2();
	yylval.tree = new syntaxTree(yytext);
	return rc;
}
```

