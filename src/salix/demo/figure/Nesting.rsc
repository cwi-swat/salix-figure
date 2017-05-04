module salix::demo::figure::Nesting

import util::Math;
import salix::lib::Figure;
import salix::HTML;
import salix::App;
import salix::lib::RenderFigure;

alias Model = list[tuple[num width, num height]];

num startWidth = 800, startHeight = 800;


Model startModel = [<startWidth, startHeight>];

data Msg
   = resizeX(int id, real x)
   | resizeY(int id, real y)
   ;
   
 Model update(Msg msg, Model m) {
    switch (msg) {
       case resizeX(_, real x): m[0].width = x;
       case resizeY(_, real y): m[0].height = y;
       }
     return m;
}

Model init() = startModel;

void tableTest(Fig f, Model m) = f.grid(borderWidth(4), borderStyle("groove"), 
      () {
            f.row(
               (){
                  list[str] colors = ["red","yellow", "blue"];
                  for (str c<-colors) f.box(size(<40, 40>), fillColor(c));
                  });
            f.row(
               (){
                  list[str] colors = ["green","brown", "yellow"];
                  for (str c<-colors) f.box(size(<40, 40>), fillColor(c));
                  });
         });

void testFigure(Fig f, Model m) = 
      f.ngon(n(6), fillColor("green"), grow(1.2), fillOpacity(0.2), lineWidth(4), lineColor("red"),
         () {f.html(size(<100, 100>),
             () {
            table(
                salix::HTML::style([
                  <"border-style","groove">, <"width", "inherit">,<"height","inherit">]), () {
                 tr(() {
                    td("aap");
                    td("noot");
                    });         
                 tr((){
                     td("teun");
                     td("gijs");
                     }
                   );
                 tr((){
                     td((){
                         fig(15, 15, (Fig f) {
                             f.box(size(<10, 10>), fillColor("blue"));
                             }
                          );
                        });
                      td((){
                         fig(15, 15, (Fig f) {
                             f.box(size(<10, 10>), fillColor("blue"));
                             }
                          );
                        });
                    });
                    
                });
           });});
         
     
void myView(Model m) {
    div(() {
        h2("Figure using SVG");
        fig(800, 200, (Fig f) {
              tableTest(f, m);
         });
         fig(800, 200, (Fig f) {
              testFigure(f, m);
         });
       });
     }
  
    
//---------------------------------------------------------------------------------------------------------------------------------------------------------

App[Model] testApp() {
   return app(init, myView, update, 
    |http://localhost:9103|, |project://salix-figure/src|);
   }
   
public App[Model] c = testApp();

public void main() {
     c.stop();
     c.serve();
     }