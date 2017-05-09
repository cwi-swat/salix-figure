module salix::demo::figure::Tests
import util::Math;
import Prelude;
import salix::lib::Figure;
import salix::lib::RenderFigure;
import salix::HTML;
import salix::Core;
import salix::App;
import salix::Slider;

//-------------------------------------------------------------------MODEL--------------------------------------------------------------------------------

alias Model = list[int];

Model startModel = [];

data Msg
   = doIt()
   ;

Model update(Msg msg, Model m) {
         return m;
}

Model init() = startModel;

        
 void  b(Fig f, str color, num x, num y) =  f.at(x, y, () {
                 f.box(size(<100, 100>), lineWidth(2), lineColor("black"), fillColor(color));
                 });
 
 void tests(Fig f, Model m) {
     f.vcat(borderWidth(4), borderColor("grey"), borderStyle("groove"), vgap(4), () { 
      f.overlay(() {b(f, "red", 0, 0);b(f, "blue",40, 0); b(f, "yellow", 0, 40);})
     ;f.box(size(<100, 100>), fillColor("green"), lineWidth(2), lineColor("black"))
     ;f.box(size(<80, 40>), lineColor("black"), lineWidth(2), fillColor("antiquewhite"), 
           () {
              f.htmlText("Hallo", fontSize(20), fontColor("darkred"));
              })
      
      ;f.box(fillColor("antiquewhite"), lineWidth(8), lineColor("blue"), align(centerMid), grow(1.0)
              , () {f.box( size(<200, 200>), fillColor("gold"), lineWidth(8), lineColor("red"));}
              )
      ;f.box(align(topLeft),grow(1.5),fillColor("antiquewhite"), lineWidth(2), lineColor("black")
         ,() {f.box(size(<50, 50>),fillColor("yellow"));}
         )
      ;f.box(align(centerMid),grow(1.5),fillColor("antiquewhite"), lineWidth(2), lineColor("black")
         , () {f.box(size(<50, 50>),fillColor("yellow"));}
         )
      ;f.box(align(bottomRight),grow(1.5),fillColor("antiquewhite"), lineWidth(2), lineColor("black")
         ,() {f.box(size(<50, 50>),fillColor("yellow"));}
         )
      ;f.box(size(<75,75>),   align(topLeft), fillColor("antiquewhite"), lineColor("black"), lineWidth(2)
         , () {f.box(shrink(0.666), fillColor("yellow"));}
         )
      ;f.box(size(<75,75>), align(centerMid), fillColor("antiquewhite"), lineColor("black"),lineWidth(2)
         , () {f.box(FProp::shrink(0.666), fillColor("yellow"));}
         )
      ;f.box(size(<75,75>), align(bottomRight), fillColor("antiquewhite"), lineColor("black"), lineWidth(2)
         , () {f.box(FProp::shrink(0.666), fillColor("yellow"));}
         )
      ;f.box(size(<75,75>), align(centerMid), fillColor("antiquewhite"), lineColor("black"),lineWidth(2)
           , () {f.circle(FProp::shrink(0.666), fillColor("yellow"), lineWidth(2), lineColor("brown"));}
         )
        
      ;f.hcat(align(topLeft), borderWidth(0), lineWidth(0), hgap(0)
           , () {f.box(size(<30, 30>), fillColor("antiquewhite"));
                 f.box(size(<50, 50>), fillColor("yellow"));
                 f.box(size(<70, 70>), fillColor("red"));
                }
        )
      ;f.hcat(align(centerMid), lineWidth(0), hgap(0), borderWidth(0)
          ,() {f.box(size(<30, 30>), fillColor("antiquewhite"));
               f.box(size(<50, 50>), fillColor("yellow"));
               f.box(size(<70, 70>), fillColor("red"));
               }
        )
       ;f.hcat(align(bottomRight), lineWidth(0), hgap(0), borderWidth(0)
           ,() {f.box(size(<30, 30>), fillColor("antiquewhite"));
                f.box(size(<50, 50>), fillColor("yellow"));
                f.box(size(<70, 70>), fillColor("red"));
                }    
        )
       ;f.hcat(FProp::width(210), FProp::height(90), align(bottomRight), hgap(0), borderWidth(0)
          , () {f.box(FProp::shrink(1.0), fillColor("blue"));
                f.box(FProp::shrink(0.7), fillColor("yellow"));
                f.box(FProp::shrink(1.0), fillColor("red"));
                }
        )
       ;f.vcat(FProp::width(200), FProp::height(70),  align(bottomLeft)
           , () {f.box(FProp::shrink(1.0), fillColor("blue"));
                 f.box(FProp::shrink(0.5), fillColor("yellow"));
                 f.box(FProp::shrink(1.0), fillColor("red"));
                 }
        )
       ;f.vcat(size(<200, 60>)
           ,() {
               f.htmlText(align(centerRight), fontSize(14), fontColor("blue"),"a");
               f.htmlText(align(centerRight),fontSize(14), fontColor("blue"),"bb");
               f.htmlText(align(centerRight),fontSize(14), fontColor("blue"), "ccc");
               }
        )
        ;f.grid(FProp::width(200), FProp::height(70), align(bottomLeft), () {
            f.row(() {f.box(FProp::shrink(0.5), fillColor("blue"));});
            f.row(
                 () {f.box(FProp::shrink(0.3), fillColor("yellow"));
                     f.box(FProp::shrink(0.5), fillColor("red"));
                    }
            );
          }
        )
        ;f.grid(FProp::width(200), FProp::height(70), align(centerMid), () {
           f.row(() {f.box(FProp::shrink(0.5), fillColor("blue"));});
           f.row(
                 () {f.box(FProp::shrink(0.3), fillColor("yellow"));
                     f.box(FProp::shrink(0.5), fillColor("red"));
                    }
            );
           }       
        );
      //  ,graph(width(200), FProp::height(200), nodes=[<"a", box(size(<60, 60>),fig=htmlText("aap", fontSize(14), fontColor("blue")), grow(1.6), fillColor("beige"))>
      //                                   , <"b", box(size(<60, 60>),fig=htmlText("noot", fontSize(14), fontColor("blue")), grow(1.6), fillColor("beige"))>]
      //                              ,edges=[edge("a","b")])
        }
        );
     } 
     
 void myView(Model m) {
    div(() {
        // h2("Figure using SVG")
        fig((Fig f) {
              tests(f, m);
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