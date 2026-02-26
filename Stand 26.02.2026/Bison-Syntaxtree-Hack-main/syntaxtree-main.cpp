int yyerror(string s) {
	cout << s << endl;
	return 0;
}

int main() {
	int rc =  yyparse();
	if (!rc)
		root->tikz();
	else
		cerr << "Parse-Ergebnis " << rc << endl;
	return rc;
}
