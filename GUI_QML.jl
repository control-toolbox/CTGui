using CTDirect
using QML

include("ocp.jl")
sol = solve(ocp1)

# try to load main.qml