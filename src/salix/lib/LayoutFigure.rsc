module salix::lib::LayoutFigure
import util::Math;
import salix::SVG;
import salix::HTML;
import salix::App;
import salix::Core;
import salix::Node;
import salix::lib::Figure;
import salix::lib::Dagre;
import salix::lib::ParseHtml;
import salix::lib::Tree;
import util::Reflective;
import Prelude;


value vAlign(Alignment align) {
       if (align == bottomLeft || align == bottomMid || align == bottomRight) return salix::HTML::valign("bottom");
       if (align == centerLeft || align ==centerMid || align ==centerRight)  return salix::HTML::valign("middle");
       if (align == topLeft || align == topMid || align == topRight) return salix::HTML::valign("top");
       return "";
       }
       
value hAlign(Alignment align) {
       if (align == bottomLeft || align == centerLeft || align == topLeft) return salix::HTML::align("left");
       if (align == bottomMid || align == centerMid || align == topMid) return salix::HTML::align("center");
       if (align == bottomRight || align == centerRight || align == topRight) return salix::HTML::align("right");
       return "";   
       }
       
num diag(num a, num b) = sqrt(a*a+b*b);

str toP(num e) {
        str r = ".";
        str tl(num v) {
             int n = 4;
             for (int i<-[0..n]) {
                 v = 10*v;
                 r+="<toInt(v)%10>";
                 }
             for (int i<-[n,n-1..0]) {
                if (r[i]!="0") {
                      break;
                      }
                r=  substring(r, 0, size(r)-1);
                } 
             return r=="."?"":r;
             }
        num v = abs(e);
        return "<e<0?"-":""><toInt(v)><tl(v)>";
        }
        
 num getLineWidth(Figure f) {
      f = getTransformedFigure(f);
      num lw = (ngon():=f)? f.lineWidth/cos(PI()/f.n): 
           (isGrid(f)?f.borderWidth:f.lineWidth);
      return (lw>=0?lw:0);
      }
      
list[value] fromCommonFigureAttributesToSalix(Figure f) { 
      return fromCommonFigureAttributesToSalix(f, []);
      }
       
 list[value] fromCommonFigureAttributesToSalix(Figure f, list[tuple[str, str]] styles) {  
   styles += f.style; 
   list[value] r =[];    
   if (!isEmpty(f.fillColor)) r+= salix::SVG::fill(f.fillColor);
   if (!isEmpty(f.lineColor)) r+= salix::SVG::stroke(f.lineColor);
   if (f.lineWidth>=0) r+= salix::SVG::strokeWidth("<f.lineWidth>");
   if (f.lineOpacity>=0) r+= salix::SVG::strokeOpacity("<f.lineOpacity>");
   if (f.fillOpacity>=0) r+= salix::SVG::fillOpacity("<f.fillOpacity>");
   if (!isEmpty(f.visibility)) r+= salix::SVG::visibility(f.visibility);
   if (Event q:= f.event)  if (onclick(Msg msg):=q) r+=salix::SVG::onClick(msg);
   if (!isEmpty(styles)) r +=salix::HTML::style(styles);
   return r;
   }
   
list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::rotate(num angle, Figure g)) {
   list[value] r =[];
   num lwo = getLineWidth(f);
   num alpha = 180*angle/PI();
   if (f.r<0 && f.width>=0 && f.height>=0) {
          f.r = min(f.width, f.height)/2;
          if (isGrid(g)) f.r -= getLineWidth(g)/2;
          } 
        if (f.r>=0) {r+= salix::SVG::r("<toP(f.r)>");
                num xc = f.width/2+lwo/2;
                num yc = f.height/2+lwo/2;
                r+= salix::SVG::cx("<toP(xc)>");    
                r+= salix::SVG::cy("<toP(yc)>"); 
                r+= salix::SVG::transform("rotate(<toP(alpha)>, <toP(xc)>, <toP(yc)>)");         
                }
   r+=fromCommonFigureAttributesToSalix(f);
   return r; 
   }
   
list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::at(num x, num y, Figure g)) {
   list[value] r =[];
   r+= salix::SVG::transform("translate(<toP(x)>, <toP(y)>)");         
   return r; 
   }
   
list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::circle()) {
   list[value] r =[];
   num lwo = getLineWidth(f);
   if (f.r<0 && f.width>=0 && f.height>=0) {
             f.r = min(f.width, f.height)/2;
             if (isGrid(f.fig)) f.r -= getLineWidth(f.fig)/2;
             }
        if (f.r>=0) {r+= salix::SVG::r("<toP(f.r)>");
                r+= salix::SVG::cx("<toP(f.width/2+lwo/2)>");
                r+= salix::SVG::cy("<toP(f.height/2+lwo/2)>");           
                }
   r+=fromCommonFigureAttributesToSalix(f);
   return r; 
   }
   
list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::ellipse()) {
   list[value] r =[];
   num lwo = getLineWidth(f);
        if (f.rx<0 && f.width>=0) {
            f.rx = (f.width/*-borderWidth*/)/2;
            if (isGrid(f.fig)) f.rx -= getLineWidth(f.fig)/2;
            }
        if (f.ry<0 && f.height>=0) {
            f.ry = (f.height/*-borderWidth*/)/2;
            if (isGrid(f.fig)) f.ry -= getLineWidth(f.fig)/2;
            }
        if (f.rx>=0) {
                      r+= salix::SVG::rx("<toP(f.rx)>");
                      r+= salix::SVG::cx("<toP(f.rx+lwo/2)>");
                      }
        if (f.ry>=0) {                  
                      r+= salix::SVG::ry("<toP(f.ry)>");
                      r+= salix::SVG::cy("<toP(f.ry+lwo/2.0)>");         
                      }
   r+=fromCommonFigureAttributesToSalix(f);
   return r; 
   } 
   
 list[value] _fromFigureAttributesToSalix(Figure f, list[str] refs) {
   list[value] r =[];
   if (f.width>=0) r+= salix::SVG::width("<f.width>"); 
   if (f.height>=0) r+= salix::SVG::height("<f.height>");
   lrel[str, str] q =[];
   for (str ref <-refs) {
        if (startsWith(ref, "startMarker"))  q+=<"marker-start", "url(#<ref>)">;
        else
        if (startsWith(ref, "midMarker")) q+=<"marker-mid", "url(#<ref>)">;
        else
        if (startsWith(ref, "endMarker")) q+= <"marker-end", "url(#<ref>)">;            
        }
   r+=salix::HTML::style(q);
   // r+=salix::SVG::vectorEffect("non-scaling-stroke");
   r+=salix::SVG::d(f.d);
   r+=fromCommonFigureAttributesToSalix(f, q);
   return r; 
   }
   
