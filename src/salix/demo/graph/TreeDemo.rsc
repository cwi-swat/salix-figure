module salix::demo::graph::TreeDemo

import salix::App;
import salix::HTML;
import salix::SVG;
import salix::Node;
import IO;
import util::Math;
import Set;
import List;
import String;
import salix::lib::Figure;
import salix::lib::Tree;
import salix::lib::LayoutFigure;
import salix::lib::Slider;


alias Model = tuple[num minWidth,  num maxWidth
                   ,num minHeight ,num maxHeight
                   ,num minKids, num maxKids
                   ,num maxDepth
                   ];

data Msg
   = minWidth(int id, real w)
   | minHeight(int id, real h)
   | maxWidth(int id, real w)
   | maxHeight(int id, real h)
   | minKids(int id, real minN)
   | maxKids(int id, real maxN)
   | maxDepth (int id, real n)
   ;
   
int idx = 0;

Figure treeKnod(tuple[num, num] siz, str txt) {
    int nc = arbInt(3);
    switch(nc) {
      case 0: return salix::lib::Figure::box(size=siz, fig = htmlText(txt, fontSize=10, size=<20, 20>)
           ,fillColor = "antiqueWhite", lineColor = "brown", fillOpacity=0.7);
      case 1: return salix::lib::Figure::circle(size=siz, fig = htmlText(txt, fontSize=10, size=<20, 20>)
           ,fillColor = "lightskyblue", lineColor = "brown", fillOpacity=0.7);
      case 2: return salix::lib::Figure::ngon(n=5, lineWidth =1, size=siz, fig = htmlText(txt, fontSize=10, size=<20, 20>)
           ,fillColor = "lightcoral", lineColor = "brown", fillOpacity=0.7);
      }
      return emptyFigure();
    }
   
public TreeNode genTree(int maxDepth, int minKids, int maxKids, int minX, int minY, int maxX, int maxY){
    idx = idx+1;
    /*
	Figure root = salix::lib::Figure::circle(fig = htmlText("<idx>", fontSize=10, size=<20, 20>)
	// , fillColor=colors[arbInt(size(colors))][0]
	, fillColor = "antiqueWhite", lineColor = "brown"
	, size=<minX + arbInt(maxX-minX), minY + arbInt(maxY -minY)>);
	//println("genTree1 <minX + arbInt(maxX-minX)> <minY + arbInt(maxY -minY)>");
	*/
	Figure root = treeKnod(<minX + arbInt(maxX-minX), minY + arbInt(maxY -minY)>, "<idx>");
	if(maxDepth  <= 0 || (maxDepth<2 && arbInt(100) <= 50)){return treeNode(root,[]); }
	int nr = arbInt(maxKids-minKids) + minKids;	
	//println("genTree2:<nr>");
	return treeNode(root,
		[ genTree(maxDepth-1,minKids,maxKids,minX,minY,maxX,maxY) | int i <- [0..nr]]);	
}
   
Figure testFigure(Model m) {
    Figure b = box(width=15, height= 15, fillColor="green");
    // TreeNode root  = treeNode(b, [treeNode(b, [], x=20, y=90), treeNode(b, [], x=90, y=90)], x=50, y=20);
    idx = 0;
    // TreeNode root  = treeNode(b, [treeNode(b, []), treeNode(b, [])]);  
    TreeNode root  = genTree(round(m.maxDepth), round(m.minKids),   round(m.maxKids)
                            ,round(m.minWidth), round(m.minHeight), round(m.maxWidth), round(m.maxHeight));      
    return tree(root, refinement=5);
    }
   
void myView(Model m) {
    Model defaults = init();
    list[list[list[SliderBar]]] sliderBars = [[
                             [
                              < minWidth, 0, "min width:", 5, 150, 5, defaults[0],"5", "150 (<round(m.minWidth)>)"> 
                              ,< maxWidth, 0, "max width:", 5, 150, 5, defaults[2],"5", "150 (<round(m.maxWidth)>)">                
                             ]
                             ,
                             [
                              
                             < minHeight, 0, "min height:", 5, 150, 5, defaults[1],"5", "50 (<round(m.minHeight)>)"> 
                             ,< maxHeight, 0, "max height:", 5, 150, 5, defaults[3],"5", "150 (<round(m.maxHeight)>)"> 
                             ]
                             ,
                             [
                              < minKids, 0, "min kids:", 1, 5, 1, defaults[4],"1", "5 (<round(m.minKids)>)"> 
                             ,< maxKids, 0, "max kids:", 1, 10, 1, defaults[5],"1", "10 (<round(m.maxKids)>)"> 
                             ]
                             ,
                             [
                              < maxDepth, 0, "max depth:", 1, 8, 1, defaults[6],"2", "9 (<round(m.maxDepth+1)>)"> 
                             ]                         
                             ]];     
    div(() {
        h2("Figure using SVG");
        slider(sliderBars);  
        fig(testFigure(m), width=1600, height = 800);
        //fig(200, 200, (Fig f) {
        //    testFigure(f, m);
        //});
    });
    }
    
Model init() = <20, 31, 20, 41, 2, 3, 2>;

Model update(Msg msg, Model m) {
    switch (msg) {
         case minWidth(_, real w): m.minWidth = w;
         case minHeight(_, real h): m.minHeight= h; 
         case maxWidth(_, real w): m.maxWidth = w;
         case maxHeight(_, real h): m.maxHeight= h;  
         case minKids(_, real minN): m.minKids = minN;
         case maxKids(_, real maxN): m.maxKids= maxN; 
         case maxDepth(_, real n): m.maxDepth = n; 
         }
         return m;
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