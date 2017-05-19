module salix::demo::figure::Demo

import util::Math;
import salix::HTML;
import salix::lib::Figure;
import salix::lib::RenderFigure;
import salix::Core;
import salix::App;
import salix::lib::Slider;

alias Model = list[tuple[num shrink, num grow]];

Model startModel = [<1, 1>, <1, 1>, <1, 1>];

data Msg
   = shrink(int id, num x)
   | grow(int id, num x)
   ;
   
 Model update(Msg msg, Model m) {
    switch (msg) {
       case shrink(int id, num v): m[id].shrink = v;
       case grow(int id, num v): m[id].grow = v;
       }
     return m;
}

Model init() = startModel;
    
//---------------------------------------------------------------------------------------------------------------------------------------------------------

void() newBox(Fig f, Model m, str lc, void() inner) = () {
      f.at(10, 10
      ,(){
         f.box(fillColor("none"), lineWidth(8), lineColor(lc), FProp::shrink(m[0].shrink)
         ,FProp::grow(m[0].grow), inner);
         }
      );
     };
            
void boxes(Fig f, Model m) {
      list[str] colors = ["green",  "red", "blue", "grey", "magenta", "brown"];
      f.hcat(fillColor("none"), borderWidth(0) 
      ,() {
          ((){f.at(10, 10 
             ,(){
                f.box(FProp::grow(m[0].grow), lineColor("grey"), fillColor("yellow")
                     ,lineWidth(8),size(<30, 40>));
                }
              );}|newBox(f, m, e, it)|e<-colors)();
              f.box(size(<300, 300>)
              ,(){
                 (() {
                     f.at(10, 10
                     ,(){
                         f.box(FProp::shrink(m[0].shrink), lineColor("grey"), lineWidth(1)
                         ,fillColor("antiquewhite"));
                         }
                  );}|newBox(f, m, e, it)| e<-colors)();        
                  }
              );
             }
          );         
      }
      
 void() newEllipse(Fig f, Model m, str lc, void() inner) = () {
      f.at(0, 0
      ,(){
         f.ellipse(fillColor("none"), lineWidth(8), lineColor(lc), FProp::shrink(m[1].shrink)
         ,FProp::grow(m[1].grow), inner);
         }
      );
     };
            
void ellipses(Fig f, Model m) {
      list[str] colors = ["green",  "red", "blue", "grey", "magenta", "brown"];
      f.hcat(fillColor("none"), borderWidth(0) 
      ,() {
          ((){f.at(0, 0 
             ,(){
                f.ellipse(FProp::grow(m[1].grow), lineColor("grey"), fillColor("yellow")
                     ,lineWidth(8),size(<30, 40>));
                }
              );}|newEllipse(f, m, e, it)|e<-colors)();
              f.box(size(<400, 300>)
              ,(){
                 (() {
                     f.at(0, 0
                     ,(){
                         f.ellipse(FProp::shrink(m[1].shrink), lineColor("grey"), lineWidth(1)
                         ,fillColor("antiquewhite"));
                         }
                  );}|newEllipse(f, m, e, it)| e<-colors)();        
                  }
              );
             }
          );         
      }
      
void() newNgon(Fig f, Model m, str lc, void() inner) = () {
      f.at(0, 0
      ,(){
         f.ngon(n(5), fillColor("none"), lineWidth(8), lineColor(lc), FProp::shrink(m[2].shrink)
         ,FProp::grow(m[2].grow), inner);
         }
      );
     };
            
void ngons(Fig f, Model m) {
      list[str] colors = ["green",  "red", "blue", "grey", "magenta", "brown"];
      f.hcat(fillColor("none"), borderWidth(0) 
      ,() {
          ((){f.at(0, 0 
             ,(){
                f.ngon(FProp::n(5), FProp::grow(m[2].grow), lineColor("grey"), fillColor("yellow")
                     ,lineWidth(8),size(<30, 40>));
                }
              );}|newNgon(f, m, e, it)|e<-colors)();
              f.box(size(<200, 200>)
              ,(){
                 (() {
                     f.at(0, 0
                     ,(){
                         f.ngon(FProp::n(5),FProp::shrink(m[2].shrink), lineColor("grey"), lineWidth(1)
                         ,fillColor("antiquewhite"));
                         }
                  );}|newNgon(f, m, e, it)| e<-colors)();        
                  }
              );
             }
          );         
      }


void vennDiagram(Fig f, Model m) = f.overlay(
     size(<350, 150>),
     () {
           f.box(fillColor("none"),  size(<350, 150>), align(topLeft),
             () {f.ellipse(FProp::width(200), FProp::height(100), fillColor("red"),  fillOpacity(0.7));});
           f.box(fillColor("none"),  size(<350, 150>), align(topRight),
             () {f.ellipse(FProp::width(200), FProp::height(100), fillColor("green"),  fillOpacity(0.7));});
           f.box(fillColor("none"),  size(<350, 150>), align(bottomMid),
             () {f.ellipse(FProp::width(200), FProp::height(100), fillColor("blue"),  fillOpacity(0.7));});         
         }
     );
     
 void myView(Model m) {
    div(() {
        h2("Figure using SVG");
        fig(800, 400, (Fig f) {
              vennDiagram(f, m);
         });
        fig(800, 400, (Fig f) {
              boxes(f, m);
         });
         fig(800, 400, (Fig f) {
              ellipses(f, m);
         });
         fig(800, 400, (Fig f) {
              ngons(f, m);
         });
         slider([[
                  [<Msg::shrink, 0, "shrink box:", 0.9, 1, 0.01, 1,"", ""> ]
                 ,[<Msg::grow, 0, "grow box:", 1, 1.2, 0.01, 1,"", ""> ]
                 ,[<Msg::shrink, 1, "shrink ellipse:", 0.9, 1, 0.01, 1,"", ""> ]
                 ,[<Msg::grow, 1, "grow ellipse:", 1, 1.2, 0.01, 1,"", ""> ]
                 ,[<Msg::shrink, 2, "shrink polygon:", 0.9, 1, 0.01, 1,"", ""> ]
                 ,[<Msg::grow, 2, "grow polygon:", 1, 1.2, 0.01, 1,"", ""> ]
                 ]]);   
        });
    }
     
 App[Model] testApp() {
   return app(init, myView, update, 
    |http://localhost:9103|, |project://salix-figure/src|);
   }
   
public App[Model] c = testApp();

public void main() {
     c.stop();
     c.serve();
     }