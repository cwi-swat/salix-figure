module salix::demo::graph::RandomGraph

import salix::App;
import salix::HTML;
import salix::SVG;
import salix::Node;
import salix::lib::Dagre;
import IO;
import util::Math;
import Set;
import List;
import salix::lib::Slider;

/* map[str, tuple[list[Attr], lrel[str,str, list[Attr]] 
      ("SYN RCVD":<[], [<"close", "FINWAIT-1", []>, <"rcv ACK of SYN", "FINWAIT-1", []>]>)
*/


alias Graph = list[tuple[list[Attr], lrel[int, list[Attr]]]];

alias GModel = tuple[num width,num height, num scale, int current, int nNodes, int nEdges];

App[GModel] graphApp()
  = app(ginit, gview, gupdate, |http://localhost:9103|, |project://salix-figure/src|);
  

  
Graph getGraph(GModel m) {
      list[tuple[int f, int t]] remember =[];
      int random(GModel m, int n) {
           int e = 0;
           do {
           e = arbInt(m.nNodes-1);
           if (e>=n) e = e+1;
           } while (indexOf(remember, <n, e>)>=0);
           remember+=<n, e>;
           return e;
           }
      return [<[], [<random(m, n),[]>|int e<-[0..m.nEdges]]>|int n<-[0..m.nNodes]];
      }

num startWidth = 200;
num startHeight = 400; 

Graph graph = [];
         
GModel ginit() {
               GModel m = <startWidth, startHeight, 1, 0, 4, 1>;
               graph = getGraph(m);
               return m;
               }

data Msg
  = resizeX(int id, real x)
  | resizeY(int id, real y)
  | nodes(int id, real y)
  | edges(int id, real y)
  | scale(int id, real s)
  | randomGraph()
  ;
  
GModel gupdate(Msg msg, GModel m) {
  switch (msg) {
    case resizeX(_, real x): m.width = x;
    case resizeY(_, real y): m.height = y;
    case nodes(_, real x): m.nNodes = round(x);
    case edges(_, real y): m.nEdges = round(y);
    case scale(_, real s): m.scale = s;
    case randomGraph(): graph = getGraph(m);
    }
  return m;
} 

void rowLayout(void() fs...) {
     table( (){
         tr(
           () {
              for (void() f<-fs) {
                td(valign("top")
                , salix::HTML::style([<"border-style","solid">, <"border-width","4">, <"border-color","grey">])
                , (){f();});
                }
           }     
           );
         });
     }
  
 void gview(GModel m) {
  num lo = 50, hi = 500;
 
  list[list[list[SliderBar]]] sliderBars = [[
                             [
                              < resizeX, 0, "resize X:", lo, hi, 25, startWidth,"<lo>", "<hi>"> 
                             ]
                             ,[
                              < resizeY, 0, "resize Y:", lo, hi, 25, startHeight,"<lo>", "<hi>"> 
                             ]
                             ,[
                              < Msg::scale, 0, "scale:", 0.1, 2, 0.1, 1,"0.1", "2"> 
                             ]
                             ]
                             ,
                            [ [
                              < nodes, 0, "nodes:", 1, 10, 1, 4,"1", "10"> 
                             ]
                             ,[
                              < edges, 0, "edges:", 0, 3, 1, 1,"0", "3"> 
                             ]]
                             ];       
  div(() { 
    h2("Final state machine"); 
    button(onClick(randomGraph()),"Generate New Graph");
    slider(sliderBars);
      dagre("mygraph" /*rankdir("LR"),*/ 
       ,salix::SVG::width("<m.width>px"), salix::SVG::height("<m.height>px"), prop("scale", "<m.scale>")
         , (N n, E e) {
      int i = 0;
      for (tuple[list[Attr], lrel[int, list[Attr]]] out<-graph) {
       list[Attr] attrs = out[0];
       attrs+=[salix::HTML::class("node-content")];
       // attrs += shape("rect");
        n("<i>", [salix::Node::attr("padding","0")]+
             // [salix::SVG::width("40px"), salix::SVG::height("20px")]+
             // salix::HTML::style([<"width", "40px">, <"height", "20px">]) +
          [() { 
          div(attrs+"node<i>"
             /*
             [() {
	          p("node<i>");
	          // svg(salix::SVG::width("40"),salix::SVG::height("40"), (){salix::SVG::circle(salix::SVG::r("10"), cx("15"), cy("15"), fill("red"));});   
	        }]
	        */
	        );
        }]);
        i = i+1;
      }
      i = 0;
      for ( tuple[list[Attr] , lrel[int, list[Attr]]] out<-graph) {
        for (tuple[int to, list[Attr] attrs] l <- out[1]) {
             e("<i>", "<l.to>", l.attrs+[lineInterpolate("lineair")]);        
        }
        i = i+1;
       }          
  });
});
}

public App[GModel] c = graphApp();

public void main() {
     c.stop();
     c.serve();
     } 
  