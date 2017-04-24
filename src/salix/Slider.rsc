module salix::Slider
import salix::HTML;
import Prelude;

data Msg;

Msg(real) partial(Msg(int, real) f, int p) {return Msg(real y){return f(p, y);};}

alias SliderBar = tuple[Msg(int, real) msg, int id, str label, num low, num high, num step, num val, str left, str right];

void _slider(Msg(real) msg, num low, num high, num step, num val) {
    salix::HTML::input(
            salix::HTML::\type("range")
           ,salix::HTML::min("<low>")
           ,salix::HTML::max("<high>")
           ,salix::HTML::step("<step>")
           ,salix::HTML::\value("<val>")
           ,salix::HTML::onChange(msg)
         );
    }
    
   
void tableCell(Msg(int, real) msg, int id, num low, num high, num step, num val, str label, str left, str right) {
     td(label);
     td(left);
     td(() {_slider(partial(msg ,id), low, high, step, val);});
     td(right);
     }
   
void tableRow(list[list[SliderBar]] sliders) {
      list[tuple[str, str]] styles=[];     
       styles += <"border-spacing", "5px 5px">;
       styles+= <"border-collapse", "separate">;
       styles+= <"border-width", "2">;
       // styles+= <"border-color", "grey">; 
       styles+= <"border-style", "groove
       ">; 
       tr((){ 
         for (slids<-sliders) {
            td(salix::HTML::style(styles), (){
              table(salix::HTML::style(styles), (){
              for (slid <- slids)
                tr((){
                  tableCell(slid.msg, slid.id, slid.low, slid.high, slid.step, slid.val, slid.label, slid.left, slid.right);
                 });
            });
            });}
           });
   }
   
void slider(list[list[list[SliderBar]]] sliders) { 
       list[tuple[str, str]] styles=[];     
       styles += <"border-spacing", "5px 5px">;
       styles+= <"border-collapse", "separate">;
       // styles+= <"width", "1000px">;
       table(salix::HTML::style(styles), (){
            for (list[list[SliderBar]] slids<-sliders) {
                tableRow(slids);                      
                }
           });
    }