list[value] fromFigureAttributesToSalix(Figure f:salix::lib::Figure::path(),
    list[str] refs) {
          return _fromFigureAttributesToSalix(f, refs);
          }
   
list[value] fromFigureAttributesToSalix(Figure f:salix::lib::Figure::path(list[str] curve),
    list[str] refs) {
      f.d = intercalate(" ", curve);
      return _fromFigureAttributesToSalix(f, refs);
    }
   
str points2str(Points points) = "<for(p<-points){> <toP(p[0])>,<toP(p[1])>  <}>";
 
list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::polygon(Points curve), list[str] refs) {
   list[value] r =[];
   if (f.width>=0) r+= salix::SVG::width("<f.width>"); 
   if (f.height>=0) r+= salix::SVG::height("<f.height>");  
   lrel[str, str] q =[];
   for (str ref <-refs) {
        if (startsWith(ref, "startMarker"))  q+=<"marker-start", "url(#<ref>)">;
        else
        if (startsWith(ref, "midMarker")) q+=<"marker-mid", "url(#<ref>)">;
        else
        if (startsWith(ref, "endMarker")) q+= <"marker-end", "url(#<ref>)">;            
        }
   r+=salix::HTML::style(q);
   // r+=salix::SVG::vectorEffect("non-scaling-stroke");
   r+=salix::SVG::points(points2str(curve));
   r+=fromCommonFigureAttributesToSalix(f, q);
   return r; 
   } 
   
list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::polyline(Points curve), list[str] refs) {
    list[value] r = [];
   if (f.width>=0) r+= salix::SVG::width("<f.width>"); 
   if (f.height>=0) r+= salix::SVG::height("<f.height>");
   lrel[str, str] q =[];
   for (str ref <-refs) {
        if (startsWith(ref, "startMarker"))  q+=<"marker-start", "url(#<ref>)">;
        else
        if (startsWith(ref, "midMarker")) q+=<"marker-mid", "url(#<ref>)">;
        else
        if (startsWith(ref, "endMarker")) q+= <"marker-end", "url(#<ref>)">;            
        }
   r+=salix::HTML::style(q);
   r+=salix::SVG::points(points2str(curve));
   r+=fromCommonFigureAttributesToSalix(f, q);
   return r; 
   }   

   
list[value] fromFigureAttributesToSalix(f:salix::lib::Figure::ngon(),
        list[str] curve) {
   list[value] r =[];
   num lwo = f.lineWidth/cos(PI()/f.n); 
   if (lwo<0) lwo = 0;
   if (f.width>=0) r+= salix::SVG::width("<toP(f.width)>"); 
   if (f.height>=0) r+= salix::SVG::height("<toP(f.height)>");
   // r+=salix::SVG::vectorEffect("non-scaling-stroke");
   r+=salix::SVG::d(intercalate(" ", curve));
   r+= salix::SVG::x("<toP(lwo/2)>"); r+= salix::SVG::y("<toP(lwo/2)>");
   r+=fromCommonFigureAttributesToSalix(f);
   return r; 
   }    
       
default list[value] fromFigureAttributesToSalix(Figure f) {
   list[value] r =[];
   num lwo = getLineWidth(f);
   if (f.width>=0) r+= salix::SVG::width("<toP(f.width)>"); 
   if (f.height>=0) r+= salix::SVG::height("<toP(f.height)>");
   if (f.rounded[0]>0) r+= salix::SVG::rx("<toP(f.rounded[0])>"); 
   if (f.rounded[1]>0) r+= salix::SVG::ry("<toP(f.rounded[1])>");     
   r+= salix::SVG::x("<toP(lwo/2)>"); r+= salix::SVG::y("<toP(lwo/2)>");
   r+=fromCommonFigureAttributesToSalix(f);
   return r;
   }
   
list[value] svgSize(Figure f) {
   list[value] r =[];
   num lw = getLineWidth(f);
   if (f.width>=0) r+= salix::SVG::width("<toP(f.width+lw)>"); 
   if (f.height>=0) r+= salix::SVG::height("<toP(f.height+lw)>");
   return r;
   }
   
list[value] fromTextPropertiesToSalix(Figure f, bool svg) {
    list[tuple[str, str]] styles = f.style; 
    if (!svg) styles+= <"overflow", f.overflow>; 
    int fontSize = (f.fontSize>=0)?f.fontSize:12;
    styles+=<"font-size", "<fontSize>pt">;
    if (!isEmpty(f.fontStyle)) styles+=<"font-style", f.fontStyle>;
    if (!isEmpty(f.fontFamily)) styles+=<"font-family", f.fontFamily>;
    if (!isEmpty(f.fontWeight)) styles+= <"font-weight", f.fontWeight>;
    if (!isEmpty(f.textDecoration)) styles+=<"text-decoration", f.textDecoration>;
    if (!isEmpty(f.fontColor)) styles+=<(svg?"fill":"color"), f.fontColor>;
    if (svg) {
        if (!isEmpty(f.fontLineColor)) styles+= <"stroke",f.fontLineColor>;
        if (f.fontLineWidth>=0) styles+=<"stroke-width", "<f.fontLineWidth>">;
        styles+=<"text-anchor", "middle">;
        }
    if (f.width>=0) styles+= <"width", "<toP(f.width)>px">; 
    if (f.height>=0) styles+= <"height", "<toP(f.height)>px">;
    list[value] r =[salix::HTML::style(styles)];
    if (svg) {
        if (f.width>=0) r+=salix::SVG::x("<toP(f.width/2)>");
        if (f.height>=0) r+=salix::SVG::y("<toP(f.height/2+6)>");
        }
    return r;
   }
   
