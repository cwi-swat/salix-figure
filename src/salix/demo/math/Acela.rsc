module salix::demo::math::Acela

import salix::App;
import salix::HTML;
import salix::SVG;
import salix::Node;
import salix::Core;
import salix::lib::Math;
import IO;
import util::Math;
import Set;
import List;
import String;

alias Model = tuple[list[tuple[str, str, str]] term, list[bool] result];

data Msg
  = ok(int id, int c, str txt)  
  | leave(int id, int c)
  | reformat(int id, str txt) 
  | finished(int id)
  ;
  
  
Model finit() = <[<"c", "2", "`c^2`">, <"c", "2", "`c_2`">], [true, true]>;

Model fupdate(Msg msg, Model m) {
  
  switch (msg) {
    case ok(int id, int c, str txt): { 
           m.result[id] = false;
           m.term[id][2] = "`<m.term[id][0]><id==0?"^":"_"><m.term[id][1]>`";
           if (size(txt)>1 && txt[-1]==" ") {
              do(blur(finished(id), id, c));
              txt = txt[0..-1];
              }
           m.term[id][c] = txt; 
           } 
    case leave(int id, int c): {
       m.result[id] = true;
       m.term[id][2] = "`<m.term[id][0]><id==0?"^":"_"><m.term[id][1]>`";
       do(rerun(finished(id), id, ""));
       }
    case reformat(int id, str txt): {
       do(rerun(finished(id), id, txt));
       }
    case finished(id):;
    }
  return m;
}

Msg(str) partial(Msg(int, int, str) f, int p, int c) {return Msg(str y){return f(p, c, y);};}

Msg(str) partial(Msg(int, str) f, int p) {return Msg(str y){return f(p, y);};}

void enter(str s, int id, int c) =
input(salix::HTML::id("a_<id>_<c>"), salix::HTML::\type("text")
                  , salix::HTML::size("10")
                  , salix::HTML::\value(s)
                  , salix::HTML::style([<"width", "<max(size(s)*8, 2)>px">])
                  ,onInput(partial(ok, id, c)), onBlur(leave(id, c)));
                  
/*
void fview(Model m) {        
  div(() { 
    h2("Demonstration Mathjax"); 
         div(()
           {
             table(class("checkbox"),() {
               tr(class("checkbox"), () {
                 td(class("cell"), (){enter(m.term[0][0], 0, 0);});
                 td(class("cell"), (){enter(m.term[0][1], 0, 1);});
                 if (m.result[0]) td(class("cell result"),
                     (){div(id("a0"), "<m.term[0][2]>");}
                     ); 
                 else (td(class("cell")));
                 td(class("cell"), () {
                   button(salix::HTML::style([<"width", "100px">]), onClick(
                      reformat(0, m.term[0][2])), 
                   "math");  
                   });
                 });
               tr(() {
                 td(class("cell"), (){enter(m.term[1][0], 1, 0);});
                 td(class("cell"), (){enter(m.term[1][1], 1, 1);});
                 if (m.result[1]) td(class("cell result"),
                     (){div(id("a1"), "<m.term[1][2]>");}
                   ); 
                 else (td(class("cell")));
                 td(class("cell"),() {
                   button(salix::HTML::style([<"width", "100px">]), onClick(
                      reformat(1, m.term[1][2])), 
                   "math");  
                   });
                 });
              });  
          });
         }                     
  );
}
*/


void fview(Model m) {        
  div(() { 
    h2("Demonstration Mathjax"); 
         div(()
           {
           span(
           "If you enter "
           );
           enter(m.term[0][0], 0, 0);    
           span("^");
           enter(m.term[0][1], 0, 1);
           span("then the result ");
           if (m.result[0]) span(() {span(id("a0"), "` `<m.term[0][2]>` `");});
           else span("?");
           span("will be displayed");
           } );
           
           div(()
           {
           span(
           "If you enter "
           );
           enter(m.term[1][0], 1, 0);    
           span("_");
           enter(m.term[1][1], 1, 1);
           span("then the result ");
           if (m.result[1]) span(() {span(id("a1"), "` `<m.term[1][2]>` `");});
           else span("?");
           span("will be displayed");
           
           } );                                 
  });
}

/*
void fview(Model m) {        
  div("Lesser then? &lt;");
  }
*/  

App[Model] formApp()
  = app(finit, fview, fupdate, |http://localhost:9103|, |project://salix-figure/src|
    );

public App[Model] c = formApp();

public void main() {
     c.stop();
     c.serve();
     }