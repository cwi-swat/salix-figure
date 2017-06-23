module salix::lib::Math
import salix::Core;
import salix::Node;


Cmd rerun(Msg f) = command("rerun", encode(f));
