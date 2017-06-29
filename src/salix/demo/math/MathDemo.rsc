module salix::demo::math::MathDemo

import salix::App;
import salix::HTML;
import salix::SVG;
import salix::Node;
import salix::Core;
import IO;
import util::Math;
import Set;
import List;
import String;
import salix::lib::Form;
// import salix::lib::Math;
import salix::lib::Slider;
import salix::lib::RenderFigure;


num startWidth = 400;
num startHeight = 800;   

// list[Sub] subs(Model m) = [timeEvery(tick, 10) | m.running ]; 

alias Model = tuple[num width,num height, str term1, str term2,  str op, map[str, bool] kind, list[str] buffer, list[str] emsg,
                    bool disabled, bool visible, bool visible2, bool running];

data Msg
  = resizeX(int id, real x)
  | resizeY(int id, real y)
  | ok(int id, str txt)  
  | open(str txt)
  //| tick(int time)
  //| finished()
  ;
  
int nVars= 2;

list[str] emptyFields() = [""|_<-[0..nVars]];

list[str] terms=["`(a+b)`", "`(a+b)^2`", "`(c+d)`"];

map[str, bool] defaultKind = (terms[0]:true,terms[1]:false, terms[2]:false);
  
Model finit() = <startWidth, startHeight, "", "",  "*", defaultKind, emptyFields(),  emptyFields(), false, false, true, false>;

bool isDig(value v) =  (str s:=v) ?  /^[0-9]+$/:=s : false;
bool isLetterCode(value v) = (str s:=v) ? /^[A-Z]+$/:=s : false; 

list[tuple[int, str]] isCorrect(Model m) {
   list[tuple[int, str]] r =[];
   list[str] c =[];
   int i =  0;
   for (str b<-m.buffer)  {
         if (isEmpty(b)) r+=[<i, "empty field">];
         else c+= b;
         i += 1;
         }
   /*
   if (size(m.buffer[2])!=6) r+=<2, "Length of post code must be 6">;
   else
   if (!isDig(substring(m.buffer[2], 0, 4))) r+=<2, "Digits expected">;
   else
   if (!isLetterCode(substring(m.buffer[2], 4, 6))) r+=<2, "Letters expected">;
   */
   return r;
   }   

Model fupdate(Msg msg, Model m) {
  switch (msg) {
    case resizeX(_, real x): m.width = x;
    case resizeY(_, real y): m.height = y;
    case ok(int id, str txt): {
       if (id<0) {
                  {
                  list[tuple[int, str]] wrong = isCorrect(m);
                  if (isEmpty(wrong)) {
                       m.term1 = m.buffer[0]; m.buffer[0]="";m.emsg[0]="";
                       m.term2 = m.buffer[1]; m.buffer[1]="";m.emsg[1]="";  
                       // println(m.kind); 
                       m.kind = defaultKind;
                       m.visible = false;
                       m.visible2 = true;
                       // m.running = true;
                         
                       }  
                  else 
                    for (tuple[int, str] t<-wrong) m.emsg[t[0]]=t[1];       
                  }
           }
       else {
           if (id<2) {
              m.buffer[id]=txt;  // Text
              m.emsg[id]=""; 
              } 
           if (id==2) m.op  = txt;
           if (id==3) {
                       m.kind[txt] = true;
                       println(m.kind); 
                       }
             }
       }
     case open(str text): {
         m.visible = true;
         }
     //case tick(int time): {
     //     println("tick: <time>");
     //     m.running = false;
     //     m.visible2 = true;
     //     do(rerun(finished())); 
     //    }
     //case finished():println("Finished");
  }
  return m;
}



list[FormEntry] lines = [
              <"First Term", str(Model m) {return m.buffer[0];}, str(Model m) {return m.emsg[0];}>
             ,<"Second Term", str(Model m) {return m.buffer[1];}, str(Model m) {return m.emsg[1];}>
             ,<"Terms", Checkbox(Model m) 
                { return 
                 [<m.kind[terms[0]],  terms[0], terms[0]>
                 ,<m.kind[terms[1]], terms[1], terms[1]>,
                 <m.kind[terms[2]],  terms[2], terms[2]>];
                 }
                ,str(Model m) {return "";}>
             ];
/*
void fview(Model m) {
  num lo = 200, hi = 1000;
  void() f = formPanel("ok", lines)(m, ok, m.disabled?"":"ok");
                
  div(() { 
    h2("Form"); 
    if (m.visible) {
        div([salix::SVG::width("<m.width>px"), salix::SVG::height("<m.height>px")],
            () {f(); }
       );
       }
    else {
         div(()
           {
             button(salix::HTML::style([<"width", "200px">]), onClick(open("open")), 
                   "open");
                   if (m.visible2)
             table(() {
               tr(class("checkbox"), () {
                 td(class("cell"), "`<m.term1>`"); 
                 });
               tr(() {
                 td(class("cell"), "`<m.term2>`");
                 });
              });  
          });
         }                     
  });
}
*/

void fview(Model m) {            
  div(() { 
    h2("Demonstation Mathjax"); 
         div(()
           {
             table(() {
               tr(class("checkbox"), () {
                 td(class("cell"), "`<m.term1>`"); 
                 });
               tr(() {
                 td(class("cell"), "`<m.term2>`");
                 });
              });  
          });
         }                     
  );
}

App[Model] formApp()
  = app(finit, fview, fupdate, |http://localhost:9103|, |project://salix-figure/src|
    // , subs =subs
    );

public App[Model] c = formApp();

public void main() {
     c.stop();
     c.serve();
     }