list[value] fromTableModelToProperties(Figure f) {
    list[value] r =[];
    list[tuple[str, str]] styles=[];     
        styles += <"border-spacing", "<f.hgap>px <f.vgap>px">;
        styles+= <"border-collapse", "separate">;
        //if (f.width>=0) styles+= <"width", "<f.width>">; 
        // if (f.height>=0) styles+= <"height", "<f.height>">;
        r+=salix::HTML::style(styles);
        return r;    
   }
   
list[value] fromTdModelToProperties(Figure f, Figure g) {
    list[tuple[str, str]] styles = f.style+
    [<"padding", "<round(g.padding_top)>px <round(g.padding_right)>px <round(g.padding_bottom)>px <round(g.padding_left)>px">];
    if (f.borderWidth>=0) styles += <"border-width", "<f.borderWidth>px">;
    if (!isEmpty(f.borderColor)) styles+= <"border-color", "<f.borderColor>">;
    if (!isEmpty(f.borderStyle)) styles+= <"border-style", "<f.borderStyle>">;
    
    list[value] r =[salix::HTML::style(styles)];
    value q = hAlign(g.cellAlign);
    if (str _:=q) r += hAlign(f.align); else r+=q;
    q = vAlign(g.cellAlign);
    if (str _:=q) r += vAlign(f.align); else r+=q;
    return r;
    }
    
Figure getTransformedFigure(Figure f) {
   if (at(_, _, Figure g):=f) return g;
   if (rotate(_, Figure g):=f) return g;
   return f;
   }
   
void() innerFig(Figure outer, Figure inner) {
    return (){
       num lwo = getLineWidth(outer);
       num lwi = getLineWidth(inner);
       num widtho = outer.width; num heighto = outer.height;
       num widthi = inner.width; num heighti = inner.height;    
       list[value] svgArgs = [];
       if (widthi>=0) svgArgs+= salix::SVG::width("<toP(widthi+lwi)>");
       if (heighti>=0) svgArgs+= salix::SVG::height("<toP(heighti+lwi)>");
       list[value] foreignObjectArgs = [style(<"line-height", "0">)];
       if (widtho>=0) foreignObjectArgs+= salix::SVG::width("<toP(widtho-lwo)>");
       if (heighto>=0) foreignObjectArgs+= salix::SVG::height("<toP(heighto-lwo)>");
       foreignObjectArgs+= salix::SVG::x("<lwo>"); foreignObjectArgs+= salix::SVG::y("<lwo>");
       list[value] tdArgs = fromTdModelToProperties(outer, inner);
       list[value] tableArgs = foreignObjectArgs; 
       foreignObject(foreignObjectArgs+[(){table(tableArgs+[(){tr((){td(tdArgs+[(){svg(svgArgs+[(){eval(inner);}]);}]);});}]);}]);
       };
    } 
     
void() tableCells(Figure f, list[Figure] g) {
    list[void()] r =[];
    for (Figure h<-g) {
       Figure w= h; // Because of bug in rascal?
       list[value] svgArgs = [];
       num width = h.width; num height = h.height;
       num lw = getLineWidth(h);
       if (width>=0) svgArgs+= salix::SVG::width("<toP(width+lw)>");
       if (height>=0) svgArgs+= salix::SVG::height("<toP(height+lw)>");
       list[value] tdArgs = fromTdModelToProperties(f, h); 
       r+= [() {
           salix::HTML::td(tdArgs+[(){svg(svgArgs+[(){eval(w);}]);}]);
        }];
       }
    return () {for  (void() z<-r) z();};
    }
    
void() tableRows(Figure f) {
    list[void()] r =[];
    list[list[Figure]] figArray = [];
    if (grid():=f) {
       if (!isEmpty(f.figArray)) figArray = f.figArray;
       else figArray=[g.figs|Figure g<-f.figs]; // g is row
       }  
    else if (vcat():=f) figArray  = [[h]|h<-f.figs];    
    else if (hcat():=f) figArray  = [f.figs];
    for (list[Figure] g<-figArray) {
      list[Figure] w  = g;
        r+= [() {
        salix::HTML::tr(tableCells(f, w));  
        }];
       }
    return () {for (void() z<-r) z();};
    }
    
bool isGrid(Figure f) = hcat():=f || vcat():= f || grid():=f || htmlFigure(_):=f;
    
num getGrowFactor(Figure f, Figure g) {
    if ((salix::lib::Figure::ellipse():=f|| salix::lib::Figure::ngon():=f)&&(box():=g || isGrid(g))) return sqrt(2);
    if (salix::lib::Figure::circle():=f &&  (salix::lib::Figure::ngon():=g || salix::lib::Figure::ngon():=g)) return 1/sqrt(2);
    return 1;
    }
    
bool hasFigField(Figure f) = root():=f || box():=f || salix::lib::Figure::circle():=f || salix::lib::Figure::ellipse():=f 
       || salix::lib::Figure::ngon():=f;
 
 
Figure adjustParameters(Figure f) {      
   if (f.size != <0, 0>) {
       if (f.width<0) f.width = f.size[0];
       if (f.height<0) f.height = f.size[1];
       } 
    if (f.hgrow<0) f.hgrow = f.grow;
    if (f.vgrow<0) f.vgrow = f.grow;
    if (f.hshrink<0) f.hshrink = f.shrink;
    if (f.vshrink<0) f.vshrink = f.shrink;  
    return f;
    }
      
Figure pullDim(Figure f:path(list[str] _)) {
      if (emptyFigure()!:=f.startMarker) f.startMarker = pullDim(f.startMarker);
      if (emptyFigure()!:=f.midMarker) f.midMarker = pullDim(f.midMarker);
      if (emptyFigure()!:=f.endMarker) f.endMarker = pullDim(f.endMarker);
      return f;
      }
      
