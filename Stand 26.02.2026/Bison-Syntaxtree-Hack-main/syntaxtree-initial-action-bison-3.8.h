#undef  YY_REDUCE_PRINT
#define YY_REDUCE_PRINT(Rule) { \
	if (yytname[yyr1[Rule]][0] != '@') { \
		int n_rhs = yyr2[Rule], n = 0; \
		root = yyval.tree = new syntaxTree(yytname[yyr1[Rule]]); \
		for (int i = 0; i < n_rhs; i++) {\
			if (yytname[yyrhs[yyprhs[Rule] + i]][0] != '@') \
				yyval.tree->append(yyvsp[i + 1 - n_rhs].tree), n++; \
		} \
		if (!n) yyval.tree->append(syntaxTree_epsilon_node()); \
	}\
}
