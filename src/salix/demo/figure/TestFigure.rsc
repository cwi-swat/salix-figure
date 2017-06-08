module salix::demo::figure::TestFigure
import salix::lib::LayoutFigure;
import salix::lib::Figure;
import salix::lib::RenderFigure;
import salix::HTML;
import salix::Core;
import salix::App;
import salix::lib::Slider;
import Prelude;

alias Model = tuple[str innerFill, num middleGrow];

data Msg
   = doIt()
   ;

/*
Figure testFigure(Model m) {
    Figure down =  box(width=50, height = 50,
                                 fillColor=m.innerFill,        lineWidth  = 4, lineColor="magenta");
    Figure middle= box(grow=m.middleGrow, fillColor="antiquewhite",lineWidth =  8, lineColor="green", align=bottomRight, fig = down);
    Figure top =  
             box(grow=1.4, fillColor="lightyellow", lineWidth = 16, lineColor="brown" ,align=topLeft,     fig=middle
             , padding=<10, 10, 10, 10>);
    return top;
    }  
*/
    
void testFigure(Fig f, Model m) {
    void down (Fig f)  = f.box(FProp::width(50), FProp::height(50));
    void middle(Fig f, Model m) = f.box(FProp::grow(m.middleGrow), FProp::fillColor(m.innerFill),FProp::lineWidth(8), FProp::lineColor("green")
         ,FProp::align(bottomRight), () {down(f);});
    void top(Fig f, Model m) =
             f.box(FProp::grow(1.4), FProp::fillColor("lightyellow"), FProp::lineWidth(16)
             ,FProp::lineColor("brown") ,FProp::align(topLeft)
             ,FProp::padding(<10, 10, 10, 10>), () {middle(f, m);});
    top(f, m);       
    }
 
/*   
fig(800, 400, (Fig f) {
              vennDiagram(f, m);
         });  
*/

/* Proposal
void testFigure(Fig f, Model m) {
  void() down(Fig f) = () {f.box(f.box(FProp::width(50), FProp::height(50));};
  void() middle(Fig f, Model m) = () {
    f.box(FProp::grow(m.middleGrow)
         ,FProp::fillColor(m.innerFill)
         ,FProp::lineWidth(8)
         ,FProp::lineColor("green")
         ,FProp::align(bottomRight)) 
         o down(f);
    };
  void() top(Fig f, Model m) =() {
    f.box(FProp::grow(1.4), FProp::fillColor("lightyellow")
         ,FProp::lineWidth(16)
         ,FProp::lineColor("brown") 
         ,FProp::align(topLeft)
         ,FProp::padding(<10, 10, 10, 10>)) 
         o middle(f, m);
     };
     top(f, m)(); 
   }  
*/

void myView(Model m) {
    div(() {
        h2("Figure using SVG");
        // fig(testFigure(m));
        fig(200, 200, (Fig f) {
            testFigure(f, m);
        });
        button(salix::HTML::style([<"width", "200px">]), onClick(doIt()), 
                   "Push"); 
    });
    }
    
Model init() = <"snow", 1.2>;

Model update(Msg msg, Model m) {
    switch (msg) {
       case doIt():
          if (m.innerFill=="snow") {
              m.innerFill= "lightgrey";
              m.middleGrow = 1.5;
              }
          else {
              m.innerFill = "snow";
              m.middleGrow = 1.2;
              }
         }
         return m;
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