Figure pullDim(Figure f:path()) {
      if (emptyFigure()!:=f.startMarker) f.startMarker = pullDim(f.startMarker);
      if (emptyFigure()!:=f.midMarker) f.midMarker = pullDim(f.midMarker);
      if (emptyFigure()!:=f.endMarker) f.endMarker = pullDim(f.endMarker);
      return f;
      }
      
 Figure pullDim(Figure f:salix::lib::Figure::graph()) {
      f = adjustParameters(f);
      list[tuple[str, Figure]] r = [];
      for (tuple[str id, Figure fig] d<-f.nodes) {
            r+=[<d.id, pullDim(d.fig)>];
            }
      f.nodes = r;
      return f;
      }
      
Figure pullDim(Figure f:emptyFigure()) {
      f.width = 0;
      f.height = 0;
      return f;
      }
     

Figure pullDim(Figure f:overlay()) {
    f = adjustParameters(f);
    if (isEmpty(f.figs)) return f;
    f.figs = [pullDim(h)|Figure h<-f.figs];
    num maxWidth = max([h.width>=0?h.width+(getLineWidth(h)):-1|h<-f.figs]);
    num maxHeight = max([h.height>=0?h.height+(getLineWidth(h)):-1|h<-f.figs]);
    if (f.width<0 && maxWidth>=0) f.width = maxWidth;
    if (f.height<0 && maxHeight>=0) f.height = maxHeight;
    return f;
    }
    
Figure pullDim(Figure f:htmlText(_)) {
    return adjustParameters(f);
    }
    
Figure pullDim(Figure f:svgText(_)) {
    return adjustParameters(f);
    }
    
Figure pullDim(Figure f:at(num x, num y)) {
    Figure g = f.fig;
    return pullDim(at(x, y, g));
    }
    
Figure pullDim(Figure f:at(num x, num y, Figure g)) {
    f = adjustParameters(f);
    g = pullDim(g);
    Figure r = at(x, y, g);
    r.width = f.width; r.height = f.height;
    if (r.width<0&& g.width>=0) r.width = g.width + x;
    if (r.height<0&& g.height>=0) r.height = g.height + y;
    r.lineWidth = g.lineWidth;
    r.hgrow = f.hgrow; r.vgrow = f.vgrow;
    r.hshrink = f.hshrink; r.vshrink = f.vshrink;
    return r;
    }
    
Figure pullDim(Figure f:rotate(num angle)) {
    Figure g = f.fig;
    return pullDim(rotate(angle,  g));
    }
    
Figure pullDim(Figure f:rotate(num angle, Figure g)) {
    f = adjustParameters(f);
    g = pullDim(g);
    num lwo = getLineWidth(f);
    num lwi = getLineWidth(g);
    Figure r = rotate(angle, g);
    if (f.width<0 && g.width>=0) r.width = f.hgrow*g.width + lwi+ lwo;
    if (f.height<0 && g.height>=0) r.height = f.vgrow*g.height + lwi +lwo;
    num width = r.width; num height = r.height;
    if (width>=0 && height>=0) {
       r.width = diag(width, height);
       r.height = diag(width, height); 
       }
    r.lineWidth = f.lineWidth; r.lineColor = f.lineColor;
    return r;
    }

TreeNode newTreeNode(TreeNode root) {
    return visit(root) {
        case treeNode(Figure g, list[TreeNode] branches) => treeNode(pullDim(g), branches)
        }
    }
  
Figure pullDim(Figure f:tree(TreeNode root)) {
    return tree(newTreeNode(root)
    ,xSep=f.xSep, ySep=f.ySep,  pathColor=f.pathColor
	       ,orientation=f.orientation
	       ,manhattan=f.manhattan
           ,refinement=f.refinement,rasterHeight=f.rasterHeight);
    }

      
default Figure pullDim(Figure f) {
     f = adjustParameters(f); 
     if ((salix::lib::Figure::circle():=f || salix::lib::Figure::ngon():=f) && f.width<0 && f.height<0 && f.r>=0) {
            f.width = 2 * f.r; f.height = 2 * f.r;
        }
     if (salix::lib::Figure::ellipse():=f) {
           if (f.width<0 && f.rx>=0) {
              f.width = 2 * f.rx; 
              }
           if (f.height<0 && f.ry>=0) {
              f.height = 2 * f.ry; 
              }
           }
     if (hasFigField(f) && emptyFigure()!:=f.fig) {    
        f.fig = pullDim(f.fig);
        Figure g = f.fig;
        num lwo = getLineWidth(f);
        num lwi = getLineWidth(g);
        num paddingX= g.padding_left+g.padding_right;
        num paddingY= g.padding_top+g.padding_bottom;
        if (f.width<0 && g.width>=0) f.width = f.hgrow*getGrowFactor(f, g)*(g.width + lwi+ lwo)+paddingX;
        if (f.height<0 && g.height>=0) f.height = f.vgrow*getGrowFactor(f, g)*(g.height + lwi + lwo)+paddingY;
        if (f.width>0 && f.height>0 && (salix::lib::Figure::circle():=f)) {
            num width = f.width; num height = f.height;
            f.width = diag(width, height);
            f.height = diag(width, height);
        }
        }
     if (grid():=f || vcat():=f || hcat():=f) {
         list[list[Figure]] z =[];
         num height = 0;
         num lw = getLineWidth(f);
         int nc  = 0;
         list[list[Figure]] figArray = [];
         if (grid():=f) {
             if (!isEmpty(f.figArray)) figArray = f.figArray;
             else figArray=[g.figs|Figure g<-f.figs]; // g is row
             }
         else if (vcat():=f) figArray= [[h]|h<-f.figs]; 
         else if (hcat():=f) figArray  = [f.figs];
         list[num] maxColWidth = [-1|_<-[0..max([size(g)|g<-figArray])]];
         for (list[Figure] g<- figArray) {
            list[Figure] r = [];
            num h1 = 0;
            int i = 0;   
            for (Figure h<-g)  {
                  Figure v = pullDim(h);
                  num lwi = getLineWidth(v);
                  num colWidth = v.width>=0?(v.width+lwi+v.padding_left+v.padding_right):-1;
                  if (maxColWidth[i]<colWidth) maxColWidth[i] = colWidth;
                  if (h1>=0) {
                      if (v.height>=0) h1 = max([h1, v.height+lwi+v.padding_top+v.padding_bottom]);else h1=-1;
                      }
                  r += [v]; 
                  i += 1;     
                  }
            nc = max(nc, size(g));
            if (height>=0) {if (h1>=0) height+=h1; else height = -1; }    
            z+=[r];
            } 
          num width = sum(maxColWidth);  
          if (grid():=f) f.figArray= z;
          else
          if (vcat():=f) f.figs = [head(h)|list[Figure] h<-z];
          else
          if (hcat():=f) f.figs = head(z);
          if (f.width<0 && width>=0) f.width = width+nc*(f.hgap+2*lw)+f.hgap; 
          if (f.height<0 && height>=0) f.height = height+size(z)*(f.vgap+2*lw)+f.vgap;
          }
     return f;
     }
     
 list[list[Figure]] transpose(list[list[Figure]] m) {
     int n = max([size(g)|g<-m]);
     list[list[Figure]] r = [[]|_<-[0..n]];
     for (int i<-[0..size(m)]) {
          for (int j<-[0..size(m[i])]) {
             r[j]+=[m[i][j]];
          }
          for (int j<-[size(m[i])..n]) 
             r[j]+=[emptyFigure()];
       }
     return r;    
     }
     
