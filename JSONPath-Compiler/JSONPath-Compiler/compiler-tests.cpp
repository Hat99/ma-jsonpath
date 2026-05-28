#include "compiler-tests.h"
#include <iostream>



//Testfälle

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
    
    /* ignored cases */
    //{"$ ", 1},
    //{" $", 1},
    
    {"", 1},
    {".a", 1},
    {"$     .a", 0},
    {"$\n.a", 0},
    {"@.a", 1},
    {"@", 1},
    {"$[1]", 0},
    {"$[-1]", 0},
    {"$[-0]", 1},
    {"$[?@ == -0]", 0},
    {"$[1, 2, 'a']", 0},
    {"$.a[1].b[2]", 0},
    {"$[1:2:3]", 0},
    {"$[:2]", 0},
    {"$[::]", 0},
    
    {"$[?$.a]", 0},
    {"$[?$.a == 1]", 0},
    {"$[?$[1,2,3]]", 0},
    
    {"$.a", 0},
    {"$['a']", 0},
    {"$.*", 0},
    {"$[*]", 0},
    {"$..a", 0},
    {"$..*", 0},
    {"$..[*]", 0},
    {"$...a", 1},
    
    
    
    /* Capitalization test cases */
    /* things that are case sensitive vs things that aren't */
    {"$.a", 0},
    {"$.A", 0},
    {"$['\\b']", 0},
    {"$['\\B']", 1},    //escapes are lower case only
    {"$['\\u000B']", 0},
    {"$['\\u000b']", 0},
    {"$['\\U000B']", 1},
    {"$[?@ == 1e1]", 0},
    {"$[?@ == 1E1]", 0},
    {"$[?@ == true]", 0},
    {"$[?@ == True]", 1},   //key words must be lower case
    {"$[?foo()]", 0},
    {"$[?Foo()]", 1},   //function names must be lower case
    
    
    
    /* Whitespace test cases */
    /* (allowed whitespaces aren't tested as thoroughly since whitespaces are mostly ignored) */
    {"$ [1]", 0},
    {"$ .a", 0},
    {"$.a", 0},
    {"$. a", 1},
    {"$.*", 0},
    {"$. *", 1},
    
    {"$ ..['a']", 0},
    {"$..['a']", 0},
    {"$.. ['a']", 1},
    {"$.. a", 1},
    {"$..*", 0},
    {"$.. *", 1},
    {"$. .a", 1},
    {"$", 0},
    
    {"$[?$['a']]", 0},
    {"$[?$[ 'a' ]]", 0},
    {"$[?$['a'] == 1]", 0},
    //{"$[?$[ 'a' ] == 1]", 1},     //sollte nicht erlaubt sein, aber wird aktuell nicht abgefangen
    
    {"$[?@ == 1.0e1]", 0},
    {"$[?@ == 1 .0e1]", 1},
    {"$[?@ == 1. 0e1]", 1},
    {"$[?@ == 1.0 e1]", 1},
    {"$[?@ == 1.0e 1]", 1},
    
    {"$[?length(@) < 3]", 0},
    {"$[?length (@) < 3]", 1},
    
    
    
    
    
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



//Automatisierte Ausführung aller Testfälle

void runCompilerTests(int (*parse)(std::string input)){
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
}
