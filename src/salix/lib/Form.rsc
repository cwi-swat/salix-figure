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


data Msg;



Msg(str) partial(Msg(int, str) f, int p) {return Msg(str y){return f(p, y);};}

alias FormEntry[&T] = tuple[str fieldName, str (&T) val, str (&T) emsg];

//app[&T] app(&T() init, void(&T) view, &T(Msg, &T) update, loc http, loc static, 
 //           Subs[&T] subs = noSubs, str root = "root", Parser parser = parseMsg) { 

void formRow(&T m, Msg(int, str) msg, FormEntry[&T] fe, int id) {
    tr([]+[() {       
                td(() {
                  salix::HTML::span(fe.fieldName);
                  });
                td(() {
                  input(salix::HTML::\type("text"), salix::HTML::size("10"), salix::HTML::\value(fe.val(m))
                  ,onInput(partial(msg, id)));
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