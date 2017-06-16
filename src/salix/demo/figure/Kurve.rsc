module salix::demo::figure::Kurve
import util::Math;
import salix::lib::Figure;
import salix::HTML;
import salix::Core;
import salix::App;
import salix::lib::RenderFigure;
import salix::lib::Slider;
import Prelude;


alias Model = tuple[tuple[num, num] pos1, tuple[num, num] pos2];

Model startModel = <<-1.324715, 0>, <0, 1>>;

data Msg
   = next1()
   | next2()
   | prev1()
   | prev2()
   ;
   
 Model update(Msg msg, Model m) {
    switch (msg) {
       case next1(): ;
       case next2(): ;
       case prev1(): ;
       case prev2(): ;
       }
     return m;
}

Model init() = startModel;

num crv(num x) { 
   // println(x); println(sqrt(x*x*x-x+1)); 
   return sqrt(x*x*x-x+1);
   }


void testFigure(Fig f, Model m) = 
      f.vcat(vgap(10)
      ,() {
          f.box(lineWidth(2), lineColor("black")
               , () {
                    f.overlay(size(<600, 600>)
                         ,() {
                             num xs = -1.324715;
                             str path1 = p_.M(xs, crv(xs));
                             path1+=intercalate(" ", [p_.L(x, crv(x))|num x<-[-1.30, -1.29.. 1.7]]);
                             str path2 = p_.M(xs, -crv(xs));
                             path2+=intercalate(" ", [p_.L(x, -crv(x))|num x<-[-1.30, -1.29.. 1.7]]);
                             // println(path1);                    
                             f.path(d(path1+path2), viewBox(<-2, -2, 4, 4>),  lineColor("red"));
                             f.overlay(/*viewBox(<-2, -2, 4, 4>),*/ size(<600, 600>),() {
                             f.at(m.pos1[0], m.pos1[1], (){f.circle(r(20), fillColor("red"));}); 
                             });                                            
                            });
                    });
          });

     
void myView(Model m) {
    div(() {
        h2("Elliptic Curve");
        fig(800, 800, (Fig f) {
              testFigure(f, m);
         }); 
         button(onClick(next1()),"Next first point ");
         button(onClick(next2()),"Next second point");
         button(onClick(prev1()),"Previous first point ");
         button(onClick(prev2()),"Previous second point");
        });
    }
    
//---------------------------------------------------------------------------------------------------------------------------------------------------------

App[Model] testApp() {
   return app(init, myView, update, 
    |http://localhost:9103|, |project://salix-figure/src|);
   }
   
public App[Model] c = testApp();

public void show() {
   for (num x<-[-1, -1.01 .. -1.5]) println("x=<x> f(x)=<x*x*x-x+1>");
   }

public void main() {
     c.stop();
     c.serve();
     }