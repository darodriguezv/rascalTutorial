module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::LanguageServer;

import Syntax;
import Generator4;
import Checker;

PathConfig pcfg = getProjectPathConfig(|project://rascaldsl|);

data Command = gen(start[Planning] pt, str title = "Generate text file");

Language tdslLang = language(pcfg, "TDSL", "tdsl", "Plugin", "contribs");

set[LanguageService] contribs() = {
  parser(start[Planning](str program, loc src) {
    return parse(#start[Planning], program, src);
  }),

  lenses(rel[loc src, Command lens](start[Planning] p) {
    return {<p.src, gen(p, title="Generate generator4.txt")>};
  }),

  summarizer(Summary (loc _, start[Planning] p) {
    return check(p);
  }),

  executor(exec)
};

value exec(gen(start[Planning] pt, str _)) {
  str out = generator4(pt);
  loc outputFile = |project://rascaldsl/instance/output/generator4.txt|;
  writeFile(outputFile, out);
  edit(outputFile);
  return ("result": true);
}

void main() {
  registerLanguage(tdslLang);
}
