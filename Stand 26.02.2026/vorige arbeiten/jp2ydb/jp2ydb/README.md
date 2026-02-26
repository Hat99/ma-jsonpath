# jp2ydb — JSONPath → YottaDB (read‑only) CLI

Ein kleines CLI‑Werkzeug, das einen **klar abgegrenzten JSONPath‑Teilumfang** parst und in **YottaDB**‑Global‑Referenzen übersetzt. Die Abfrage wird in einem YottaDB‑Docker‑Container über eine schlanke M‑Routine (`JPBRIDGE.m`) **nur lesend** ausgeführt.

> Kurzfassung
>
> ```bash
> ./build.sh               # baut nach bin/jp2ydb
> ./run_ydb.sh             # startet den YottaDB-Container interaktiv im aktuellen Terminal. 
> JP_BRIDGE_FILE=src/JPBRIDGE.m \
> YDB_CONTAINER=ydb \
> bin/jp2ydb -ar '$.bicycle.color'
> ```

---

## Features

* **Scanner/Parser** mit **Flex/Bison**.
* **AST**‑Struktur; Ausgabe mit `-a`.
* **Deterministisches Mapping** vom unterstützten JSONPath zu YottaDB‑Referenzen.
* **Reine Lesezugriffe** via `JPBRIDGE.m` im Container; das CLI schreibt nicht.
* Klare Trennung der Verantwortlichkeiten:

  * *Lexing/Parsing* → JSONPath-Tokenisierung und Aufbau des AST
  * *Mapping* → YDB‑Referenz
  * *Bridge* → Ausführung im Container, Ergebnis‑Marker auf stdout

## Unterstützter JSONPath‑Teilumfang

**Unterstützt**

* Wurzel: `$`
* Punkt-Notation: `$.bicycle.color`  
* String-Key in Klammern: `$["bicycle"]["price"]`  
* Ganzzahl-Index: `$.book[0].title`  
    (**0-basiert in JSONPath → 1-basiert in YottaDB**)


**(Noch) nicht unterstützt**
(führt zu klaren Parse‑Fehlern)

* Rekursiver Abstieg `..`
* Wildcards `.*` / `[*]`
* Slices `[a:b]`, `[a:b:c]`
* Filter `?()`
* Unions `[a,b]`
* Negative Indizes

**Typregeln**

* `$` wird **nicht** als Subskript materialisiert.
* `.name` und `["name"]` werden **String‑Subskripte**.
* `[INT]` wird **numerisches** Subskript mit Offset `+1` (z. B. `[0] → 1`).
* `"1"` ist ein **String‑Key**, **nicht** der Index `1`.

> **Hinweis (Root-Konvention):**  
> Das Root-Global wird mit `-g NAME` gesetzt (z. B. `-g store`) ist standard.  
> JSONPath-Ausdrücke sind **relativ** zu diesem Root anzugeben, z. B.  
> `$.book[0].title` → `^store("book",1,"title")`.  
> Ein zusätzliches `.store` im Pfad würde zu `^store("store",...)` führen und **nicht** passen.


## Architektur

```
JSONPath → [Flex] Token → [Bison] AST → Mapper → "^root(…)" → JPBRIDGE.m → $DATA/$GET → stdout
```

**Marker‑Protokoll von JPBRIDGE.m** (vom CLI ausgewertet):

* `JP:D:<code>` — Ergebnis von `$DATA(@ref)` (0 | 1 | 10 | 11)
* `JP:V:<value>` — `$GET(@ref)` falls vorhanden
* (optionale Erweiterung) unmittelbare Kinder: `JP:K:<key>` gefolgt von `JP:V:<value>`

## Voraussetzungen

* GCC/Clang, **Flex**, **Bison**
* Linux/macOS (unter macOS ggf. mit `-ll` statt `-lfl` linken)
* Docker (für den YottaDB‑Container)

## Build

Out‑of‑Source‑Build mit dem mitgelieferten Script:

```bash
chmod +x build.sh
./build.sh          # Release
./build.sh debug    # Debug‑Symbole
./build.sh clean    # löscht build/ und bin/
```

Artefakte:

* `build/` — Objekte & generierte Dateien (`parser.tab.c/.h`, `lex.yy.c`)
* `bin/jp2ydb` — fertiges CLI

> Debian/Ubuntu: Falls der Linker `-lfl` nicht findet → `sudo apt install libfl-dev`.

### Alternative: Makefile (In‑Place‑Build)

Das Makefile funktioniert ebenfalls. Achte darauf, dass die Include‑Pfade zur aktuellen Struktur (`src/`, `src/lib/`) passen.

## Projektstruktur

