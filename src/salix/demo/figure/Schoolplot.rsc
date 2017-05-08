module salix::demo::figure::Schoolplot

import util::Math;
import Prelude;
import salix::lib::Figure;
import salix::lib::RenderFigure;
import salix::HTML;
import salix::Core;
import salix::App;
import salix::Slider;
alias Model = list[tuple[num side]];

num startSide = 400;


Model startModel = [<startSide>];

data Msg
   = resize(int id, real x)
   ;
   
 Model update(Msg msg, Model m) {
    switch (msg) {
       case resize(_, real x): m[0].side = x;
       }
     return m;
}

Model init() = startModel;

     
void myView(Model m) {
    div(() {
        h2("Figure using SVG");
        fig(m[0].side, m[0].side, (Fig f) {
              thePlot(f, m);
         });
        num lo = 200, hi = 1000;
        list[list[list[SliderBar]]] sliderBars = [[
                             [
                              < resize, 0, "resize:", lo, hi, 50, startSide,"<lo>", "<hi>"> 
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
     
 list[str] innerGridH(int n) {
     num s = 1.0/n;
     return [p_.M(0, y), p_.L(1, y)|y<-[s,2*s..1]];
     }
     
list[str] innerGridV(int n) {
     num s = 1.0/n;
     return [p_.M(x, 0), p_.L(x, 1)|x<-[s,2*s..1]];
     }

list[str] innerSchoolPlot1() {
     num s =0.5;
     return [p_.M(10, 10-i), p_.L(10-i, 0)|i<-[s,s+0.5..10]];
     }
     
list[str] innerSchoolPlot2() {
     num s = 0.5;
     return [p_.M(i, 10), p_.L(0, i)|i<-[s,s+0.5..10]];
     }
   
 void schoolPlot(Fig f, Model g) {
     tuple[num side] m  =g[0];
     num d = m.side-40;
     num r = d;
     f.overlay(size(<d, d>),
         () {
         f.path(lineWidth(1),FProp::d(intercalate(" ", innerSchoolPlot1()+innerSchoolPlot2()))
                  ,fillColor("none"),lineColor("blue"), viewBox(<0, 0, 10, 10>));
         f.at(150*d/400, 150*d/400, () {f.circle(FProp::r(r/10),  fillColor("yellow")
                  ,lineWidth(10), lineColor("red"), lineOpacity(0.5), fillOpacity(0.5),
                  () {
                     f.htmlText(
                      FProp::style([<"color", "darkblue">, <"font-weight","bold">, <"fill-opacity","1.0">]),"Hallo");
                   }
                  );
                 }
                );
         f.at(50*d/400, 50*d/400, () {f.circle(lineWidth(10), lineColor("red"), fillColor("none"),   
            () {
               f.box(FProp::width(50*d/400), FProp::height(50*d/400), lineColor("grey"), lineWidth(10), fillColor("antiquewhite"));
               }
              );
            }
            );
        f.at(250*d/400, 250*d/400, () {f.circle(lineWidth(10), grow(1.0), fillColor("none"), lineColor("brown")
             ,() {f.ngon(FProp::n(7), FProp::r(r/10), lineWidth(10), lineColor("grey"), fillColor("none"));}
             );
           });
         })
        ;
     } 

void simpleGrid(Fig f, Model m) {
     f.overlay(fillColor("none")
             , () {
                f.path(d(intercalate(" ",innerGridV(10)+innerGridH(10))),
                   viewBox(<0, 0, 1, 1>), fillColor("none"),
                   lineColor("lightgrey"), lineWidth(1));
                 schoolPlot(f, m);
        }
        );
     }
     
void labeled(Fig f, Model m, void(Fig, Model) g) {
        f.hcat(lineWidth(0), size(<m[0].side, m[0].side>),
          () {
             f.vcat((){gridLabelY(f, m);});
             f.vcat(lineWidth(0), () {
                    f.box(lineWidth(4), lineColor("grey"), (){g(f, m);});
                    f.hcat((){gridLabelX(f, m);});
                     }
                 );
           });
      }
     
 void gridLabelX(Fig f, Model m) {
     for (int i<-[1..10]) {
         f.box(lineWidth(0), lineColor("none"), FProp::width(m[0].side/10), FProp::height(20), () {f.htmlText("<i>");});
         }
     }
     
 void gridLabelY(Fig f, Model m) {
     for (int i<-[9, 8..0]) {
          f.box(lineWidth(0), lineColor("black"), FProp::width(20), FProp::height(m[0].side/10) ,  () {f.htmlText("<i>");});
          }
     }
     
 void labeledGrid(Fig f, Model m) {
    return labeled(f, m, simpleGrid);   
    }
    
 void thePlot(Fig f, Model m) = labeledGrid(f, m);
 
   
