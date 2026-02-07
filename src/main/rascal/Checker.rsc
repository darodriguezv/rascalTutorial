module Checker

import ParseTree;
import Relation;
import String;
import util::IDEServices;
import Syntax;

// Section 8 / Listing 11 style (validation using concrete syntax)
public Summary check(start[Planning] p) {
  rel[str, loc] overLimit = {<"<a>", pay.src> |
    /pay:(PaymentAction) ` Pay <INT a> euro ` := p,
    toInt("<a>") > 10000
  };

  rel[str, loc] tasks = {<"<prio>", prio.src> |
    /(Task) ` Task <Action action> priority : <INT prio> <Duration? duration> ` := p
  };

  rel[str, loc] tasksWithSamePrio = {<n1, p1> |
    <n1, p1> <- tasks,
    <n2, p2> <- tasks,
    n1 == n2,
    p1 != p2
  };

  rel[str, loc] durations = {<"<dl>", dur.src> |
    /dur:(Duration) ` duration : <INT dl> min ` := p,
    toInt("<dl>") % 60 == 0
  };

  return summary(p.src,
    messages =
      {<l, warning("There is a budget limit of 10000. So <e> is too big.", l)> |
        e <- overLimit<0>, l <- overLimit[e]}
    + {<l, error("Priorities need to be unique: <e> is used somewhere else.", l)> |
        e <- tasksWithSamePrio<0>, l <- tasksWithSamePrio[e]}
    + {<l, warning("Rewrite duration in <toInt(e)/60> hours.", l)> |
        e <- durations<0>, l <- durations[e]}
  );
}
