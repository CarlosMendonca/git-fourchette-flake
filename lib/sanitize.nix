# Turn an upstream version string into a valid (and readable) Nix attr suffix.
#   "1.6.0"   -> "1_6_0"
#   "1.6.0-1" -> "1_6_0_1"
version: builtins.replaceStrings [ "." "-" "+" ] [ "_" "_" "_" ] version
