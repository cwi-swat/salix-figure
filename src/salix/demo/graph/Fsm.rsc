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
import salix::lib::Slider;

Msg(str) partial(Msg(str, str) f, str p) {return Msg(str y){return f(p, y);};}

alias Constraint = tuple[bool(Model m) cond, str emsg];

alias FormEntry = tuple[str idx, value startValue, str fieldName, list[Constraint] constraints];

alias Model = tuple[num width,num height, Fsm fsm, str buffer, str name];

data Msg
  = resizeX(int id, real x)
  | resizeY(int id, real y)
  | nextStep(str to)
  | changeText(str idx, str txt)
  ;
  

void formRow(Model m, Msg(str, str) msg, FormEntry fe) {
    tr([]+[() {
             if (str s:=fe.startValue) {
                td(() {
                  salix::HTML::span(fe.fieldName);
                  });
                td(() {
                  input(salix::HTML::\type("text"), salix::HTML::size("10"), salix::HTML::\value(s)
                  ,onInput(partial(msg, fe.idx)));
                  });
                }
                 td(() {
                  for (Constraint c<-fe.constraints)  {
                      if (!c.cond(m)) {
                           salix::HTML::span(c.emsg);
                           }
                      }
                  });            
             }]
          );
    }
  

(void() (Model, Msg(str), str, str, str)) genInputNext(str buttonLab, list[FormEntry] lines) {
  return void() (Model m, Msg(str) msg , str from, str lab, str to) {
         return () {
            list[tuple[str, str]] styles = [<"min-width", "400px">
                                         , <"border-width","2">
                                         // , <"border-color","black">
                                         , <"border-style", "groove">];
            table([salix::HTML::style(styles)]+[() {
              for (FormEntry  fe <-lines)
                 formRow(m, changeText, fe); 
             tr(() {
               td([salix::HTML::colspan(2), salix::HTML::align("center")]+[() {
                   button(salix::HTML::style([<"width", "200px">]), onClick(msg(to)), buttonLab);
               }]);
               }); 
           }]);
      
      };
      };
  }
  
public data Fsm = fsm(str current,  
           map[str, tuple[list[Attr(Model, str)] attrs, lrel[str, str, list[value(Model, Msg(str), str, str, str)]] out]] graph);

Attr currentMarker(Model m, str x) {
    return salix::HTML::style([<"background-color",x==m.fsm.current?"red":"antiquewhite">]);
    }

App[Model] graphApp()
  = app(ginit, gview, gupdate, |http://localhost:9103|, |project://salix-figure/src|);
  
  
void() inputNext(Model m, Msg(str) msg, str from, str lab, str to) {
  list[tuple[str, str]] style = [<"border-style", "solid">, <"border-color","grey"> 
      , <"border-width","2">];
  return () {table(() {
      tr(() {
         td(() {
           button(salix::HTML::style([<"width", "200px">]), onClick(msg(to)), lab);
           });
         td(salix::HTML::style(style), "Name:");
         td(() {
            input(salix::HTML::\type("text"), salix::HTML::size("10"), salix::HTML::\value("")
            , onInput(changeText));
            }) ;
           });   
         });
  };
  }
  
void() next(Model m, Msg(str) msg, str from, str lab, str to) {
    return () {
              button(salix::HTML::style([<"width", "200px">]), onClick(msg(to)), lab);
              };
    }
    

Fsm fsm = fsm("CLOSED", 
        (
         "CLOSED": <[currentMarker], [<"open", "LISTEN", [genInputNext("open", 
             [
             <"1", "Bert", "First Name", []>
             ,<"2", "Lisser", "Second Name", []>
             ])]>]>
        , "LISTEN": <[currentMarker], [<"rcv SYN", "SYN RCVD", [next]>
                        ,<"send", "SYN SENT", [next]>
                        ,<"close", "CLOSED", [next]>
                        ]>
        ,"SYN RCVD": <[currentMarker], [<"close", "FINWAIT-1", [next]>
                          ,<"rcv ACK of SYN", "ESTAB", [next]>
                          ]>
        ,"SYN SENT": <[currentMarker], [<"rcv SYN", "SYN RCVD", [next]>
                          ,<"rcv SYN, ACK", "ESTAB", [next]>
                          ,<"close", "CLOSED", [next]>
                        ]>
        ,"FINWAIT-1": <[currentMarker],[<"rcv ACK of FIN", "FINWAIT-2", [next]>
                          ,<"rcv FIN", "CLOSING", [next]>
                          ]>
        ,"ESTAB": <[currentMarker],    [<"close", "FINWAIT-1", [next]>
                          ,<"rcv FIN", "CLOSE WAIT", [next]>
                          ]>
        ,"CLOSE WAIT": <[currentMarker], [<"close", "LAST-ACK", [next]>]>
        ,"FINWAIT-2": <[currentMarker], [<"rcv FIN", "TIME WAIT", [next]>]>
        ,"CLOSING": <[currentMarker], [<"rcv ACK of FIN", "TIME WAIT", [next]>]>
        ,"LAST-ACK": <[currentMarker], [<"rcv ACK of FIN", "CLOSED", [next]>]>  
        ,"TIME WAIT": <[currentMarker], [<"timeout", "CLOSED", [next]>]>              
        ));
        
 public void paintFsm(Fsm fsm, Model m, Msg(str x) msg, list[Attr] attrs) {
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
              lrel[str, str, list[value(Model, Msg(str), str, str, str)]] out = fsm.graph[x].out;
               for (tuple[str lab, str to , list[value(Model, Msg(str), str, str, str)] attrs] edge <-out) {
                 list[value] attrs = [edgeLabel(edge.lab)]+[attr(m , msg, x, edge.lab, edge.to)|attr<-edge.attrs];
                 e(x, edge.to, attrs);
               }
            }
           }
         ]);  
       }
       , () {ul(salix::HTML::style([<"list-style-type","none">]), () {
           lrel[str, str, list[value(Model, Msg(str), str, str, str)]] steps = fsm.graph[fsm.current].out;
           for (tuple[str, str, list[value(Model, Msg(str), str, str, str)]] x<-steps) {
               li((){
              // button(salix::HTML::style([<"width", "200px">]), onClick(msg(x[1])), x[0]); 
              if (x[2] != [],value(Model, Msg(str),  str, str, str) f:= x[2][-1]) { 
                        if (void()  g:=f(m, msg, fsm.current, x[0], x[1])) g();
                    }           
               });
              }
           });
           }
      );    
   }
  			
num startWidth = 400;
num startHeight = 800;          

Model ginit() = <startWidth, startHeight, fsm, "", "">;




Model gupdate(Msg msg, Model m) {
  switch (msg) {
    case resizeX(_, real x): m.width = x;
    case resizeY(_, real y): m.height = y;
    case nextStep(str to): {
       if (m.fsm.current== "LISTEN" && to=="SYN RCVD") {
          m.name = m.buffer;
          m.buffer = "";
          }
       m.fsm.current=to;
       }
    case changeText(str idx, str txt): {
       m.buffer = txt;
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