#include <iostream>
#include <string>

bool parserVerbose = true;

extern "C"{
void yyerror(char *t){
    if(parserVerbose){
        printf("%s\n", t);
    }
}
int yyparse();
void yy_scan_string(const char* str);

extern int yydebug;
}


int parse(std::string input){
    //try normalized path first, then try "normal" jsonpath
    yy_scan_string((std::string("n") + input).c_str());
    if(yyparse() == 0){
        return 0;
    }
    
    yy_scan_string((std::string("j") + input).c_str());
    return yyparse();
}


struct TestCase{
    std::string test;
    int result;
};

const TestCase testCases[] = {
    /* "custom" examples */
    {"$", 0},
    {"a", 1},
    {"$.a", 0},
    {"$ .a", 0},
    {"$ ", 1},
    {" $", 1},
    {"", 1},
    {".a", 1},
    {"$     .a", 0},
    {"$\n.a", 0},
    {"@.a", 1},
    {"@", 1},
    
    
    
    /* examples from RFC-9535 section 1.5 */
    {"$['store']['book'][0]['title']", 0},
    {"$.store.book[0].title", 0},
    {"$.store.book[?@.price < 10].title", 0},
    {"$.store.book[*].author", 0},
    {"$..author", 0},
    {"$.store.*", 0},
    {"$.store..price", 0},
    {"$..book[2]", 0},
    {"$..book[2].author", 0},
    {"$..book[2].publisher", 0},
    {"$..book[-1]", 0},
    {"$..book[0,1]", 0},
    {"$..book[:2]", 0},
    {"$..book[?@.isbn]", 0},
    {"$..book[?@.price<10]", 0},
    {"$..*", 0},
    
    /* examples from RFC-9535 section 2.2.3 */
    {"$", 0},
    
    /* examples from RFC-9535 section 2.3.1.3 */
    {"$.o['j j']", 0},
    {"$.o['j j']['k.k']", 0},
    {"$.o[\"j j\"][\"k.k\"]", 0},
    {"$.o[\"'\"][\"@\"]", 0},
    
    /* examples from RFC-9535 section 2.3.2.3 */
    {"$[*]", 0},
    {"$.o[*]", 0},
    {"$.o[*, *]", 0},
    {"$.a[*]", 0},
    
    /* examples from RFC-9535 section 2.3.3.3 */
    {"$[1]", 0},
    {"$[-2]", 0},
    
    /* examples from RFC-9535 section 2.3.4.3 */
    {"$[1:3]", 0},
    {"$[5:]", 0},
    {"$[1:5:2]", 0},
    {"$[5:1:-2]", 0},
    {"$[::-1]", 0},
    
    /* examples from RFC-9535 section 2.3.5.3 */
    {"$.a[?@.b == 'kilo']", 0},
    {"$.a[?(@.b == 'kilo')]", 0},
    {"$.a[?@>3.5]", 0},
    {"$.a[?@.b]", 0},
    {"$[?@.*]", 0},
    {"$[?@[?@.b]]", 0},
    {"$.o[?@<3, ?@<3]", 0},
    {"$.a[?@<2 || @.b == \"k\"]", 0},
    {"$.a[?match(@.b,\"[jk]\")]", 0},
    {"$.a[?search(@.b,\"[jk]\")]", 0},
    {"$.o[?@>1 && @<4]", 0},
    {"$.o[?@.u || @.x]", 0},
    {"$.a[?@.b == $.x]", 0},
    {"$.a[?@ == @]", 0},
    
    /* examples from RFC-9535 section 2.4 */
    {"$[?length(@.authors) >= 5]", 0},
    {"$[?count(@.*.author) >= 5]", 0},
    {"$[?match(@.date, \"1974-05-..\")]", 0},
    {"$[?search(@.author, \"[BR]ob\")]", 0},
    {"$[?value(@..color) == \"red\"]", 0},
    //well-typedness as stated in RFC-9535 has to be checked
    //after parsing ("does function x accept y and return z?")
    {"$[?length(@) < 3]", 0},
    {"$[?length(@.*) < 3]", 0},
    {"$[?count(@.*) == 1]", 0},
    {"$[?count(1) == 1]", 0},
    {"$[?count(foo(@.*)) == 1]", 0},
    {"$[?match(@.timezone,'Europe/.*')]", 0},
    {"$[?match(@.timezone,'Europe/.*') == true]", 0},
    {"$[?value(@..color) == \"red\"]", 0},
    {"$[?value(@..color)]", 0},
    {"$[?bar(@.a)]", 0},
    {"$[?bnl(@.*)]", 0},
    {"$[?blt(1==1)]", 0},
    {"$[?blt(1)]", 0},
    {"$[?bal(1)]", 0},
    
    /* examples from RFC-9535 section 2.5.1.3 */
    {"$[0, 3]", 0},
    {"$[0:2, 5]", 0},
    {"$[0, 0]", 0},
    
    /* examples from RFC-9535 section 2.5.1.3 */
    {"$..j", 0},
    {"$..[0]", 0},
    {"$..[*]", 0},
    {"$..*", 0},
    {"$..o", 0},
    {"$.o..[*,*]", 0},
    {"$.a..[0,1]", 0},
    
    /* examples from RFC-9535 section 2.6.1 */
    {"$.a", 0},
    {"$.a[0]", 0},
    {"$.a.d", 0},
    {"$.b[0]", 0},
    {"$.b[*]", 0},
    {"$.b[?@]", 0},
    {"$.b[?@==null]", 0},
    {"$.c[?@.d==null]", 0},
    {"$.null", 0},
    
    /* examples from RFC-9535 section 2.7.1 */
    {"$.a", 0},
    {"$['a']", 0},
    {"$[1]", 0},
    {"$[-3]", 0},
    {"$[2]", 0},
    {"$.a.b[1:2]", 0},
    {"$['a']['b'][1]", 0},
    {"$[\"\\u000B\"]", 0},
    {"$['\\u000b']", 0},
    {"$[\"\\u0061\"]", 0}
};