list[list[Figure]] expand(list[list[Figure]] m) {
     int n = max([size(g)|g<-m]);
     list[list[Figure]] r = [[]|_<-[0..size(m)]];
     for (int i<-[0..size(m)]) {
          for (int j<-[0..size(m[i])]) {
             r[i]+=[m[i][j]];
          }
          for (int j<-[size(m[i])..n]) 
             r[i]+=[emptyFigure()];
       }
     return r;    
     }
     
 tuple[num, list[list[Figure]]] getHeightMissingCells(num height, num lw, num vgap, list[list[Figure]] figArray) {
     if (height<0) return <-1, []>;
     int nUndefinedRows = 0;
     num definedHeight = 0;
     num sumLw = 0;
     list[list[Figure]] z =[];
     for (list[Figure] g<- expand(figArray)) {
         list[Figure] r =[];
         num maxHeight = -1;num maxLw = -1;
         for (Figure h<-g) {
              maxHeight= max(h.height, maxHeight);
              maxLw = max(getLineWidth(h), maxLw);
         }
         if (maxHeight>=0) definedHeight= definedHeight+maxHeight;
         if (maxLw>=0) sumLw+=maxLw;
         for (Figure h<-g) {
              Figure x = h; 
              if (x.height<0) x.height = maxHeight;
              r+=x;
              }
         z+=[r];
         if (maxHeight<0) nUndefinedRows+=1;
          }
     num computedHeight = -1;
     if (nUndefinedRows>0) computedHeight = (height-definedHeight-size(figArray)*(vgap+2*lw)-vgap-sumLw)/nUndefinedRows;
     // println("Height: <height> <computedHeight> <definedHeight> <nUndefinedRows> size(figArray)");
     return <computedHeight, z>;  
     }
     
 tuple[num, list[list[Figure]]] getWidthMissingCells(num width, num lw, num hgap, list[list[Figure]] figArray ) {
     if (width<0) return <-1, []>;
     figArray = transpose(figArray);
     int nUndefinedCols = 0;
     num definedWidth = 0;
     list[list[Figure]] z =[];
     num sumLw = 0;
     for (list[Figure] g<- figArray) {
         list[Figure] r =[];
         num maxWidth = -1; num maxLw = -1;
         for (Figure h<-g) {
              maxWidth= max(h.width, maxWidth);
              maxLw = max(getLineWidth(h), maxLw);
         }
         if (maxWidth>=0) definedWidth= definedWidth+maxWidth;
         if (maxLw>=0) sumLw+=maxLw;
         for (Figure h<-g) {
              Figure x = h;
              if (x.width<0) x.width = maxWidth;
              r+=x;
              }
         z+=[r];
         if (maxWidth<0) nUndefinedCols+=1;    
         }
     num computedWidth = -1;
     if (nUndefinedCols>0) computedWidth = (width-definedWidth-size(figArray)*(hgap+2*lw)-hgap-sumLw)/nUndefinedCols;
     // println("Width: <width> <computedWidth> <definedWidth> <nUndefinedCols> size(figArray)");
     return <computedWidth, transpose(z)>;  
     }
     
 Figure pushDim(Figure f:overlay()) {
    f = adjustParameters(f);
    if (isEmpty(f.figs)) return f;
    list[Figure] z =[];
    if (f.width>=0)
    for (Figure h<-f.figs) {
       num lw = getLineWidth(h);
       if (f.width>=0 && h.width<0) h.width = f.width-lw;
       if (f.height>=0 && h.height<0) h.height = f.height-lw;
       z+=[h];
       }
    f.figs = [pushDim(h)|h<-z];
    return f;
    }
    
 Figure pushDim(Figure f:salix::lib::Figure::graph()) {
      f = adjustParameters(f);
      list[tuple[str, Figure]] r = [];
      for (tuple[str id, Figure fig] d<-f.nodes) {
            r+=[<d.id, pushDim(d.fig)>];
            }
      f.nodes = r;
      return f;
      }
      
