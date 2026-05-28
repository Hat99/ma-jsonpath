#include <iostream>
#include <string>
#include <ctime>
#include "lex.yy.h"
#include "jsonpath.tab.hpp"
#include "compiler-tests.h"

/* Für Einbindung des Parsers */
bool parserVerbose = true;


int yyerror(std::string s) {
    if(parserVerbose){
        std::cout << s << std::endl;
    }
    return 0;
}
int yyparse();

extern int yydebug;
extern void setStateInitial();
extern void setStateNormalized();

using namespace std;
int yylex();
int yylex_2();

//Für Bison-Syntaxtree-Hack Einbindung

int yylex() {
    int rc = yylex_2();
    yylval.tree = new syntaxTree(yytext);
    return rc;
}
extern syntaxTree * root;



//Eigener Parse-Vorgang, um normalisierte und allgemeine Ausdrücke zu erkennen

int parse(std::string input){
    //try normalized path first, then try "normal" jsonpath
    YY_BUFFER_STATE buffer = yy_scan_string((std::string("n") + input).c_str());
    setStateNormalized();
    if(yyparse() == 0){
        return 0;
    }
    yy_delete_buffer(buffer);
    
    buffer = yy_scan_string((std::string("j") + input).c_str());
    setStateInitial();
    int res = yyparse();
    yy_delete_buffer(buffer);
    return res;
    
}



//Ausgabe des Syntaxbaums über Visualisierungskomponente als PDF

void root2pdf(){
    
    /* micro sekunden timestamp nach https://stackoverflow.com/questions/22203319/c-c-microsecond-timestamp */
    long microseconds_since_epoch = duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    
    std::string timeStamp = to_string(microseconds_since_epoch);
    
    
    /*Umleitung in Outputdatei nach https://stackoverflow.com/questions/18086193/redirect-stdout-stderr-to-file-under-unix-c-again */
    freopen((timeStamp + ".tex").c_str(), "a", stdout);
    root->tikz();
    freopen("/dev/tty", "w", stdout);
    
    std::string compileCmd ="pdflatex -interaction=batchmode " + timeStamp + " > /dev/null 2>&1";
    std::system(compileCmd.c_str());
    
    std::remove((timeStamp + ".tex").c_str());
    std::remove((timeStamp + ".log").c_str());
    std::remove((timeStamp + ".aux").c_str());
    
    std::cout << "PDF created (" << timeStamp << ".pdf)\n";
}



//Controller-Funktionalität in main-Funktion

int main(int argc, const char * argv[]) {
    yydebug = 0;
    parserVerbose = false;
    bool visualize = false;
    
    bool inputProvided = false;
    
    
    //Flags setzen, erkennen ob Ausdrücke im Input sind
    for(int i = 1; i < argc; i++){
        std::string arg = argv[i];
        if(arg == "-debug" || arg == "-d"){
            yydebug = 1;
        }
        else if (arg == "-verbose" || arg == "-v"){
            parserVerbose = true;
        }
        else if(arg == "-run-tests" || arg == "-rt"){
            runCompilerTests(&parse);
            return EXIT_SUCCESS;
        }
        else if(arg == "-visualize" || arg == "-vis"){
            visualize = true;
        }
        else{
            inputProvided = true;
        }
    }
    
    //Wenn Ausdrücke im Input sind, abarbeiten
    if(inputProvided){
        for(int i = 1; i < argc; i++){
            std::string arg = argv[i];
            if(arg == "-debug" || arg == "-d"){
                //already done
            }
            else if(arg == "-verbose" || arg == "-v"){
                //already done
            }
            else if (arg == "-visualize" || arg == "-vis"){
                //already done
            }
            else{
                if(parse(arg) == 1){
                    std::cout << "Error encountered for input " << arg << "\n";
                } else if(root && visualize){
                    root2pdf();
                }
            }
        }
    }
    //Sonst: "Eingabemaske" starten
    else{
        while(true){
            std::cout << "Input a JSONPath query ('quit' or 'exit' to quit):\n";
            
            std::string input;
            
            std::getline(std::cin, input);
            
            if(input == "exit" || input == "quit"){
                break;
            }
            
            if(parse(input) == 0){
                std::cout << "Success.\n";
                if(root && visualize){
                    root2pdf();
                }
            }
            else{
                std::cout << "Error encountered for input " << input << "\n";
            }
        }
    }
}
