module salix::lib::Tree
import salix::lib::Figure;
import util::Math;
import Prelude;

alias TreeBorder = tuple[int yPosition, list[int] offset];

TreeNode adjust(TreeNode root, num refinement) {
    if (treeNode(Figure f, list[TreeNode] branches):=root) {
           f.width /= refinement; f.height /= refinement;
           num x = root.x, y = root.y;
           return treeNode(f, [adjust(b, refinement)|b<-branches], x=x/refinement, y = y/refinement);
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
    
TreeBorder newEdge(int yPosition, int height) = <yPosition, [0|_<-[0..height]]>;

tuple[TreeBorder, TreeBorder, TreeNode] doShapeTree(TreeNode tree, int height, int yPosition,
int xSep, int ySep) {
   if (treeNode(Figure f, list[TreeNode] branches):=tree) {
        TreeBorder left, right;
        tuple[TreeBorder, TreeBorder, TreeNode] r;
        if (isEmpty(branches)) {
             left = newEdge(round(yPosition+getHeight(tree)), height);
             right = newEdge(round(yPosition+getHeight(tree)), height);
             }
        else {
             list[tuple[TreeBorder left, TreeBorder right, TreeNode tree]] edge = [doShapeTree(
                   b, height, yPosition+getHeight(tree)+ySep, xSep, ySep)|b<-branches];
             left = edge[0][0];
             right = edge[0][1];
             branches[0].x = 0;
             for (int i<-[0..size(branches)-1]) {
                 num overlap = 0;
                 if (yPosition+getHeight(tree)+ySep < min(edge[i+1][0].yPosition, right.yPosition))
                 for (int j<-[yPosition+getHeight(tree)+ySep..
                    min(edge[i+1][0].yPosition, right.yPosition)]) {
                    overlap = max(overlap, edge[i+1][0].offset[j]+right.offset[j]);
                    }
                 println("overlap=<overlap>");
                 // Push Branches apart
                 branches[i+1].x = overlap+xSep;
                 // Adjust left outline
                 if (left.yPosition+getHeight(tree)+ySep+1 < edge[i+1][0].yPosition+1)
                 for (int j<-[left.yPosition+getHeight(tree)+ySep+1 ..
                    edge[i+1][0].yPosition+1]) 
                         left.offset[j] = edge[i+1][0].offset[j] - branches[i+1].x;
                  left.yPosition = max(left.yPosition, edge[i+1][0].yPosition);
                 // Adjust right outline
                 if (right.yPosition+getHeight(tree)+ySep+1 < edge[i+1][1].yPosition+1)
                 for (int j<-[right.yPosition+getHeight(tree)+ySep+1 ..
                    edge[i+1][1].yPosition+1]) 
                         right.offset[j] = edge[i+1][1].offset[j] +branches[i+1].x;
                  right.yPosition = max(right.yPosition, edge[i+1][1].yPosition);
                 }
                 if (size(branches)>1) {
                    int centre = round(branches[-1].x/2);
                    for (int i<-[0..size(branches)]) branches[i].x  -= centre;
                    // for (int i<-[0..size(branches)])println("Branch <i> <branches[i].x>");
                    for (int i<-[yPosition..left.yPosition+1]) left.offset[i]+=centre;
                    for (int i<-[yPosition..right.yPosition+1]) right.offset[i]-=centre;
                    }     
             }
             for (int i <-[yPosition-ySep ..round(yPosition+getHeight(tree))]) {
                left.offset[i] = round(getWidth(tree)/2);
                right.offset[i] = round((getWidth(tree)+1)/2);
                }
            r= <left, right, treeNode(f, branches, y=yPosition)>;
            return r; 
            
        }
        return  <0, 0, treeNode(emptyFigure(), [])>;
   }

TreeNode treeLayout(Figure f) {
    if (tree(TreeNode root):=f) {
      root = adjust(root, f.refinement);
      tuple[TreeBorder, TreeBorder, TreeNode] r = doShapeTree(root, f.rasterHeight, round(f.ySep/f.refinement),
      round(f.xSep/f.refinement), round(f.ySep/f.refinement));
      root = r[2];
      root = adjust(root, 1.0/f.refinement);
      if (<num minX, num minY> := getMinXMaxY(root)) {
          root = translateX(root, -minX);
          }
      visitPrint(root);
      return root;
      }
    }