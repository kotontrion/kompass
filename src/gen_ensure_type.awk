#!/usr/bin/awk -f
BEGIN { print "void ensure_types() {" }
/^\s*namespace\s*/ { namespace = $2 }
/\s*(public\s+)(sealed\s+)?class\s*/ {
  class_name = ($2 == "class" ? $3 : ($3 == "class" ? $4: $NF))
  if(namespace)
    print "    typeof(" namespace "." class_name ").ensure();" 
  else
    print "    typeof(" class_name ").ensure();" 
}
ENDFILE { namespace = "" }
END { print "}" }
