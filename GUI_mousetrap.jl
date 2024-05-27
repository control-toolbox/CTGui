using CTDirect
using Mousetrap 

include("ocp.jl")


# main window control-toolbox
main() do app::Application
    window = Window(app)
    #set_child!(window, Title("control-toolbox"))

    button = Button()
    connect_signal_clicked!(button) do self::Button
        println(ocp1)
        sol = solve(ocp1)
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