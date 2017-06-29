module salix::lib::Math
import salix::Core;
import salix::Node;


Cmd rerun(Msg f, int id, str txt) = command("rerun", encode(f), args = ("id": id, "txt": txt));

@doc{Smart constructors for constructing encoded subscriptions.}
Sub timeOnce(Msg(int) int2msg, int interval)
  = subscription("timeOnce", encode(int2msg), args = ("interval": interval));
