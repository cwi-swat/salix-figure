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

num lo = -1.324715;

Model startModel = <<lo, 0>, <0, 1>>;

data Msg
   = next1()
   | next2()
   | prev1()
   | prev2()
   ;
   
 Model update(Msg msg, Model m) {
    num step = 0.1;
    switch (msg) {
       case next1(): {
           m.pos1=
              (m.pos1[0]-step < lo || m.pos1[1]>0)?
                <m.pos1[0]+step, crv(m.pos1[0]+step)>
                :
                <m.pos1[0]-step, -crv(m.pos1[0]-step)>;
                }
       case next2(): {
           m.pos2=
              (m.pos2[0]-step < lo || m.pos2[1]>0)?
                <m.pos2[0]+step, crv(m.pos2[0]+step)>
                :
                <m.pos2[0]-step, -crv(m.pos2[0]-step)>;
                }
       case prev1(): {   
             m.pos1=
              (m.pos1[0]-step < lo || m.pos1[1]<0)?
                <m.pos1[0]+step, -crv(m.pos1[0]+step)>
                :
                <m.pos1[0]-step, crv(m.pos1[0]-step)>;
             }
       case prev2(): 
       {   
             m.pos2=
              (m.pos2[0]-step < lo || m.pos2[1]<0)?
                <m.pos2[0]+step, -crv(m.pos2[0]+step)>
                :
                <m.pos2[0]-step, crv(m.pos2[0]-step)>;
             }
       }
     return m;
}

Model init() = startModel;

num crv(num x) { 
   // println(x); println(sqrt(x*x*x-x+1)); 
   return sqrt(x*x*x-x+1);
   }

num cline(Model m, num x)  = ((m.pos2[1]-m.pos1[1])/(m.pos2[0]-m.pos1[0]))
*(x-m.pos1[0])+m.pos1[1];

num lambda(Model m)=((m.pos2[1]-m.pos1[1])/(m.pos2[0]-m.pos1[0]));

tuple[num, num]  P3(Model m) {
    num p1 = lambda(m)*lambda(m)-m.pos1[0]-m.pos2[0];
    num nu = m.pos1[1]-lambda(m)*m.pos1[0];
    num p2 = lambda(m)*p1+nu;
    return <p1, p2>;
    }

void testFigure(Fig f, Model m) = 
      f.vcat(vgap(10)
      ,() {
          f.box(lineWidth(2), lineColor("black")
               , () {
                    f.overlay(size(<600, 600>)
                         ,() {
                             num xs = lo;
                             num r  = 0.05;
                             tuple[num, num] p3 = P3(m);
                             str path1 = p_.M(xs, crv(xs));
                             path1+=intercalate(" ", [p_.L(x, crv(x))|num x<-[-1.30, -1.29.. 1.7]]);
                             str path2 = p_.M(xs, -crv(xs));
                             path2+=intercalate(" ", [p_.L(x, -crv(x))|num x<-[-1.30, -1.29.. 1.7]]);
                             // println(path1);                    
                             f.path(d(path1+path2), viewBox(<-2, -2, 4, 4>),  lineColor("red"));
                             //f.overlay(/*viewBox(<-2, -2, 4, 4>),*/ size(<600, 600>),() {
                             f.at(m.pos1[0]-r, m.pos1[1]-r, viewBox(<-2, -2, 4, 4>), size(<600, 600>), (){f.circle(FProp::r(r),  fillColor("red"));});
                             f.at(m.pos2[0]-r, m.pos2[1]-r, viewBox(<-2, -2, 4, 4>), size(<600, 600>), (){f.circle(FProp::r(r),  fillColor("blue"));});
                             f.at(p3[0]-r, p3[1]-r, viewBox(<-2, -2, 4, 4>), size(<600, 600>), (){f.circle(FProp::r(r),  lineColor("black")
                                                 , fillColor("none"), lineWidth(0.02));}); 
                             f.at(p3[0]-r, -p3[1]-r, viewBox(<-2, -2, 4, 4>), size(<600, 600>), (){f.circle(FProp::r(r),  fillColor("green"));});       
                             //}); 
                             str path3 = p_.M(-2, cline(m, -2));  
                             path3 += p_.L(4, cline(m, 4)); 
                             f.path(d(path3), viewBox(<-2, -2, 4, 4>),  size(<600, 600>), lineColor("grey"));                                        
                            });
                    });
          });

     
void myView(Model m) {
    div(() {
        h2("Elliptic Curve");
        fig(800, 800, (Fig f) {
              testFigure(f, m);
         }); 
         table((){
           tr((){
              td((){button(onClick(next1()),"Next first point ");});
              td((){button(onClick(next2()),"Next second point ");});
              });
           tr((){
              td((){button(onClick(prev1()),"Previous first point ");});
              td((){button(onClick(prev2()),"Previous second point");});
              });   
           });
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