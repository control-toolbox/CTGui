using CTDirect
using CTBase # for plot, todo: reexport in CTDirect
using Mousetrap 


my_ocp = nothing
my_sol = nothing

# not very useful...
function display_ocp(ocp)
    println(ocp)
end

# +++todo: load a .jl file
#  cf FileChooser ? openfile to display / edit externally ?
include("ocp.jl")
function on_load_ocp_clicked(seff::Button)
    println("Load problem...")
    global my_ocp = ocp
    display_ocp(my_ocp)
    return nothing
end

# output is currently in julia REPL, try to pass textfield
function on_solve_clicked(self::Button)
    display_ocp(my_ocp)
    println("Solve problem...")
    global my_sol = solve(my_ocp)
    return nothing
end

# currently fails, probably needs to pass a 'figure' object
# renderarea ?
function on_plot_clicked(self::Button)
    println("Plot solution...")
    plot(my_sol)
    return nothing
end


# main window control-toolbox
main() do app::Application

    # +++ use Actions instead

    # load ocp
    button_load_ocp = Button()
    set_child!(button_load_ocp, Label("Load"))
    set_tooltip_text!(button_load_ocp, "Load problem")
    connect_signal_clicked!(on_load_ocp_clicked, button_load_ocp)

    # solve ocp
    button_solve = Button()
    set_child!(button_solve, Label("Solve"))
    set_tooltip_text!(button_solve, "Solve problem")
    connect_signal_clicked!(on_solve_clicked, button_solve)

    # plot solution
    button_plot = Button()
    set_child!(button_plot, Label("Plot"))
    set_tooltip_text!(button_plot, "Plot solution")
    connect_signal_clicked!(on_plot_clicked, button_plot)

    # main window layout
    window = Window(app)
    set_title!(window, "control-toolbox")
    # MenuBar
    # reuse bocop2 icons for toolbar set_icon!
    # later add 3 tabs below button bar, cf StackSwitcher ?
    set_child!(window, hbox(button_load_ocp, button_solve, button_plot))

    present!(window)
end
