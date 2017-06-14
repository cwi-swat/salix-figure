module salix::demo::figure::Template

import util::Math;
import salix::lib::Figure;
import salix::HTML;
import salix::Core;
import salix::App;
import salix::lib::LayoutFigure;
import salix::lib::RenderFigure;
import salix::lib::Slider;

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
        fig(800, 400, (Fig f) {
              testFigure(f, m);
         });
        num lo = 200, hi = 1000;
        list[list[list[SliderBar]]] sliderBars = [[
                             [
                              < resizeX, 0, "resize X:", lo, hi, 50, startWidth,"<lo>", "<hi>"> 
                             ]
                             ,[
                              < resizeY, 0, "resize Y:", lo, hi, 50, startHeight,"<lo>", "<hi>"> 
                             ]
                             ]];
        slider(sliderBars);
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
     