Figure pushDim(Figure f:rotate(num angle)) {
      Figure g = f.fig;
      return pushDim(rotate(angle, g));
      }
      
 Figure pushDim(Figure f:rotate(num angle, Figure g)) {
    num lwo = getLineWidth(f);
    num lwi = getLineWidth(g);
    num width = f.width; num height = f.height;
    if (g.width<0 && width>=0) g.width = g.hshrink*min(width, height)/sqrt(2)-lwi-lwo;
        // g.width = g.hshrink*width*width/diag(width, height)-lwi-lwo;
    if (g.height<0 && height>=0) g.height = g.vshrink*min(width, height)/sqrt(2)-lwi-lwo; 
        // g.height = g.hshrink*height*height/diag(width, height)-lwi-lwo;
    g = pushDim(g);
    Figure r = rotate(angle, g);  
    r.lineWidth = f.lineWidth;
    r.lineColor= f.lineColor;
    r.width = f.width;
    r.height = f.height;
    return r;
    }
    
 Figure pushDim(Figure f:at(num x, num y)) {
    Figure g = f.fig;
    return pushDim(at(x, y, g));
    }
    
 Figure pushDim(Figure f:at(num x, num y, Figure g)) {
    num shiftX =0; num shiftY = 0;
    if (g.width<0 && f.width>=0) {
        g.width = g.hshrink*(f.width-x);
        shiftX =  ((f.width - x)-g.width)/2;
        }
    if (g.height<0 && f.height>=0) {
         g.height = g.vshrink*(f.height-y); 
         shiftY =  ((f.height - y)-g.height)/2;
         }
    if (g.lineWidth<0) g.lineWidth = f.lineWidth;
    g = pushDim(g);
    Figure r = at(x+shiftX, y+shiftY, g);  
    r.width = f.width;
    r.height = f.height;
    r.lineWidth = f.lineWidth;
    r.hgrow = f.hgrow; r.vgrow = f.vgrow;
    r.hshrink = f.hshrink; r.vshrink = f.vshrink;  
    return r;
    }
     
 default Figure pushDim(Figure f) {
     if (hasFigField(f) && emptyFigure()!:=f.fig) {
           Figure g = adjustParameters(f.fig); 
           num lwo = getLineWidth(f);
           num lwi = getLineWidth(g);
           num paddingX= g.padding_left+g.padding_right;
           num paddingY= g.padding_top+g.padding_bottom;
           if (g.width<0 && f.width>=0) g.width = g.hshrink*(f.width-lwo) - lwi-paddingX;
           if (g.height<0 && f.height>=0) g.height = g.vshrink*(f.height-lwo) -lwi-paddingY;
           f.fig = pushDim(g);
     }
     if (grid():=f || vcat():=f || hcat():=f) {
         num lw = getLineWidth(f);
         list[list[Figure]] figArray = [];
         if (grid():=f) {
             if (!isEmpty(f.figArray)) figArray = f.figArray;
             else figArray=[g.figs|Figure g<-f.figs]; // g is row
             }
         else if (vcat():=f) figArray= [[h]|h<-f.figs]; 
         else if (hcat():=f) figArray  = [f.figs];
         tuple[num height, list[list[Figure]] figs] cellsH = getHeightMissingCells(f.height, lw, f.vgap, figArray);
         tuple[num width, list[list[Figure]] figs] cellsW = getWidthMissingCells(f.width, lw, f.hgap, cellsH.figs);
          list[list[Figure]] z =[];
          for (list[Figure] g<-cellsW.figs) {
              list[Figure] r = [];
              for (Figure h<-g) {  
                  Figure q = adjustParameters(h);
                  if (cellsW.width>=0 && q.width<0) q.width =   cellsW.width*q.hshrink-lw-q.padding_left-q.padding_right; 
                  if (cellsH.height>=0 && q.height<0) q.height =   cellsH.height*q.vshrink-lw-q.padding_top-q.padding_bottom; 
                  r += pushDim(q);  
                  }
              z+=[r];
              }
          if (grid():=f) f.figArray= z;
          else
          if (vcat():=f) f.figs = [head(h)|list[Figure] h<-z];
          else
          if (hcat():=f) f.figs = head(z);
          }
     return f;
     }
     
 Figure solveStepDim(Figure f) {
     f = pullDim(f);
     return pushDim(f);
     }
     
 Figure solveDim(Figure f) {
     return solve(f) solveStepDim(f);
     }
     
 public void fig(Figure f, num width = -1, num height = -1) {
     Figure root = root(width = width, height = height);
     if (root.size != <0, 0>) {
       if (root.width<0) f.width = f.size[0];
       if (root.height<0) f.height = f.size[1];
       }
     root.fig = f;
     root = solveDim(root);
     // println("Root <root>");
     eval(root);
     }
    
void eval(emptyFigure()) {;}

void eval(Figure f:root()) {svg(svgSize(f)+[() {eval(f.fig);}]);}

void eval(Figure f:overlay()) {svg(svgSize(f)+[(){for (g<-f.figs) {svg(svgSize(g)+[() {eval(g);}]);}}]);}

void eval(Figure f:box()) {\rect(fromFigureAttributesToSalix(f));if (emptyFigure()!:=f.fig) innerFig(f, f.fig)();}

void eval(Figure f:salix::lib::Figure::circle()) {salix::SVG::circle(fromFigureAttributesToSalix(f));if (emptyFigure()!:=f.fig) innerFig(f, f.fig)();}

void eval(Figure f:salix::lib::Figure::ellipse()) {salix::SVG::ellipse(fromFigureAttributesToSalix(f));if (emptyFigure()!:=f.fig) innerFig(f, f.fig)();}

