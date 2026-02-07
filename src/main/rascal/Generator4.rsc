module Generator4

import IO;
import ParseTree;
import Syntax;

// Section 7 / Listing 10 style (concrete syntax based generation)
public str printTaskWithDuration(start[Planning] ast) {
  list[str] rVal = [];
  visit (ast) {
    case (Task) ` Task <Action action> priority : <INT prio> <Duration? duration> `:
      rVal += "<printAction(action)> <printDuration(duration)>";
  }
  return intercalate(" &\n", rVal);
}

public str printTaskWithoutDuration(start[Planning] ast) {
  list[str] rVal = [];
  for (a <- { action |
      /(Task) ` Task <Action action> priority : <INT prio> <Duration? duration> ` := ast }) {
    rVal += "<printAction(a)>";
  }
  return intercalate(" ,\n", rVal);
}

str printAction(action) {
  visit (action) {
    case (LunchAction) ` Lunch <ID location> `:
      return "Lunch at location <location>";
    case (MeetingAction) ` Meeting <STRING topic> `:
      return "Meeting about <topic>";
    case (PaperAction) ` Report <ID report> `:
      return "Report <report>";
    case (PaymentAction) ` Pay <INT amount> euro `:
      return "Pay <amount> Euro";
  }
  return "Unknown action!";
}

str printDuration(durationOpt) {
  str r = "";
  visit (durationOpt) {
    case (Duration) ` duration : <INT dl> <TimeUnit unit> `: {
      str u = "";
      visit (unit) {
        case (Minute) ` min `: u = "m";
        case (Hour) ` hour `: u = "h";
        case (Day) ` day `: u = "d";
        case (Week) ` week `: u = "w";
      }
      r = "with duration : <dl> <u>";
    }
  }
  return r;
}

public str generator4(start[Planning] pt) {
  return "Tasks (with duration):\n<printTaskWithDuration(pt)>\n\n"
       + "Tasks (without duration):\n<printTaskWithoutDuration(pt)>\n";
}

void main() {
  loc inputFile = |project://rascaldsl/instance/spec1.tdsl|;
  start[Planning] pt = parse(#start[Planning], readFile(inputFile), inputFile);
  str out = generator4(pt);
  println(out);
  writeFile(|project://rascaldsl/instance/output/generator4.txt|, out);
}
