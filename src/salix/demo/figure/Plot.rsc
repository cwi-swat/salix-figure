module salix::demo::figure::Plot
import util::Math;
import salix::lib::Figure;
import salix::HTML;
import salix::Core;
import salix::App;
import salix::lib::RenderFigure;
import salix::lib::Slider;
import Prelude;


alias Model = list[tuple[num x, num f]];

Model startModel = [<0, 1>, <0, 1>];

data Msg
   = moveX(int id, real x)
   | frek(int id,  real f)
   ;
   
 Model update(Msg msg, Model m) {
    switch (msg) {
       case moveX(int id, real x): m[id].x = x;
       case frek(int id, real f):m[id].f = f;
       }
     return m;
}

Model init() = startModel;


void testFigure(Fig f, Model m) = 
      f.vcat(vgap(10)
      ,() {
          f.box(lineWidth(2), lineColor("black")
               , () {
                    f.overlay(size(<600, 200>)
                         ,() {
                             int n  = 20;
                             str path1 = p_.M(0, -sin(m[0].x));
                             path1+=intercalate(" ", [p_.L(m[0].f*2*PI()*i/n, -sin(2*PI()*(i/n)+m[0].x))|num i<-[1, 2..n+1]]);
                             f.path(d(path1), viewBox(<0, -1, 2*PI(), 2>), fillColor("none"), lineColor("red")
                             , () {
                                f.circle(r(3), fillColor("grey"), viewBox(<0, 0, 600, 600>), marker("mid"));
                                f.box(size(<16, 6>), fillColor("brown"), viewBox(<0, 0, 600, 600>), marker("start"));
                                f.box(size(<16, 6>), fillColor("greenyellow"), viewBox(<0, 0, 600, 600>), marker("end"));
                                }
                             );
                             str path2 = p_.M(0, -cos(m[1].x));
                             path2+=intercalate(" ", [p_.L(m[1].f*2*PI()*i/n, -cos(2*PI()*(i/n)+m[1].x))|num i<-[1, 2..n+1]]);
                             f.path(d(path2), viewBox(<0, -1, 2*PI(), 2>), fillColor("none"), lineColor("blue"));
                             // f.at(500, 150, (){f.circle(r(20), fillColor("red"));});
                          });              
                 });
           f.hcat(FProp::height(30)
                 ,() {
                     f.box(lineColor("black")
                     ,() {
                            f.htmlText(fontColor("red"), "sin: x=<m[0].x>");
                         });
                     f.box(lineColor("black")
                     ,() {
                            f.htmlText(fontColor("blue"), "cos: x=<m[1].x>");
                          });
                     });  
          });

     
void myView(Model m) {
    div(() {
        h2("Figure using SVG");
        fig(800, 400, (Fig f) {
              testFigure(f, m);
         });
        slider([[
                  [<moveX, 0, "sin:", 0, 3.14, 0.1, 0, "0", "2pi"> ]
                 ,[<moveX, 1, "cos:", 0, 3.14, 0.1, 0, "0", "2pi"> ]
                 ]]);   
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