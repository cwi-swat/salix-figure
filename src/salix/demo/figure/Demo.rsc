module salix::demo::figure::Demo

import util::Math;
import salix::HTML;
import salix::lib::Figure;
import salix::lib::LayoutFigure;
import salix::lib::RenderFigure;
import salix::Core;
import salix::App;
import salix::Slider;

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
/*    
public Figure newBox(Model m, str lc, Figure el) {
      return at(10, 10, box(align = centerMid, lineColor= lc, 
             fillColor = "none", fig = el, lineWidth = 8  
             , shrink=m[0].shrink, grow=m[0].grow
             ));
      }
public Figure boxes(Model m) { 
         list[str] colors = ["green",  "red", "blue", "grey", "magenta", "brown"];
         return hcat(fillColor="none", borderWidth = 0, hgap = 0, figs = [
          (
           at(10, 10, 
           box(grow=m[0].grow, 
             lineColor="grey", fillColor = "yellow", lineWidth = 8, lineOpacity=1.0, size=<30, 40>)
           )
            |newBox(m, e, 
            it)| e<-colors)
          ,
          box(size=<300, 300>,  fig=(at(10, 10,  box(shrink = m[0].shrink, align = centerMid, lineColor="grey", lineWidth=1
                , fillColor = "antiquewhite", lineOpacity=1.0))
          |newBox(m, e, it)| e<-colors))
            ])
         ;
          }
*/

public Figure newEllipse(Model m, str lc, Figure el) {
      return 
      //  at(0, 0,
        ellipse(lineColor= lc, lineWidth = 8 
           , shrink=m[1].shrink, grow=m[1].grow
           , fillColor = "white",  
      fig = el
      //)
      );
      }
public Figure ellipses(Model m) {
      list[str] colors = ["red","blue" ,"grey","magenta", "brown", "green"];
      return hcat(fillColor="none",  hgap = 6,  figs = [
     (idEllipse(34, 24) |newEllipse(m, e,  it)| e<-colors)
      ,
      box(size=<250, 150>, fig=(idEllipse(-1, -1) |newEllipse(m, e, it)| e<-colors))
      ]);
      ;
      }
      
public Figure newNgon(Model m, str lc, Figure el) {
      return 
      at(0, 0, 
             ngon(n = 5,  grow=1.0, align = centerMid, lineColor= lc 
          ,shrink=m[2].shrink, grow=m[2].grow
          ,lineWidth = 8, fillColor = "white", padding=<0,0,0,0>,
      fig = el)
    )
      ;
      }

public Figure ngons(Model m) {
          list[str] colors = ["antiquewhite", "yellow", "red","blue" ,"grey","magenta"];
           return 
              hcat(hgap=6, lineWidth = 4, figs=[
             (idNgon(5, 20) |newNgon(m, e, it)| e<-colors)
             ,
            box(size=<200, 200>, fig= (idNgon(5, -1) |newNgon(m, e, it)| e<-colors))
           ])
           ;}
           
public Figure vennDiagram() = overlay(
     size=<350, 150>,
     figs = [
           box(fillColor="none",  size=<350, 150>, align = topLeft,
             fig = ellipse(width=200, height = 100, fillColor = "red",  fillOpacity = 0.7))
          ,box(fillColor="none", size=<350, 150>, align = topRight,
             fig = ellipse(width=200, height = 100, fillColor = "green", fillOpacity = 0.7))
          ,box(fillColor="none", size=<350, 150>,align = bottomMid,
            fig = ellipse(width=200, height = 100, fillColor = "blue",  fillOpacity = 0.7))
     ]
     );

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


public list[list[Figure]] figures(Model m, bool tooltip) = 
[
   [boxes(m)],
     [ellipses(m)]
    ,[ngons(m)]
    ,[vennDiagram()]
   ]; 
     
      
            
 Figure demoFig(Model m) = grid(align = centerMid, borderStyle="groove", borderWidth=2, vgap=50, figArray=figures(m, false));   
     
 Figure testFigure(Model m) {
     return demoFig(m);
     }
     
 void myView(Model m) {
    div(() {
        h2("Figure using SVG");
        // fig(testFigure(m));
        salix::lib::RenderFigure::figure(800, 400, (Fig f) {
              vennDiagram(f, m);
         });
        salix::lib::RenderFigure::figure(800, 400, (Fig f) {
              boxes(f, m);
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