module salix::lib::RenderFigure

import salix::Node;
import salix::Core;
import salix::lib::Figure;
import salix::lib::LayoutFigure;
import IO;
import Node;

data FProp
  = cx(num x)
  | cy(num y)
  | rx(num x)
  | ry(num y)
  | r(num r)
  | n(int n)
  | d(str d)
  | angle(num phi)
  | points(Points points)
  | yReverse(bool b)
  | xReverse(bool b)
  | connected(bool b)
  | closed(bool b)
  | curved(bool b)
  | padding(tuple[int left, int top, int right, int bottom] padding)
  | width(num w)
  | height(num h)
  | align(Alignment align)
  | cellAlign(Alignment align)
  | shrink(num shrink)
  | hshrink(num hshrink)
  | vshrink(num vshrink)
  | grow(num grow)
  | hgrow(num hgrow)
  | vgrow(num vgrow)
  | resizable(bool b)
  | gap(tuple[num hgap, num vgap] hvgap) // todo: fix superfluous tuples here.
  | hgap(num hgap)
  | vgap(num vgap)
  | lineWidth(num w)
  | lineColor(str color)
  | lineDashing(list[int] ds)
  | lineOpacity(num opacity)
  | borderWidth(num w)
  | borderStyle(str style)
  | borderColor(str color)
  | fillColor(str color)
  | fillOpacity(num opacity)
  | fillRule(str rule)
  | clipPath(list[str] path)
  | rounded(tuple[num r1, num r2] rounded)
  | size(tuple[num r1, num r2] size)
  | viewBox(tuple[num x, num y, num width, num height] viewBox)
  | style(lrel[str key, str val] ccs)
  | fontColor(str color)
  | fontStyle(str style)
  | fontSize(num w)
  | marker(str marker)
  | overflow(str overflow)
  ; 
  
alias FigF = void(list[value]); 
alias FigF1 = void(num, list[value]);
alias FigF2 = void(num, num, list[value]);
alias Fig = tuple[

  // Primitives
  FigF box,
  FigF ellipse,
  FigF circle,
  FigF ngon,
  FigF polygon,
  
  // Text
  FigF htmlText,
  FigF svgText,
  
  // Transform
  FigF1 rotate,
  FigF2 at, 
  
  //FigF shape, // needs nesting with start/mid/end marker
  FigF path, // needs nesting with start/mid/end marker
  
  FigF hcat,
  FigF vcat,
  FigF overlay,
  FigF row,
  FigF grid,
  
  // embedding salix
  FigF html
];

data Figure
 = dummy(list[Figure] figs = [])
 // TODO: extend eval to interpret this figure
 ;

Figure setProps(Figure f, list[value] vals) {
  map[str,value] update(map[str,value] kws, FProp fp)
    = kws + (getName(fp): getChildren(fp)[0]); // assumes all props have 1 arg
  return ( f | setKeywordParameters(it, update(getKeywordParameters(it), fp)) | FProp fp <- vals );
}

void fig(void(Fig) block) {
  fig(-1, -1, block);
  }


Figure getFigure(void(Fig) block) {
  list[Figure] stack = [dummy()];
  
  Figure pop() {
    Figure p = stack[-1];
    stack = stack[0..-1];
    return p;
  }
  
  void push(Figure f) {
    stack += [f];
  }
  
  void add(Figure f) {
    Figure t = pop();
    if (t has startMarker && f.marker=="start") {
        t.startMarker = f;
        }
    else
    if (t has midMarker && f.marker=="mid") {
        t.midMarker = f;
        }
    else
    if (t has endMarker && f.marker=="end") {
        t.endMarker = f;
        }
    // todo: should all be figs
    else
    if (t has figs) {
      t.figs += [f];
    }
    else if (t has fig) {
      t.fig = f;
    } // else ignore...
    push(t);
  }
  
  void makeFig(Figure base, list[value] vals) {
    push(base);
    if (vals != [], void() block := vals[-1]) {
      block();
    }
    add(setProps(pop(), vals));  
  }
  
  void _box(value vals...) = makeFig(Figure::box(), vals);
  void _ellipse(value vals...) = makeFig(Figure::ellipse(), vals);
  void _circle(value vals...) = makeFig(Figure::circle(), vals);
  void _ngon(value vals...) = makeFig(Figure::ngon(), vals);
  void _polygon(value vals...) {
         if (vals != [], Points points := vals[-1]) {
           makeFig(Figure::polygon(points), vals);
           }
         }
  void _htmlText(value vals...) {
         if (vals != [], str txt := vals[-1]) {
             makeFig(Figure::htmlText(txt), vals[0..-1]);
             }
          }
  void _svgText(value vals...) {
          if (vals != [], str txt := vals[-1]) {
            makeFig(Figure::svgText(txt), vals);
            }
          }
  void _rotate(num angle, value vals...) = makeFig(Figure::rotate(angle), vals);
  void _at(num x, num y, value vals...) = makeFig(Figure::at(x, y), vals);
  
  // vs should be keyword arg
  //void shape(list[Vertex] vs, value vals...) = makeFig(Figure::shape(vs), vals);
  
  // these things should also have only keyword args for consistency
  // void path(...)
  // void textpath...
  
  // and start/end/mid marker should be just figs
  void _path(value vals...) = makeFig(Figure::path(), vals);
  void _hcat(value vals...) = makeFig(Figure::hcat(), vals);
  void _vcat(value vals...) = makeFig(Figure::vcat(), vals);
  void _overlay(value vals...) = makeFig(Figure::overlay(), vals);
  void _row(value vals...) = makeFig(Figure::row(), vals);
  void _grid(value vals...) = makeFig(Figure::grid(), vals);
  
  // NB: block should draw 1 node
  void _html(value vals...) {
      if (vals != [], void() block := vals[-1]) {
         makeFig(Figure::htmlFigure(block), vals[0..-1]);
         }      
      }
  
  block(<_box, _ellipse, _circle, _ngon, _polygon, _htmlText, _svgText, _rotate, _at, _path, _hcat, _vcat, _overlay, _row, _grid, _html>);
  
  iprintln(stack[-1].figs[0]);
  return stack[-1].figs[0];
  //addNode(render(eval(stack[-1].figs[0])));
}

void fig(num w, num h, void(Fig) block) {
     Figure r = getFigure(block);
     if (w>0  && h>0)
        salix::lib::LayoutFigure::fig(r, width=w, height=h);
     else
        salix::lib::LayoutFigure::fig(r);     
       }
