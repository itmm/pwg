pwg: pwg.cpp

pwg.cpp: README.md
	@echo "mdp $<"
	@which mdp >/dev/null && mdp $< || echo "please install markdown-patcher" 1>&2
