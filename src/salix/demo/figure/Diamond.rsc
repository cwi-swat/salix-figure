module salix::demo::figure::Diamond

import util::Math;
import salix::lib::Figure;
import salix::HTML;
import salix::Core;
import salix::App;
import salix::lib::LayoutFigure;
import salix::lib::RenderFigure;
import salix::Slider;

alias Model = list[tuple[num width, num height, num phi]];

num startWidth = 800, startHeight = 800;


Model startModel = [<startWidth, startHeight, 0>];

data Msg
   = resizeX(int id, real x)
   | resizeY(int id, real y)
   | skew(int id, real phi)
   ;
   
 Model update(Msg msg, Model m) {
    switch (msg) {
       case resizeX(_, real x): m[0].width = x;
       case resizeY(_, real y): m[0].height = y;
       case skew(_, real phi): m[0].phi = phi;
       }
     return m;
}

Model init() = startModel;

void myView(Model m) {
    div(() {
        h2("Figure using SVG");
        // fig(testFigure(m), width = m[0].width, height = m[0].height);
        fig(m[0].width, m[0].height, (Fig f) {testFigure(f, m);});
        num lo = 200, hi = 1000;
        list[list[list[SliderBar]]] sliderBars = [[
                             [
                              < resizeX, 0, "resize X:", lo, hi, 50, startWidth,"<lo>", "<hi>"> 
                             ]
                             ,[
                              < resizeY, 0, "resize Y:", lo, hi, 50, startHeight,"<lo>", "<hi>"> 
                             ]
                             ,[
                              < skew, 0, "skew:", 0, PI()/2, PI()/100, 0 ,"90", "0"> 
                             ]
                             ]];
        slider(sliderBars);
        });
    }
    
//---------------------------------------------------------------------------------------------------------

App[Model] testApp() {
   return app(init, myView, update, 
    |http://localhost:9103|, |project://salix-figure/src|);
   }
   
public App[Model] c = testApp();

public void main() {
     c.stop();
     c.serve();
     }
/* 
Figure testFigure(Model m) {
     Points points = [<0, 0>,  <1+sin(m[0].phi), cos(m[0].phi)>, <sin(m[0].phi), cos(m[0].phi)>, <1,0>];
     return rotate(PI()/6, shapes::Figure::polygon(points, lineColor="black", fillColor="yellow", lineWidth=1, viewBox=<0, 0, 2, 2>));
     } 
*/
     
 void testFigure(Fig f, Model m) { 
     Points points = [<0, 0>,  <1+sin(m[0].phi), cos(m[0].phi)>, <sin(m[0].phi), cos(m[0].phi)>, <1,0>];
     f.rotate(PI()/6, (){
         f.polygon(points, lineColor("black"), fillColor("yellow"), lineWidth(1)
        ,viewBox(<0, 0, 2, 2>));
         });
     } 
