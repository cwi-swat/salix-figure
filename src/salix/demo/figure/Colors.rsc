module salix::demo::figure::Colors
import util::Math;
import salix::HTML;
import salix::App;
// import salix::Core;
import salix::lib::LayoutFigure;
import salix::lib::Figure;
import Prelude;

alias Model = list[list[tuple[int width, int height, str fillColor]]];


// alias Model = tuple[int width, int height];
list[str] selectColors= ["antiqueWhite", "green", "blue", "royalblue", "steelblue", "mediumblue", "lightblue", " navy","coral", "red"];

Model startModel = [[<65, 65, "antiqueWhite">|__<-[0..(i%2==0?4:3)]]|int i<-[0..5]];

// Model startModel = <50, 50>;

data Msg
  = wdth(tuple[int, int] p, int w)
  | hght(tuple[int, int] p, int h)
  | fillColor(tuple[int, int] p, str c)
  ;

// \<input type=\"range\" min=\"<f.low>\" max=\"<f.high>\" step=\"<f.step>\" id=\"<id>\"  class=\"form\" value= \"<f.\value>\"/\>

Model update(Msg msg, Model m) {
    switch (msg) {
       case wdth(tuple[int, int] p, int w): {m[p[0]][p[1]].width=w;}
       case hght(tuple[int, int] p, int h): {m[p[0]][p[1]].height=h;}
       case fillColor(tuple[int, int] p, str c): {m[p[0]][p[1]].fillColor=c;}
       }
     return m;
     }

Model init() = startModel;

void slider(Msg(int) msg, int low, int high) {
    salix::HTML::input(
            salix::HTML::\type("range")
           ,salix::HTML::min("<low>")
           ,salix::HTML::max("<high>")
           ,salix::HTML::onChange(msg)
         );
    }
    
void colorSelector(int i, int j, list[str] colors) {
         salix::HTML::span((){   
         salix::HTML::text("Select Color");
         salix::HTML::select([salix::HTML::onChange(partial(fillColor, <i, j>))]+[(){
             for (str color<-colors)
              salix::HTML::option(color);
             }]);
           // +[salix::HTML::onChange(msg)]
     });
    }
    
 Figure testFigure(Model m) {
   return ellipse(lineWidth=4, lineColor="red"// , grow=sqrt(2)
      , fig=
     grid(borderStyle="groove", borderWidth= 4,
         figArray=[[
         box(width=d.width, height = d.height, fillColor= d.fillColor
        // ,lineWidth =2, lineColor="coral"
        // , fig = box(fillColor="navy", shrink=0.7,lineColor = "green", lineWidth = 2)
        )|d<-row]| row<-m]));
   }
   
void tableCell(int row, int j, int low, int high, bool hgh) {
     td(hgh?"height":"width:");
     td("<low>");
     td(() {slider(partial((hgh?hght:wdth),<row, j>), low, high);});
     td("<high>");
     }
   
void tableRow(int row, int ncols, int low, int high) {
      list[tuple[str, str]] styles=[];     
       styles += <"border-spacing", "5px 5px">;
       styles+= <"border-collapse", "separate">;
       styles+= <"border-width", "2">;
       // styles+= <"border-color", "grey">; 
       styles+= <"border-style", "groove
       ">;     
       tr((){ 
         for (j<-[0..ncols]) {
            td(salix::HTML::style(styles), (){table(salix::HTML::style(styles), (){
            tr((){
               tableCell(row, j, low, high, false);
               });
            tr((){
               tableCell(row, j, low, high, true);
               });
            });
            colorSelector(row, j, selectColors);
            });}
           });
   }
   
void widthHeightSlider(int low, int high, Model m) { 
       list[tuple[str, str]] styles=[];     
       styles += <"border-spacing", "5px 5px">;
       styles+= <"border-collapse", "separate">;
       styles+= <"width", "1000px">;
       // Msg(int) q1(){return (int v) {wdth(v);};}
       // q.x=1;
       table(salix::HTML::style(styles), (){
            for (int i<-[0..size(m)]) {
                tableRow(i, size(m[i]), low, high);                      
                }
           });
    }
    
Msg(int) partial(Msg(tuple[int, int], int) f, tuple[int, int] p) {return Msg(int y){return f(p, y);};}

Msg(str) partial(Msg(tuple[int, int], str) f, tuple[int, int] p) {return Msg(str y){return f(p, y);};}


void myView(Model m) { 
    int low = 30; int high = 100;
    div(() {
       h2("Figure using Slider");
       fig(testFigure(m));
       //fig(emptyFigure());
          widthHeightSlider(low, high, m);
           });
       
       }
    
//---------------------------------------------------------------------------------------------------------------------------------------------------------

App[Model] testApp() {
   return app(init, myView, update, 
    |http://localhost:9112/salix/demo/figure/index.html|, |project://salix-figure/src|);  
   }
   
public App[Model] c = testApp();

public void main() {
     c.stop();
     c.serve();
     }