```
.
├── bin/
│ └── jp2ydb        
├── build/          
│ ├── parser.tab.c / .h / .o
│ ├── lex.yy.c / .o
│ ├── ast.o main.o query_yottadb.o
│ └── …
├── doc/
│ └── jp2ydb.pdf
├── src/
│ ├── JPBRIDGE.m
│ ├── main.c
│ ├── Makefile
│ ├── parser.y      
│ ├── scanner.l     
│ └── lib/
│ ├── ast.c / ast.h
│ ├── query_yottadb.c / query_yottadb.h
│ └── …
├── build.sh
├── run_ydb.sh      
└── README.md
```

## YottaDB starten

Container starten (nach Bedarf anpassen):
> Während der Container läuft, bleibt das Terminal belegt; für weitere Befehle öffnet man ein zweites Terminal.

```bash
./run_ydb.sh
# oder manuell:
# docker run -it --rm --name ydb -v "$PWD/ydb-data:/data" \
#   -p 9080:9080 -p 1337:1337 download.yottadb.com/yottadb/yottadb-debian:latest
```

Beispieldaten einspielen von einem weiteren Terminal aus: 

```bash
docker exec -it ydb bash -lc '
source /opt/yottadb/current/ydb_env_set
ydb <<"M"
; bicycle
SET ^store("bicycle","color")="red"
SET ^store("bicycle","price")=399
; book[0]
SET ^store("book",1,"category")="fiction"
SET ^store("book",1,"author")="Herman Melville"
SET ^store("book",1,"title")="Moby Dick"
SET ^store("book",1,"price")=8.99
; book[1]
SET ^store("book",2,"category")="fiction"
SET ^store("book",2,"author")="J. R. R. Tolkien"
SET ^store("book",2,"title")="The Lord of the Rings"
SET ^store("book",2,"price")=22.99
; warehouse
SET ^warehouse("location")="Berlin"
SET ^warehouse("capacity")=1200
HALT
M
'
```

Container stoppen:
```bash
YDB>halt
```

## Nutzung

Umgebungsvariablen:

* `YDB_CONTAINER` — Name des Docker‑Containers (Standard: `ydb`)
* `JP_BRIDGE_FILE` — Pfad zu `JPBRIDGE.m` (z. B. `src/lib/JPBRIDGE.m`)

Häufige Flags (Kurzüberblick — `bin/jp2ydb -h` für alle):

* `-g [=NAME]` — Root-Global setzen; ohne `NAME` wird das aktuelle Root ausgegeben 
* `-a`          — AST ausgeben
* `-r`          — Abfrage über JPBRIDGE gegen YottaDB ausführen
* `-q`          — Quiet‑Mode (unterdrückt nicht essentielle Ausgaben)

Beispiele:

```bash
# einfacher Lookup
JP_BRIDGE_FILE=src/lib/JPBRIDGE.m YDB_CONTAINER=ydb \
  bin/jp2ydb '$.book[0].title'

Moby Dick


# AST + Referenz + Ausführung
JP_BRIDGE_FILE=src/lib/JPBRIDGE.m YDB_CONTAINER=ydb \
  bin/jp2ydb '$.bicycle.color'

> Ast-Ausgabe:
PATH
  IDENTIFIER: $
  PATH
    IDENTIFIER: bicycle
    PATH
      IDENTIFIER: color
> YottaDB-Abfrage (Global ^store):
[YDB] Referenz: ^store("bicycle","color")
red
```

## Mapping‑Beispiele

| JSONPath                  | YottaDB‑Referenz             | Hinweis             |
| ------------------------- | ---------------------------- | ------------------- |
| `$.bicycle.color`         | `^store("bicycle","color")`  | String‑Keys         |
| `$.book[0].title`         | `^store("book",1,"title")`   | Index `0 → 1`       |
| `$["book"]["1"]["title"]` | `^store("book","1","title")` | `"1"` bleibt String |

## Fehlerbehandlung

* **Parse‑Fehler** (z. B. `..`, `[*]`, Slices, Filter) erzeugen spezifische Meldungen/Exit‑Codes.
* **Bridge/Exec‑Fehler** (keine Marker, fehlender Container, fehlende JPBRIDGE) werden erkannt und mit eigenen Codes gemeldet.

## Entwicklungsnotizen

* Generierte Dateien liegen in `build/`, um das Repo sauber zu halten.
* Für POSIX‑APIs (`popen`, `pclose`, `fileno`, `isatty`) setzt der Build `-D_POSIX_C_SOURCE=200809L`.
* macOS linkt Flex üblicherweise mit `-ll` (automatisch im `build.sh`).

### Erweiterung der Grammatik

Tokens/Regeln in `scanner.l`/`parser.y` ergänzen, AST in `src/lib/ast.{h,c}` erweitern und den Mapper anpassen. Nicht fertige Features weiterhin **explizit ablehnen** (z. B. `EX_PARSE`), bis die Semantik vollständig implementiert ist.

## Lizenz

aktuell ohne Lizenzdatei

## Credits

* Hotel Eltern
* Kaffeemaschine