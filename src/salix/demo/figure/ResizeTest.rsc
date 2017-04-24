module salix::demo::figure::ResizeTest
import util::Math;
import salix::Figure;
import salix::HTML;
import salix::Core;
import salix::App;
import salix::LayoutFigure;

import salix::Slider;



alias Model = tuple[int width, int height];

Model startModel = <600, 600>;

data Msg
   = resizeX(int id, real x)
   | resizeY(int id, real y)
   ;
   
 Model update(Msg msg, Model m) {
    switch (msg) {
       case resizeX(_, real x): m.width = round(x);
       case resizeY(_, real y): m.height = round(y);
       }
     return m;
}

Model init() = startModel;

Figure testVcat(Model m) = vcat(figs=[
                                       hcat(figs=[
                                           box(lineWidth=4, fillColor="yellow", lineColor="brown")
                                           // htmlText("Hello")
                                          ,box(lineWidth=4, fillColor="yellow", lineColor="brown", padding=<10, 10, 10, 10>
                                          )                                      
                                          ],borderStyle="groove", borderWidth = 2)
                                      ,box(lineWidth=4, fillColor="yellow", lineColor="red")
                                      ]);   
    
    
                                      
Figure testLayout2(Model m) = hcat(figs=[testLayout(m), testLayout(m)]);

Figure testLayout(Model m) {
      return 
      vcat(figs=[box(lineColor="black"), 
           hcat(figs = [shapes::Figure::circle(lineColor="blue"), shapes::Figure::ellipse(cx=40, cy = 90, lineColor="green")]),
           box(lineColor="red")]);
      }
      
 Figure gridExample1(Model m) {
      return grid(size=<m.width, m.height>,
          figArray = [
               [box(fillColor="red", fig=svgText("blabla")), ellipse(fillColor="blue"), box(fillColor="yellow")]
              ,[box(fillColor="green", fig=ellipse(fillColor="yellow")), box(fillColor="purple"),
                       box(fillColor="orange", fig=svgText("blabla"))]
              ]
          );
      }
     
Figure storm(Model m) {
   return vcat(size=<m.width, m.height>,gap=<20, 20>, figs = [
         hcat(figs=[circle(shrink=0.8, lineColor="blue")
               , ellipse(cx=40, cy=90, lineColor="green")]),
         box(lineColor="red"),
         grid(borderStyle="groove", borderWidth=2,
             figArray=[[svgText("A"), svgText("B")],
             [htmlText("C", align=bottomRight), htmlText("D"),
             htmlText("Jurgen"), htmlText("Piet")]])
      ]);
   }

         
 void myView(Model m) {
    div(() {
        h2("Figure using SVG");
        fig(storm(m));
        slider([[
                  [<resizeX, 0, "width:", 0, 1600, 50, m.width, "0", "1600"> ]
                 ,[<resizeY, 0, "height:", 0, 1600, 50, m.height>,"0", "1600" ]
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
