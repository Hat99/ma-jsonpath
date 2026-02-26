# 🧪 Little JSONPath Compiler (Based on Lex/Yacc)

It parse and compile JsonPath query into YottoDB query and also save LaTex file for priview in output folder

## 📦 Requirements

Make sure the following packages are installed on your system:

- **Flex** – Lexical analyzer
- **Bison** – Parser generator
- **GCC** – C compiler
- **Make** – Build tool

## 1. Build the parser (You can also update JSON query into make file for testing)
```
make
```
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