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
import String;
import salix::lib::Slider;
import salix::lib::Form;

Msg(str) partial(Msg(int, str) f, int p) {return Msg(str y){return f(p, y);};}

alias Constraint = tuple[bool(Model m) cond, str emsg];

alias Model = tuple[num width,num height, Fsm fsm, str buffer, str name, str emsg];

data Msg
  = resizeX(int id, real x)
  | resizeY(int id, real y)
  | nextStep(int id, str next)  // idx<0 -> (next=to) idx>=0 -> (next=inputtext)
  // | changeText(str idx, str txt)
  ;
  
public data Fsm = fsm(str current,  
           map[str, tuple[list[Attr(Model, str)] attrs, lrel[str, str, list[value(Model, Msg(int, str), str)]] out]] graph);

Attr currentMarker(Model m, str x) {
    return salix::HTML::style([<"background-color",x==m.fsm.current?"red":"antiquewhite">]);
    }

App[Model] graphApp()
  = app(ginit, gview, gupdate, |http://localhost:9103|, |project://salix-figure/src|);
  
    

Fsm fsm = fsm("CLOSED", 
        (
         "CLOSED": <[currentMarker], [<"open", "LISTEN", [formPanel("open", 
             [
             < "First Name", str(Model m) {return "";}, str(Model m) {return m.emsg;}>
             ,<"Second Name", str(Model m) {return "";}, str(Model m) {return m.emsg;}>
             ])]>]>
        , "LISTEN": <[currentMarker], [<"rcv SYN", "SYN RCVD", [formPanel("rcv SYN", [])]>
                        ,<"send", "SYN SENT",[formPanel("send", [])] >
                        ,<"close", "CLOSED", [formPanel("close", [])]>
                        ]>
        ,"SYN RCVD": <[currentMarker], [<"close", "FINWAIT-1", [formPanel("close", [])]>
                          ,<"rcv ACK of SYN", "ESTAB", [formPanel("rcv ACK of SYN", [])]>
                          ]>
        ,"SYN SENT": <[currentMarker], [<"rcv SYN", "SYN RCVD", [formPanel("rcv SYN", [])]>
                          ,<"rcv SYN, ACK", "ESTAB", [formPanel("rcv SYN, ACK", [])]>
                          ,<"close", "CLOSED", [formPanel("close", [])]>
                        ]>
        ,"FINWAIT-1": <[currentMarker],[<"rcv ACK of FIN", "FINWAIT-2", [formPanel("rcv ACK of FIN", [])]>
                          ,<"rcv FIN", "CLOSING", [formPanel("rcv FIN", [])]>
                          ]>
        ,"ESTAB": <[currentMarker],    [<"close", "FINWAIT-1", [formPanel("close", [])]>
                          ,<"rcv FIN", "CLOSE WAIT", [formPanel("rcv FIN", [])]>
                          ]>
        ,"CLOSE WAIT": <[currentMarker], [<"close", "LAST-ACK", [formPanel("close", [])]>]>
        ,"FINWAIT-2": <[currentMarker], [<"rcv FIN", "TIME WAIT", [formPanel("rcv FIN", [])]>]>
        ,"CLOSING": <[currentMarker], [<"rcv ACK of FIN", "TIME WAIT", [formPanel("rcv ACK of FIN", [])]>]>
        ,"LAST-ACK": <[currentMarker], [<"rcv ACK of FIN", "CLOSED", [formPanel("rcv ACK of FIN", [])]>]>  
        ,"TIME WAIT": <[currentMarker], [<"timeout", "CLOSED", [formPanel("timeout", [])]>]>              
        ));
        
 public void paintFsm(Fsm fsm, Model m, Msg(int id, str x) msg, list[Attr] attrs) {
        rowLayout(() {
        dagre("mygraph"  
            ,attrs+
             [(N n, E e) {
             for (str x <- fsm.graph) {
                list[Attr] attrs = [attr(m, x)|attr<-fsm.graph[x].attrs];
                 attrs+=[salix::HTML::class("node-content")];
                 n(x, [salix::Node::attr("padding","0")]+[() { 
                 div(attrs+[() {
	                p(x);   
	                }]);
                   }]);
                 }
            for (str x <- fsm.graph) {
              lrel[str, str, list[value(Model, Msg(int, str), str)]] out = fsm.graph[x].out;
               for (tuple[str lab, str to , list[value(Model, Msg(int, str), str)] attrs] edge <-out) {
                 list[value] attrs = [edgeLabel(edge.lab)]+[attr(m , msg, edge.to)|attr<-edge.attrs];
                 e(x, edge.to, attrs);
               }
            }
           }
         ]);  
       }
       , () {ul(salix::HTML::style([<"list-style-type","none">]), () {
           lrel[str, str, list[value(Model, Msg(int, str), str)]] steps = fsm.graph[fsm.current].out;
           for (tuple[str, str, list[value(Model, Msg(int, str), str)]] x<-steps) {
               li((){
              // button(salix::HTML::style([<"width", "200px">]), onClick(msg(x[1])), x[0]); 
              if (x[2] != [],value(Model, Msg(int, str),  str) f:= x[2][-1]) { 
                        if (void()  g:=f(m, msg,  x[1])) g();
                    }           
               });
              }
           });
           }
      );    
   }
  			
num startWidth = 400;
num startHeight = 800;          

Model ginit() = <startWidth, startHeight, fsm, "", "", "">;

Model gupdate(Msg msg, Model m) {
  switch (msg) {
    case resizeX(_, real x): m.width = x;
    case resizeY(_, real y): m.height = y;
    case nextStep(int id, str to): {
       if (id<0) {
             //if (isEmpty(m.buffer)) m.emsg="empty";
             //else 
             {
                m.name = m.buffer;
                m.buffer = "";      
                m.fsm.current=to;
                m.emsg = "";
                }
           }
       else m.buffer=to;  // Text
       }
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

// http://stackoverflow.com/questions/26348038/svg-foreignobjects-draw-over-all-other-elements-in-chrome?rq=1

Attr colorAttribute(str x) {
    return salix::HTML::style([<"background-color",x==fsm.current?"red":"antiquewhite">]);
    }

void gview(Model m) {
  num lo = 200, hi = 1000;
 
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
    h4("<m.name>");
    slider(sliderBars);
    paintFsm(m.fsm, m, nextStep, [salix::SVG::width("<m.width>px"), salix::SVG::height("<m.height>px")]);          
  });
}

public App[Model] c = graphApp();

public void main() {
     c.stop();
     c.serve();
     }