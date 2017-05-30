module salix::demo::graph::FormDemo

import salix::App;
import salix::HTML;
import salix::SVG;
import salix::Node;
import salix::lib::Dagre;
import IO;
import util::Math;
import Set;
import List;
import String;
import salix::lib::Form;
import salix::lib::Slider;

num startWidth = 400;
num startHeight = 800;       

alias Model = tuple[num width,num height, str name1, str name2, list[str] buffer, list[str] emsg, bool disabled];

data Msg
  = resizeX(int id, real x)
  | resizeY(int id, real y)
  | ok(int id, str txt)  
  ;
  
Model finit() = <startWidth, startHeight, "", "", ["Bert","Lisser"],  ["",""], false>;

list[int] isEmpty(Model m) {
   list[int] r =[];
   int i =  0;
   for (str b<-m.buffer)  {
         if (isEmpty(b)) r+=[i];
         i += 1;
         } 
   return r;
   }   

Model fupdate(Msg msg, Model m) {
  switch (msg) {
    case resizeX(_, real x): m.width = x;
    case resizeY(_, real y): m.height = y;
    case ok(int id, str txt): {
       if (id<0) {
                  {
                  m.name1 = m.buffer[0]; m.buffer[0]="";m.emsg[0]="";
                  m.name2 = m.buffer[1]; m.buffer[1]="";m.emsg[1]="";  
                  m.disabled = true;          
                  }
           }
       else {
           m.buffer[id]=txt;  // Text
           m.emsg[0]=""; m.emsg[1]="";
           list[int] wrong = isEmpty(m);
           m.disabled = !isEmpty(wrong); 
           for (int i<-wrong) m.emsg[i]="empty <i>";
           }
       }
  }
  return m;
}


list[FormEntry] lines = [
              < "Bert", "First Name", str(Model m) {return m.emsg[0];}>
             ,<"Lisser", "Second Name", str(Model m) {return m.emsg[1];}>
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
    div([salix::SVG::width("<m.width>px"), salix::SVG::height("<m.height>px")],
            () {f(); }
       );          
  });
}

App[Model] formApp()
  = app(finit, fview, fupdate, |http://localhost:9103|, |project://salix-figure/src|);

public App[Model] c = formApp();

public void main() {
     c.stop();
     c.serve();
     }