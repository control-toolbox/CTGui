using CTDirect
using CTBase # for plot, todo: reexport in CTDirect
using Mousetrap 

# use global variables for now
last_ocp = nothing # make permanent ie save on disk
last_sol = nothing # idem
current_ocp = nothing
current_sol = nothing


# not very useful...
function display_ocp(ocp)
    println(ocp)
end


# +++ later ask for ocp name (default: "ocp")
function on_load_ocp_clicked(self::Button, external_edit)
    println("Load problem...")
    file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
    on_accept!(file_chooser) do self::FileChooser, file::Vector{FileDescriptor}
        ocp_file = file[1]
        # load OCP definition
        include(get_path(ocp_file))
        ocp_name = "ocp"
        global current_ocp = eval(Symbol(ocp_name))
        global last_ocp = current_ocp
        #display_ocp(current_ocp)
        println("Loading OCP defined in $ocp_file")
        # open file in external editor
        if get_is_active(external_edit)
            open_file(ocp_file)
            println("Opening file $ocp_file")
        end
    end
    on_cancel!(file_chooser) do self::FileChooser
        println("Loading cancelled...")
    end
    present!(file_chooser)
    return nothing
end

# output is currently in julia REPL, try to pass textfield ?
# note: unless we bundle the app we will have the julia repl anyway, so maybe leave the outputs in it ?
function on_solve_clicked(self::Button)
    display_ocp(current_ocp)
    println("Solve problem...")
    global current_sol = solve(current_ocp)
    global last_sol = current_sol
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
    button_external_edit = CheckButton()
    set_child!(button_external_edit, Label("Open OCP in editor"))
    set_tooltip_text!(button_external_edit, "Open problem definition in external editor")

    button_load_ocp = Button()
    set_child!(button_load_ocp, Label("Load OCP"))
    set_tooltip_text!(button_load_ocp, "Load problem definition")
    connect_signal_clicked!(on_load_ocp_clicked, button_load_ocp, button_external_edit)

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

    # main window layout
    window = Window(app)
    set_title!(window, "control-toolbox")
    # MenuBar
    # reuse bocop2 icons for toolbar set_icon!
    # later add 3 tabs below button bar, cf StackSwitcher ?
    set_child!(window, hbox(button_load_ocp, button_external_edit, button_solve, button_plot))

    present!(window)
end
