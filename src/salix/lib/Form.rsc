module salix::lib::Form

import salix::App;
import salix::HTML;
import salix::SVG;
import salix::Node;
import IO;
import util::Math;
import Set;
import List;
import String;
import Node;
import util::Reflective;


data Msg;

alias Radio = tuple[str current, list[tuple[str, str]] line];

alias Checkbox = list[tuple[bool checked, str label, str val]];

alias Range = tuple[str lab, num current, num lo, num hi, num step, str left, str right];


Msg(str) partial(Msg(int, str) f, int p) {return Msg(str y){return f(p, y);};}

alias FormEntry[&T] = tuple[str fieldName, value (&T) val, str (&T) emsg];

//app[&T] app(&T() init, void(&T) view, &T(Msg, &T) update, loc http, loc static, 
 //           Subs[&T] subs = noSubs, str root = "root", Parser parser = parseMsg) { 
 
str getUniqueId(value v) {
   int d = getFingerprintNode(makeNode("id", v));
   return d<0?"id_<-d>":"id_<d>";
   }

void formRow(&T m, Msg(int, str) msg, FormEntry[&T] fe, int id) {
    tr([]+[() {       
                td(() {
                  salix::HTML::span(fe.fieldName);
                  });           
                td(() {
                  value v = fe.val(m);  // Bug in Rascal
                  if (str s:=v) {
                  input(salix::HTML::\type("text"), salix::HTML::size("10"), salix::HTML::\value(s)
                  ,onInput(partial(msg, id)));
                   }
                  else if (Radio s:=v) {
                    str idx = getUniqueId(s);
                    div(salix::HTML::id(idx), () 
                       {
                       for (tuple[str, str] line<-s.line) {
                         label(salix::HTML::\for(idx+"_"+line[1]), line[0]);
                         input(salix::HTML::\type("radio")
                             , salix::HTML::size("10")
                             , salix::HTML::name(idx)
                             , salix::HTML::\value(line[1])
                             , salix::HTML::\id(idx+"_"+line[1])
                             , salix::HTML::checked(line[1]==s.current)
                             , onClick(partial(msg, id)(line[1])));
                             }
                       });
                    }
                    else if (Checkbox s:=v) {
                    str idx = getUniqueId(s);
                    div(salix::HTML::id(idx), () 
                       {
                       for (tuple[bool checked , str label , str val] line<-s) {
                       label(salix::HTML::\for(idx+"_"+line.val), line.label);
                         input(salix::HTML::\type("checkbox")
                             , salix::HTML::size("10")
                             , salix::HTML::name(idx)
                             , salix::HTML::\value(idx+"_"+line.val)
                             , salix::HTML::\id(line.val)
                             , salix::HTML::checked(line.checked)
                             , onClick(partial(msg, id)(line.val)));
                             }
                       });
                    }
                  });
                 list[tuple[str, str]] styles = [<"border-style", "groove">, <"border-width", "4">];
                 td([salix::HTML::width(250), salix::HTML::style(styles)]+[() {    
                 list[tuple[str, str]] styles = [<"color","red">];
                 salix::HTML::span(salix::HTML::style(styles), fe.emsg(m));             
                  }]);           
             }]
          );
    }
  

(void() (&T, Msg(int, str), str)) formPanel(str buttonLab, list[FormEntry] lines) {
  return void() (&T m, Msg(int, str) msg , str to) {
         return () {
            list[tuple[str, str]] styles = [<"min-width", "400px">
                                         , <"border-width","2">
                                         // , <"border-color","black">
                                         , <"border-style", "groove">];
            table([salix::HTML::style(styles)]+[() {
              int id = 0;
              for (FormEntry  fe <-lines) {
                 formRow(m, msg, fe, id); 
                 id += 1;
                 }
             tr(() {
               td([salix::HTML::colspan(3), salix::HTML::align("center")]+[() {
                   button(salix::HTML::style([<"width", "200px">]), onClick(partial(msg, -1)(to)), 
                   salix::HTML::disabled(isEmpty(to)), buttonLab);
               }]);
               }); 
           }]);
      
      };
      };
  }