void eval(Figure f:htmlText(str s)) {
     num lw = getLineWidth(f);
     num width = f.width; num height = f.height; 
     list[value] foreignObjectArgs = [style(<"line-height", "1.5">)];
     if (width>=0) foreignObjectArgs+= salix::SVG::width("<toP(width-lw)>");
     if (height>=0) foreignObjectArgs+= salix::SVG::height("<toP(height-lw)>");
     foreignObjectArgs+= salix::SVG::x("<toP(lw)>"); foreignObjectArgs+= salix::SVG::y("<toP(lw)>");
     list[tuple[str, str]] styles = [<"padding", 
                                      "<f.padding_top> <f.padding_right> <f.padding_bottom> <f.padding_left>">];
     if (f.borderWidth>=0) styles += <"border-width", "<f.borderWidth>px">;
     if (!isEmpty(f.borderColor)) styles+= <"border-color", "<f.borderColor>">;
     if (!isEmpty(f.borderStyle)) styles+= <"border-style", "<f.borderStyle>">;
     if (htmlText(_):=f) {
          if(f.width>=0)  styles+= <"max-width", "<toP(f.width)>px">;
          if(f.height>=0)  styles+= <"max-height", "<toP(f.height)>px">;
          if(f.width>=0)  styles+= <"min-width", "<toP(f.width)>px">;
          if(f.height>=0)  styles+= <"min-height", "<toP(f.height)>px">;
          }
     list[value] tdArgs =[salix::HTML::style(styles)];
     tdArgs += hAlign(f.align);
     tdArgs += vAlign(f.align); 
     // tdArgs+=[salix::HTML::style(styles)];
     list[value] tableArgs = /*foreignObjectArgs+*/fromTextPropertiesToSalix(f, false); 
     foreignObject(foreignObjectArgs+[(){table(tableArgs+[(){tr((){td(tdArgs+[(){htm((){_text(s);});}]);});}]);}]);
    }
    
 void eval(Figure f:svgText(str s)) {
     salix::SVG::text_(fromTextPropertiesToSalix(f, true)+[(){salix::Core::_text(s);}]);
    }
    
void eval(Figure f:vcat()) {
                   list[value] foreignObjectArgs = [style(<"line-height", "0">)];
                   if (f.width>=0) foreignObjectArgs+= salix::SVG::width("<toP(f.width)>");
                   if (f.height>=0) foreignObjectArgs+= salix::SVG::height("<toP(f.height)>");
                   foreignObject(foreignObjectArgs+[(){salix::HTML::table(fromTableModelToProperties(f)+[tableRows(f)]);}]);
                   }
                   
void eval(Figure f:hcat()) {
                   list[value] foreignObjectArgs = [style(<"line-height", "0">)];
                   if (f.width>=0) foreignObjectArgs+= salix::SVG::width("<toP(f.width)>");
                   if (f.height>=0) foreignObjectArgs+= salix::SVG::height("<toP(f.height)>");
                   foreignObject(foreignObjectArgs+[(){salix::HTML::table(fromTableModelToProperties(f)+[tableRows(f)]);}]);
                   }
 

void eval(Figure f:grid()) {
                   list[value] foreignObjectArgs = [style(<"line-height", "0">)];
                   if (f.width>=0) foreignObjectArgs+= salix::SVG::width("<toP(f.width)>");
                   if (f.height>=0) foreignObjectArgs+= salix::SVG::height("<toP(f.height)>");
                   foreignObject(foreignObjectArgs+[(){salix::HTML::table(fromTableModelToProperties(f)+[tableRows(f)]);}]);
                   }
                   
str getViewBox(Figure f) {
                   return "<f.viewBox[0]>  <f.viewBox[1]>  <f.viewBox[2]>0?f.viewBox[2]:f.width> <f.viewBox[3]>0?f.viewBox[3]:f.height>";
                   }
     
 list[str] addMarkers(Figure f) {             
                   list[tuple[Figure fig, str lab]] r =[];
                   list[str] refs = [];
                   int startCode =  getFingerprintNode(f.startMarker);
                   int midCode =  getFingerprintNode(f.midMarker);
                   int endCode =  getFingerprintNode(f.endMarker);
                   if (emptyFigure()!:=f.startMarker) r += <f.startMarker,startCode>0?"startMarker<startCode>":"startMarkerX<(-startCode)>">;
                   if (emptyFigure()!:=f.midMarker)   r += <f.midMarker, midCode>0?"midMarker<midCode>":"midMarkerX<(-midCode)>">;
                   if (emptyFigure()!:=f.endMarker)   r += <f.endMarker, endCode>0?"endMarker<endCode>":"endMarkerX<(-endCode)>">;
                   // println("fingerPrint: <getFingerprintNode(f.midMarker)>");
                   if (!isEmpty(r))
                            salix::SVG::defs(() {
                            for (tuple[Figure fig, str lab] d<-r) {
                            salix::SVG::marker(salix::SVG::id(d.lab), markerWidth("<d[0].width>"), markerHeight("<d[0].height>"),
                              refX("<d[0].width/2.0>"), refY("<d[0].height/2.0>"), orient("auto"), preserveAspectRatio("none"),
                              salix::SVG::viewBox(getViewBox(d.fig)), 
                              salix::SVG::markerUnits("userSpaceOnUse"),
                              () {                                                                     
                                 eval(d.fig);
                                 });
                                 refs += d.lab;
                                 }                    
                         });
                      return refs;
                    } 
                                      
void eval(Figure f:path(list[str] _)) {
                   list[str] refs = addMarkers(f);           
                   salix::SVG::svg(salix::SVG::viewBox(getViewBox(f)), preserveAspectRatio("none"), (){
                              salix::SVG::g(salix::SVG::transform(f.transform),
                                 (){                        
                                    salix::SVG::path(fromFigureAttributesToSalix(f, refs));
                                   }
                              );
                       }); 
                   }
                   
void eval(Figure f:path()) {
                   list[str] refs = addMarkers(f);           
                   salix::SVG::svg(salix::SVG::viewBox(getViewBox(f)), preserveAspectRatio("none"), (){
                              salix::SVG::g(salix::SVG::transform(f.transform),
                                 (){                        
                                    salix::SVG::path(fromFigureAttributesToSalix(f, refs));
                                   }
                              );
                       }); 
                   }
                   
 void eval(Figure f:polygon(Points _)) {   
                   list[str] refs = addMarkers(f);      
                   salix::SVG::svg(salix::SVG::viewBox(getViewBox(f)), preserveAspectRatio("none"), (){                                                
                             salix::SVG::polygon(fromFigureAttributesToSalix(f, refs));
                       }); 
                   }
                   
