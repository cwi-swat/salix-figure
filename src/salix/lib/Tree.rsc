module salix::lib::Tree
import salix::lib::Figure;
import util::Math;
import Prelude;

alias TreeBorder = tuple[int yPosition, list[int] offset];

list[TreeNode] absolutize(num x, num y, list[TreeNode] bs) {
     return [treeNode(fig, branches, x=f.x+x, y=f.y)|TreeNode f<-bs
         , treeNode(Figure fig, list[TreeNode] branches):=f];
     } 

TreeNode adjust(TreeNode root, num refinement) {
    if (treeNode(Figure f, list[TreeNode] branches):=root) {
           f.width /= refinement; f.height /= refinement;
           num x = root.x, y = root.y;
           list[TreeNode] bs = absolutize(x, y, branches);
           return treeNode(f, [adjust(b, refinement)|b<-bs], x=x/refinement, y = y/refinement);
           }
    }
    
void visitPrint(TreeNode root) {
    visit(root) {
        case v:treeNode(_,_): println("<<v.x, v.y>>");
        }
    }
  
 tuple[num, num] getMinXMaxY(TreeNode root) {
    num r1 = 0;
    num r2 = 0;
    visit(root) {
        case v:treeNode(_,_): {
            if (v.x<r1) r1 = v.x;
            if (v.x>r2) r2 = v.x;
            }
        }
    return <r1, r2>;
    }
    
 TreeNode translateX(TreeNode root, num x) {
    return visit(root) {
        case f:treeNode(Figure fig,list[TreeNode] branches)=> treeNode(fig, branches, x=f.x+x, y=f.y)
        }
    }
    



TreeNode treeLayout(Figure f) {


//list[int] leftOffset = [0|_<-[0..f.rasterHeight]];
//list[int] rightOffset = [0|_<-[0..f.rasterHeight]];
   
tuple[TreeBorder, TreeBorder, TreeNode] doShapeTree(TreeNode tree, int height, int yPosition,
int xSep, int ySep, TreeBorder left, TreeBorder right) {
   if (treeNode(Figure f, list[TreeNode] branches):=tree) {
        tuple[TreeBorder, TreeBorder, TreeNode] r;
        if (isEmpty(branches)) {
             left = <round(yPosition+getHeight(tree))-1,[0|_<-[0..height]]>;
             right = <round(yPosition+getHeight(tree))-1,[0|_<-[0..height]]>;
             for (int i <-[yPosition-ySep ..round(yPosition+getHeight(tree))]) {
                left.offset[i] = round(getWidth(tree)/2);
                right.offset[i] = round((getWidth(tree)+1)/2);
                }
             r= <left, right, treeNode(f, [], y=yPosition)>;    
             }
        else {
             list[TreeBorder] leftOutline = [<0, [0|_<-[0..height]]>|_<-branches];
             list[TreeBorder] rightOutline = [<0, [0|_<-[0..height]]>|_<-branches];
             list[tuple[TreeBorder left, TreeBorder right, TreeNode tree]] edge = [doShapeTree(
                   branches[i], height, yPosition+getHeight(tree)+ySep, xSep, ySep
                   , leftOutline[i],rightOutline[i])|
                       int i<-[0..size(branches)]];
             left = edge[0].left;
             right = edge[0].right;
             edge[0].tree.x = 0;
             for (int i<-[0..size(edge)-1]) {
                 num overlap = 0;
                 if (yPosition+getHeight(tree)+ySep <= min(edge[i+1].left.yPosition, right.yPosition))
                 for (int j<-[yPosition+getHeight(tree)+ySep..
                    min(edge[i+1].left.yPosition, right.yPosition)+1]) {
                    overlap = max(overlap, edge[i+1].left.offset[j]+right.offset[j]);
                    // println("j= <j> <overlap> <edge[i+1][0]>");
                    }
                 // Push Branches apart
                 TreeNode p = edge[i+1].tree;
                 p.x = overlap+xSep;
                 edge[i+1].tree = p;
                 // Adjust left outline
                 if (left.yPosition+1 < edge[i+1].left.yPosition+1)
                 for (int j<-[left.yPosition+1 .. edge[i+1].left.yPosition+1]) 
                         left.offset[j] = edge[i+1].left.offset[j] - edge[i+1].tree.x;
                  left.yPosition = max(left.yPosition, edge[i+1].left.yPosition);
                 // Adjust right outline
                 if (yPosition< edge[i+1].right.yPosition+1)
                 for (int j<-[yPosition .. edge[i+1].right.yPosition+1]) 
                         right.offset[j] = edge[i+1].right.offset[j] +edge[i+1].tree.x;
                  right.yPosition = max(right.yPosition, edge[i+1].right.yPosition);
                 }
            if (size(edge)>1) {
                    int centre = round(edge[-1][2].x/2);
                    for (int i<-[0..size(edge)]) {
                        TreeNode p = edge[i].tree;
                        p.x -= centre;
                        edge[i].tree  = p;
                        } 
                    // for (int i<-[0..size(branches)])println("Branch <i> <branches[i].x>");
                    for (int i<-[yPosition..left.yPosition+1]) left.offset[i]+=centre;
                    for (int i<-[yPosition..right.yPosition+1]) right.offset[i]-=centre;
                    }
             for (int i <-[yPosition-ySep ..round(yPosition+getHeight(tree))]) {
                left.offset[i] = round(getWidth(tree)/2);
                right.offset[i] = round((getWidth(tree)+1)/2);
                }
             r= <left, right, treeNode(f, [e.tree|e<-edge], y=yPosition)>;     
             }        
            return r; 
            
        }
        return  <0, 0, treeNode(emptyFigure(), [])>;
   }
     
    if (tree(TreeNode root):=f) {
      root = adjust(root, f.refinement);
      tuple[TreeBorder, TreeBorder, TreeNode] r = doShapeTree(root, f.rasterHeight, round(f.ySep/f.refinement),
      round(f.xSep/f.refinement), round(f.ySep/f.refinement),
      <round(f.ySep/f.refinement+getHeight(root))-1,[0|_<-[0..f.rasterHeight]]>,
      <round(f.ySep/f.refinement+getHeight(root))-1,[0|_<-[0..f.rasterHeight]]>
      );
      root = r[2];
      root = adjust(root, 1.0/f.refinement);
      // visitPrint(root);
      if (<num minX, num minY> := getMinXMaxY(root)) {
          root = translateX(root, -minX);
          }
      return root;
      }
    }