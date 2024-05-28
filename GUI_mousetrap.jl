using CTDirect
using CTBase # for plot, todo: reexport in CTDirect
using Mousetrap 

# use global variables for now
current_ocp = nothing
current_sol = nothing
ocp_path = "please load problem"
ocp_name = "ocp"

# not very useful...
function display_ocp(ocp)
    println(ocp)
end

# +++ later ask for ocp name (default: "ocp")
function on_load_ocp_clicked(self::Button)
    file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
    on_accept!(file_chooser) do self::FileChooser, file::Vector{FileDescriptor}
        global ocp_path = get_path(file[1])
        include(ocp_path)
        global current_ocp = eval(Symbol(ocp_name))
        println("Load problem defined in $ocp_path")
    end
    on_cancel!(file_chooser) do self::FileChooser
        println("Load cancelled...")
    end
    present!(file_chooser)
    return nothing
end

function on_reload_ocp_clicked(self::Button)
    global current_ocp = nothing
    include(ocp_path)
    global current_ocp = eval(Symbol(ocp_name))
    println("Reload problem defined in $ocp_path")
end

# open file in external editor
function on_edit_ocp_clicked(self::Button)
    file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
    on_accept!(file_chooser) do self::FileChooser, file::Vector{FileDescriptor}
        global ocp_path = get_path(file[1])
        open_file(file[1])
        println("Open $ocp_path")
    end
    on_cancel!(file_chooser) do self::FileChooser
        println("Open cancelled...")
    end
    present!(file_chooser)
    return nothing
end
# output is currently in julia REPL, try to pass textfield ?
# note: unless we bundle the app we will have the julia repl anyway, so maybe leave the outputs in it ?
function on_solve_clicked(self::Button)
    #display_ocp(current_ocp)
    println("Solve problem...")
    global current_sol = solve(current_ocp)
    return nothing
end

# Note: plot appears in standalone window
function on_plot_clicked(self::Button)
    println("Plot solution...")
    p = plot(current_sol)
    display(p)
    return nothing
end


# main window control-toolbox
main() do app::Application

    # +++ use Actions instead

    # load ocp
    # +++ auto load last problem used
    button_load_ocp = Button()
    set_child!(button_load_ocp, Label("Load OCP"))
    set_tooltip_text!(button_load_ocp, "Load problem definition")
    connect_signal_clicked!(on_load_ocp_clicked, button_load_ocp)

    # +++ filemonitor later ?
    button_reload_ocp = Button()
    set_child!(button_reload_ocp, Label("Reload OCP"))
    set_tooltip_text!(button_reload_ocp, "Reload problem definition")
    connect_signal_clicked!(on_reload_ocp_clicked, button_reload_ocp)

    button_edit_ocp = Button()
    set_child!(button_edit_ocp, Label("Edit OCP"))
    set_tooltip_text!(button_edit_ocp, "Open problem definition in external editor")
    connect_signal_clicked!(on_edit_ocp_clicked, button_edit_ocp)

    # solve ocp
    # +++ add save sol (need function in CTDirect, or use native julia format and just save the variable)
    button_solve = Button()
    set_child!(button_solve, Label("Solve OCP"))
    set_tooltip_text!(button_solve, "Solve problem")
    connect_signal_clicked!(on_solve_clicked, button_solve)

    # plot solution
    # +++ add save plot
    # +++ auto load last solution (this would open a new window, add as an option)
    # +++ option for new plot or reset previous one (need to add some reuse option to CTBase plot ?)
    # +++ close all plots on exit ?
    button_plot = Button()
    set_child!(button_plot, Label("Plot solution"))
    set_tooltip_text!(button_plot, "Plot solution")
    connect_signal_clicked!(on_plot_clicked, button_plot)

    # +++MenuBar
    # +++reuse bocop2 icons for toolbar set_icon!
    # +++later add 3 tabs below button bar, cf StackSwitcher ?

    # layout blocks: ocp, solve, plot
    #show_ocp_path = Current problem: $ocp_file
    #show_ocp_name ocp_name (editable, bouton edit ?)
    #ocp_info = hbox(show_ocp_path, show_ocp_name)
    ocp_bar = hbox(button_load_ocp, button_reload_ocp, button_edit_ocp)
    set_spacing!(ocp_bar, 10)
    block_ocp = ocp_bar
    block_solve = button_solve
    block_plot = button_plot

    # main window
    window = Window(app)
    set_title!(window, "control-toolbox")
    sep1 = Separator()
    set_margin!(sep1, 20)
    sep2 = Separator()
    set_margin!(sep2, 20)
    set_child!(window, vbox(block_ocp, sep1, block_solve, sep2, block_plot))
    present!(window)
end