void eval(Figure f:polyline(Points _)) {
                   list[str] refs = addMarkers(f);         
                   salix::SVG::svg(salix::SVG::viewBox(getViewBox(f)), preserveAspectRatio("none"), (){                                                
                             salix::SVG::polyline(fromFigureAttributesToSalix(f, refs));
                       }); 
                   }
                   
 void eval (Figure f:ngon()) {
                   num shift = 1.0;
                   num lw = f.lineWidth/cos(PI()/f.n); 
                   if (lw<0) lw = 0;
                   if (f.r<0) f.r = f.width/2;
                   salix::SVG::g(salix::SVG::transform(t_.t(lw/2,lw/2)+"scale(<toP(f.r)>,<toP(f.r)>) "+t_.t(shift, shift)+t_.r(f.angle, 0, 0)),
                          (){                        
                            list[str] pth = [p_.M(-1, 0)];
                            pth += [p_.L(-cos(phi), sin(phi))|num phi<-[2*PI()/f.n, 4*PI()/f.n..2*PI()]];
                            pth += [p_.Z()];                     
                             salix::SVG::path(fromFigureAttributesToSalix(f, pth));
                            }); 
                   if (emptyFigure()!:=f.fig) innerFig(f, f.fig)();    
                   }
                   
 str shapeName(Figure f) {
      switch(f) {
         case circle():  return "circle";
         case ngon():  return "diamond";
         case ellipse(): return "ellipse";
         default: return "rect";
         }
      return "rect";
      }
                   
 void eval(Figure f:salix::lib::Figure::graph()) {
                  int graphCode =  getFingerprintNode(f);
                  str graphId = ((graphCode>0)?"graph<graphCode>":"graphX<(-graphCode)>");
                  dagre(graphId, width("<f.width>"), height("<f.height>"), (N n, E e) {
                       for (tuple[str id, Figure fig] d<-f.nodes) {
                           num lw = d.fig.lineWidth>=0?d.fig.lineWidth:0;
                           n(d.id,salix::lib::Dagre::shape("<shapeName(d.fig)>"), width("<d.fig.width+lw>"), height("<d.fig.height+lw>"),
                              class("svg"),
                              ngon():=d.fig?nCorner(d.fig.n):0,
                               (){svg(svgSize(d.fig)+[() {eval(d.fig);}]);});
                           }
                       for (Edge edg <- f.edges)
                           if (edge(str from, str to):=edg) {
                               list[value] r =[lineInterpolate(edg.lineInterpolate)];
                               list [tuple[str, str]] styl = [<"fill","none">];  
                               if (!isEmpty(edg.label)) r += edgeLabel(edg.label); 
                               if (!isEmpty(edg.labelStyle)) r += labelStyle(edg.labelStyle); 
                               if (!isEmpty(edg.arrowheadStyle)) r += arrowhead(edg.arrowheadStyle);
                               if (!isEmpty(edg.lineColor)) styl += <"stroke", edg.lineColor>;
                               if (edg.lineWidth>=0) styl += <"stroke-width", "<edg.lineWidth>">;
                               if (!isEmpty(styl)) r+=style(styl);
                               if (edg.labelOffset>=0) r += labelOffset(edg.labelOffset);
                               if (!isEmpty(edg.labelPos)) r += labelPos(edg.labelPos);
                               e(from, to, r);
                           }
                        });
                  }
                  
void eval(Figure f:salix::lib::Figure::rotate(num angle, Figure g)) {
        salix::SVG::g(fromFigureAttributesToSalix(f)+[(){
            salix::SVG::circle(fromFigureAttributesToSalix(f));
           if (emptyFigure()!:=g) innerFig(f, g)();
           }]);
       }

void eval(Figure f:at(num x, num y, Figure g)) {
           salix::SVG::g(fromFigureAttributesToSalix(f)+[(){
                   if (emptyFigure()!:=g) eval(g);
           }]);
         }
         
void eval(Figure f:salix::lib::Figure::rotate(num angle)) {
        Figure g = f.fig;
        salix::SVG::g(fromFigureAttributesToSalix(f)+[(){
            salix::SVG::circle(fromFigureAttributesToSalix(f));
           if (emptyFigure()!:=g) innerFig(f, g)();
           }]);
       }

void eval(Figure f:at(num x, num y)) {
           Figure g = f.fig;
           salix::SVG::g(fromFigureAttributesToSalix(f)+[(){
                   if (emptyFigure()!:=g) eval(g);
           }]);
         }
         
tuple[num, num] centre(TreeNode t) = <t.x+getWidth(t)/2, t.y+getHeight(t)/2>;
         
void placeNodes(TreeNode root) {
         if (treeNode(Figure f, list[TreeNode] branches):=root) {
             tuple[num, num] from = centre(root);
             for (TreeNode b<-branches) {
                tuple[num, num] to = centre(b);           
                eval(salix::lib::Figure::path([p_.M(from[0], from[1]), p_.L(to[0], to[1])], lineColor="red"));
                placeNodes(b);
             } 
             eval(at(round(root.x), round(root.y), f));           
         }
     }
         
void eval(Figure f:tree(TreeNode root)) {
         root=treeLayout(f);
         svg(svgSize(f)+[() {
             placeNodes(root);         
             }
           ]);
         }
         
void eval(Figure f:htmlFigure(void() g) ){
       num lw = getLineWidth(f);
       num width = f.width; num height = f.height;   
       list[value] foreignObjectArgs = [];
       if (width>=0) foreignObjectArgs+= salix::SVG::width("<toP(width-lw)>");
       if (height>=0) foreignObjectArgs+= salix::SVG::height("<toP(height-lw)>"); 
       foreignObjectArgs+= salix::SVG::x("<lw>"); foreignObjectArgs+= salix::SVG::y("<lw>");
       foreignObject(foreignObjectArgs+[(){div(
           salix::HTML::style([<"width", "<toInt(width-lw)>px">, <"height", "<toInt(height-lw)>px">]),
            (){g();});}]);
    } 
    
 Node _htm(list[Node] kids, list[Attr] attrs) {
       if (txt(str s):=kids[0]) return html2Node(s);
       return html2Node("not a string");
       }
       
 void htm(value vals...) = build(vals, _htm);    
