module salix::demo::graph::Fsm

import salix::App;
import salix::HTML;
import salix::SVG;
import salix::Node;
import salix::lib::Dagre;
import IO;
import util::Math;
import Set;
import List;
import salix::Slider;

alias GModel = tuple[num width,num height, str  current, map[str, list[Attr]] states, lrel[str, str, list[Attr]] edges, map[str, lrel[str, str]] out];

App[GModel] graphApp()
  = app(ginit, gview, gupdate, |http://localhost:9103|, |project://salix-figure/src|);
  
str radius = "10px";


map[str, list[Attr]] states = (
                "CLOSED":[],              
    			"LISTEN": [],
    			"SYN RCVD":[],
				"SYN SENT": [],	
                "ESTAB" : [],	
                "FINWAIT-1": [],
                "CLOSE WAIT": [],
                "FINWAIT-2": [],
                "CLOSING":  [],
                "LAST-ACK": [],
                "TIME WAIT": []
           );
           
           
 lrel[str, str, list[Attr]] edges = [<"CLOSED", "LISTEN",  [edgeLabel("open"), labelStyle([<"font-weight","bold">,<"fill","blue">])]>, 
    			<"LISTEN", "SYN RCVD",[edgeLabel("rcv SYN"), labelPos("r"), labelStyle([<"font-style","italic">, <"lineColor", "red">])]>,
    			<"LISTEN", "SYN SENT",[edgeLabel("send"), labelPos("r"), labelStyle([<"font-style","italic">, <"lineColor", "red">])]>,
    			<"LISTEN",		"CLOSED",    [edgeLabel("close"), labelStyle(<"font-style","italic">)]>,
    			<"SYN RCVD", 	"FINWAIT-1", [edgeLabel("close"), labelStyle(<"font-style","italic">)]>,
    			<"SYN RCVD", 	"ESTAB",     [edgeLabel("rcv ACK of SYN"), labelStyle(<"font-style","italic">)]>,
    			<"SYN SENT",   	"SYN RCVD",  [edgeLabel("rcv SYN"), labelStyle(<"font-style","italic">)]>,		
   				<"SYN SENT",   	"ESTAB",     [edgeLabel("rcv SYN, ACK"), labelStyle(<"font-style","italic">)]>,
    			<"SYN SENT",   	"CLOSED",    [edgeLabel("close"), labelStyle(<"font-style","italic">)]>,
    			<"ESTAB", 		"FINWAIT-1", [edgeLabel("close"), labelStyle(<"font-style","italic">)]>,
    			<"ESTAB", 		"CLOSE WAIT",[edgeLabel("rcv FIN"), labelStyle(<"font-style","italic">)]>,
    			<"FINWAIT-1",  	"FINWAIT-2",  [edgeLabel("rcv ACK of FIN"), labelStyle(<"font-style","italic">)]>,
    			<"FINWAIT-1",  	"CLOSING",    [edgeLabel("rcv FIN"), labelStyle(<"font-style","italic">)]>,
    			<"CLOSE WAIT", 	"LAST-ACK",    [edgeLabel("close"), labelStyle(<"font-style","italic">)]>,
    			<"FINWAIT-2",  	"TIME WAIT",  [edgeLabel("rcv FIN"), labelStyle(<"font-style","italic">)]>,
    			<"CLOSING",    	"TIME WAIT",  [edgeLabel("rcv ACK of FIN"), labelStyle(<"font-style","italic">)]>,
    			<"LAST-ACK",   	"CLOSED",     [edgeLabel("rcv ACK of FIN"), labelStyle(<"font-style","italic">)]>,
    			<"TIME WAIT",  	"CLOSED",     [edgeLabel("timeout=2MSL"), labelStyle(<"font-style","italic">)]>
  			];
           
GModel ginit() = <400, 800, "CLOSED", states, edges, getOutEdges()>;

data Msg
  = resizeX(int id, real x)
  | resizeY(int id, real y)
  | nextStep(str to)
  ;


GModel gupdate(Msg msg, GModel m) {
  switch (msg) {
    case resizeX(_, real x): m.width = x;
    case resizeY(_, real y): m.height = y;
    case nextStep(str to): {
       m.current=to;
    }
  }
  return m;
}

map[str, lrel[str, str]] getOutEdges() {
     map[str,  lrel[str, str]] r = (x:[]|str x<-states);
     for (tuple[str from, str to , list[Attr] attrs] x<-edges) {
        for (/ attr("label", str lab):=x.attrs)
                 r[x.from]=r[x.from]+[<lab, x.to>]; 
         }
     return r; 
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

// http://stackoverflow.com/questions/26348038/svg-foreignobjects-draw-over-all-other-elements-in-chrome?rq=1

Attr colorAttribute(GModel m, str x) {
    return salix::HTML::style([<"background-color",x==m.current?"red":"antiquewhite">]);
    }

void gview(GModel m) {
  num lo = 200, hi = 1000;
  num startWidth = 400;
  num startHeight = 800;
  list[list[list[SliderBar]]] sliderBars = [[
                             [
                              < resizeX, 0, "resize X:", lo, hi, 50, startWidth,"<lo>", "<hi>"> 
                             ]
                             ,[
                              < resizeY, 0, "resize Y:", lo, hi, 50, startHeight,"<lo>", "<hi>"> 
                             ]
                             ]];       
  div(() { 
    h2("Final state machine"); 
    slider(sliderBars);
    rowLayout(() {
      dagre("mygraph" /*rankdir("LR"),*/ 
       ,salix::SVG::width("<m.width>px"), salix::SVG::height("<m.height>px")
         , (N n, E e) {
      for (str x <- m.states) {
       list[Attr] attrs = m.states[x];
       attrs+=[salix::HTML::class("node-content")];
       attrs+=[colorAttribute(m, x)];
       // attrs += shape("rect");
        n(x, [salix::Node::attr("padding","0")]+[() { 
          div(attrs+[() {
	          p(x);
	          //svg(salix::SVG::width("40"),salix::SVG::height("40"), (){salix::SVG::circle(salix::SVG::r("10"), cx("15"), cy("15"), fill("red"));});   
	        }]);
        }]);
      }
      for (<str x, str y, list[Attr] attrs> <- m.edges) {
        e(x, y, attrs+[lineInterpolate("lineair")]);
        }
       }
      );
      },
        () {ul(salix::HTML::style([<"list-style-type","none">]), () {
           lrel[str, str] steps = m.out[m.current];
           // println(steps);
           for (tuple[str, str] x<-steps) {
               li((){button(salix::HTML::style([<"width", "200px">]), onClick(nextStep(x[1])), x[0]);});
              }
           });
           }
    );         
  });
}

public App[GModel] c = graphApp();

public void main() {
     c.stop();
     c.serve();
     }