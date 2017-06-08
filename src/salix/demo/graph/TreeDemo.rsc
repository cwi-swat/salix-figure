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
import salix::lib::LayoutFigure;


alias Model = tuple[str innerFill, num middleGrow];

data Msg
   = doIt()
   ;
   
Figure testFigure(Model m) {
    Figure b = box(width=15, height= 15, fillColor="green");
    TreeNode root  = treeNode(b, [treeNode(b, [], x=20, y=90), treeNode(b, [], x=90, y=90)], x=50, y=20);  
    return tree(root);
    }
   
void myView(Model m) {
    div(() {
        h2("Figure using SVG");
        fig(testFigure(m));
        //fig(200, 200, (Fig f) {
        //    testFigure(f, m);
        //});
    });
    }
    
Model init() = <"snow", 1.2>;

Model update(Msg msg, Model m) {
    switch (msg) {
       case doIt():
          if (m.innerFill=="snow") {
              m.innerFill= "lightgrey";
              m.middleGrow = 1.5;
              }
          else {
              m.innerFill = "snow";
              m.middleGrow = 1.2;
              }
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