module salix::ParseHtml

import lang::xml::DOM;
import salix::Node;
import salix::SVG;


import IO;
import String;

public salix::Node::Node html2Node(str src) {
    if (!startsWith(src, "\<")) return node2node(cdata(src));
    return node2node(parseXMLDOM(src));
    }

private salix::Node::Node node2node(lang::xml::DOM::Node n) {
  switch (n) {
    case document(lang::xml::DOM::Node root):
      return node2node(root);
      
    case lang::xml::DOM::Node::element(_, str name, list[lang::xml::DOM::Node] kids): {
      map[str,str] attrs = ( k: v | attribute(_, str k, str v) <- kids );
      list[salix::Node::Node] nodes = [ node2node(kid) | lang::xml::DOM::Node kid <- kids, attribute(_, _, _) !:= kid ];
      return element(name, nodes, attrs, (), ());
    } 
    
    case charData(str text):
      return txt(text);
      
    case cdata(str text):
      return txt(text);

    case entityRef(str name):
      return txt("&<name>;");
      
    case charRef(int code):
      return txt("&#<code>;");
      
    case comment(_):
      return txt("");
      
    default:
      throw "Unsupported node: <n>";     
  }
}