module salix::demo::graph::FormDemo

import salix::App;
import salix::HTML;
import salix::SVG;
import salix::Node;
import IO;
import util::Math;
import Set;
import List;
import String;
import salix::lib::Form;
import salix::lib::Slider;

num startWidth = 400;
num startHeight = 800;       

alias Model = tuple[num width,num height, str name1, str name2, str postCode, str sexe, map[str, bool] kind, list[str] buffer, list[str] emsg, bool disabled,
                    bool visible];

data Msg
  = resizeX(int id, real x)
  | resizeY(int id, real y)
  | ok(int id, str txt)  
  | open(str txt)
  ;
  
int nVars= 3;

list[str] emptyFields() = [""|_<-[0..nVars]];

map[str, bool] defaultKind = ("aap":true,"noot":false, "mies":false);
  
Model finit() = <startWidth, startHeight, "", "", "", "", defaultKind, emptyFields(),  emptyFields(), false, false>;

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
                       m.name1 = m.buffer[0]; m.buffer[0]="";m.emsg[0]="";
                       m.name2 = m.buffer[1]; m.buffer[1]="";m.emsg[1]="";  
                       m.postCode = m.buffer[2]; m.buffer[2]="";m.emsg[2]=""; 
                       println(m.kind); 
                       m.kind = defaultKind;
                       m.visible = false;
                       }  
                  else 
                    for (tuple[int, str] t<-wrong) m.emsg[t[0]]=t[1];       
                  }
           }
       else {
           if (id<3) {
              m.buffer[id]=txt;  // Text
              m.emsg[id]=""; 
              } 
           if (id==3) m.sexe  = txt;
           if (id==4) {
                       m.kind[txt] = true;
                       println(m.kind); 
                       }
             }
       }
     case open(str text): {
         m.visible = true;
         }
  }
  return m;
}


list[FormEntry] lines = [
              < "First Name", str(Model m) {return m.buffer[0];}, str(Model m) {return m.emsg[0];}>
             ,<"Second Name", str(Model m) {return m.buffer[1];}, str(Model m) {return m.emsg[1];}>
             ,<"Post Code", str(Model m) {return m.buffer[2];}, str(Model m) {return m.emsg[2];}>
             ,<"Sexe", Radio(Model m) {return <"man", [<"Man", "man">, <"Woman", "woman">]>;}
                     , str(Model m) {return "";}>
             ,<"Kind", Checkbox(Model m) {return [<m.kind["aap"], "Aap", "aap">, <m.kind["noot"], "Noot", "noot">, <m.kind["mies"], "Mies", "mies">];}
                     , str(Model m) {return "";}>
             ];

void fview(Model m) {
  num lo = 200, hi = 1000;
  void() f = formPanel("ok", lines)(m, ok, m.disabled?"":"ok");
            
  list[list[list[SliderBar]]] sliderBars = [[
                             [
                              < resizeX, 0, "resize X:", lo, hi, 50, startWidth,"<lo>", "<hi>"> 
                             ]
                             ,[
                              < resizeY, 0, "resize Y:", lo, hi, 50, startHeight,"<lo>", "<hi>"> 
                             ]
                             ]];       
  div(() { 
    h2("Form"); 
    slider(sliderBars);
    if (m.visible) 
        div([salix::SVG::width("<m.width>px"), salix::SVG::height("<m.height>px")],
            () {f(); }
       ); 
    else button(salix::HTML::style([<"width", "200px">]), onClick(open("open")), 
                   "open");        
  });
}

App[Model] formApp()
  = app(finit, fview, fupdate, |http://localhost:9103|, |project://salix-figure/src|);

public App[Model] c = formApp();

public void main() {
     c.stop();
     c.serve();
     }