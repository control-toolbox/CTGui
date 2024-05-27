using CTDirect
using QML
include("ocp.jl") # defines ocp1
sol = solve(ocp1)

# try to load main.qml