module salix::lib::Tree
import util::Math;
import Prelude;

int Y_SEPARATION = 10;
int MIN_X_SEPARATION = 10;

alias Edge = tuple[int yPosition, list[int] offset];

Edge left, right;

TreeNode adjust(TreeNode root, num refinement) {
    if (treeNode(Figure f, list[TreeNode] branches):=root) {
           f.width /= refinement; f.height /= refinement;
           return treeNode(f, [adjust(b, refinement)|b<-branches]);
           }
    }
    
Edge newEdge(int yPosition, int height) = <yPosition, [0|_<-[0..height]]>;

tuple[Edge, Edge, TreeNode] doShapeTree(TreeNode tree, int height, int yPosition) {
   if (treeNode(Figure f, list[TreeNode] branches):=tree) {
        if (isEmpty(branches)) {
             return <newEdge(yPosition+getHeight(tree), height)
                    ,newEdge(yPosition+getHeight(tree), height)
                    ,tree
                    >;
             }
        else {
             list[tuple[Edge left, Edge right, TreeNode tree]] edge = [doShapeTree(
                   b, height, yPosition+getHeight(tree)+Y_SEPARATION)|b<-branches];
             Edge left = edge[0][0];
             Edge right = edge[0][1];
             tree.branches[0].x = 0;
             for (int i<-[0..size(branches-1)]) {
                 num overlap = 0;
                 if (yPosition+getHeight(tree)+Y_SEPARATION < min(edge[i+1][0].yPosition, right.yPosition))
                 for (int j<-[yPosition+getHeight(tree)+Y_SEPARATION..
                    min(edge[i+1][0].yPosition, right.yPosition)])
                     overlap = max(overlap, edge[i+1][0].offset[j]+right.offset[j]);
                 // Push Branches apart
                 branches[i+1].x = overlap+MIN_X_SEPARATION;
                 // Adjust left outline
                 if (left.yPosition+getHeight(tree)+Y_SEPARATION+1 < edge[i+1][0].yPosition+1)
                 for (int j<-[left.yPosition+getHeight(tree)+Y_SEPARATION+1 ..
                    edge[i+1][0].yPosition+1]) 
                         left.offset[j] = edge[i+1][0].offset[j] - branches[i+1].x;
                  left.yPosition = mox(left.yPosition, edge[i+1][0].yPosition);
                 // Adjust right outline
                 if (right.yPosition+getHeight(tree)+Y_SEPARATION+1 < edge[i+1][1].yPosition+1)
                 for (int j<-[right.yPosition+getHeight(tree)+Y_SEPARATION+1 ..
                    edge[i+1][1].yPosition+1]) 
                         right.offset[j] = edge[i+1][1].offset[j] +branches[i+1].x;
                  right.yPosition = mox(right.yPosition, edge[i+1][1].yPosition);
                 }
                 if (size(branches)>1) {
                    num centre = branches[-1]/2;
                    for (int i<-[0..size(branches)]) branches[i].x  -= centre;
                    for (int i<-[yPosition..left.yPosition+1]) left.offset[i]+=centre;
                    for (int i<-[yPosition..right.yPosition+1]) right.offset[i]-=centre;
                    }           
             }
             if (int i <-[yPosition-Y_SEPARATION ..yPosition+getHeight(tree)]) {
                left.offset[i] = getWidth(tree)/2;
                right.offset[i] = (getWidth(tree)+1)/2;
                }
            tree.y = yPosition;
            return [left, right, treeNode(f, tree)];
        }
   }

TreeNode treeLayout(Figure f) {
    if (tree(TreeNode root):=f) {
      root = adjust(root, f.refinement);
      tuple[Edge, Edge, TreeNode] r = doShapeTree(root, f.rasterHeight, 0);
      root = r[2];
      root = adjust(root, 1/f.refinement);
      }
    }