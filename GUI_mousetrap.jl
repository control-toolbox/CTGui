using CTDirect
using Mousetrap 
#= conflict with solve :(
...
EXIT: Optimal Solution Found.
ERROR: LoadError: MethodError: no method matching +(::Float64, ::Expr)

the error disappears if we comment using Mousetrap...
=#



include("ocp.jl")
sol = solve(ocp1)

#=
# main window control-toolbox
main() do app::Application
    window = Window(app)
    #set_child!(window, Title("control-toolbox"))

    button = Button()
    connect_signal_clicked!(button) do self::Button
        println(ocp1)
        
    end

    set_child!(window, button)

    present!(window)
end

# OCP definition
# load OCP in .jl


# solve
# run and display basic solve

# visualization
# plot solution
=#