void runParserTests(){
    //disable parser outputs for automated tests
    parserVerbose = false;
    
    int testCount = sizeof(testCases) / sizeof(testCases[0]);
    
    int fails = 0;
    for(int i = 0; i < testCount; i++){
        std::cout << "Running case " << i+1 << " of " << testCount << "...";
        if(parse(testCases[i].test) == testCases[i].result){
            std::cout << "Success!\n";
        }else{
            fails++;
            std::cout << "Failed! Case: " << testCases[i].test << "\n";
        }
    }
    std::cout << "Tests completed. " << testCount - fails << " of " << testCount << " were successful.\n";
    
    parserVerbose = true;
}


int main(int argc, const char * argv[]) {
    yydebug = 0;
    parserVerbose = false;
    
    bool inputProvided = false;
    
    for(int i = 1; i < argc; i++){
        std::string arg = argv[i];
        if(arg == "-debug" || arg == "-d"){
            yydebug = 1;
        }
        else if (arg == "-verbose" || arg == "-v"){
            parserVerbose = true;
        }
        else if(arg == "-run-tests" || arg == "-rt"){
            runParserTests();
            return EXIT_SUCCESS;
        }
        else{
            inputProvided = true;
        }
    }
    
    if(inputProvided){
        for(int i = 1; i < argc; i++){
            std::string arg = argv[i];
            if(arg == "-debug" || arg == "-d"){
                //already done
            }
            else if(arg == "-verbose" || arg == "-v"){
                //already done
            }
            else{
                if(parse(arg) == 1){
                    std::cout << "Error encountered for input " << arg << "\n";
                }
            }
        }
    }
    else{
        while(true){
            std::cout << "Input a JSONPath query ('quit' or 'exit' to quit):\n";
            
            std::string input;
            
            std::cin >> input;
            
            if(input == "exit" || input == "quit"){
                break;
            }
            
            if(parse(input) == 0){
                std::cout << "Success.\n";
            }
            else{
                std::cout << "Error encountered for input " << input << "\n";
            }
        }
    }
    
    
}
