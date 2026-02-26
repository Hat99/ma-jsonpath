# 🧪 Little JSONPath Compiler (Based on Lex/Yacc)

It parse and compile JsonPath query into YottoDB query and also shows parse tree
It supports basic JSONPath expressions like:
```
$.store.book[0].title
$.items[*]
```
---

## 📦 Requirements

Make sure the following packages are installed on your system:

- **Flex** – Lexical analyzer
- **Bison** – Parser generator
- **GCC** – C compiler
- **Make** – Build tool

## 1. Build the parser
```
make
```
## 2. Run the parser
```
./compiler
```
You will be prompted to enter a JSONPath expression:
```
Enter JSONPath: $.store.book[0].title
✅ Valid JSONPath expression
YottaDB Global Reference: ^store("..book")("[?@.price]")
```
## 🧹 Clean the build
```
make clean
```