using CTDirect
using CTBase #for plot
using Mousetrap
using JLD2

mutable struct GUI_data
    
    current_ocp::Union{Nothing, CTBase.OptimalControlModel}
    current_sol::Union{Nothing, CTBase.OptimalControlSolution}
    ocp_path::String
    ocp_name::String
    show_ocp_path

    function GUI_data()

        data = new()
        data.current_ocp = nothing
        data.current_sol = nothing
        data.ocp_path = "please load problem"
        data.ocp_name = "ocp"
        data.show_ocp_path = Label("Current problem: $(data.ocp_path)")

        return data
    end
end

# not very useful...
function display_ocp(ocp)
    println(ocp)
end

# +++ later ask for ocp name (default: "ocp")
function on_load_ocp_clicked(self::Button, data::GUI_data)
    file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
    on_accept!(file_chooser) do self::FileChooser, file::Vector{FileDescriptor}
        data.ocp_path = get_path(file[1])
        include(data.ocp_path)
        set_text!(data.show_ocp_path, "Current problem: $(data.ocp_path)")
        data.current_ocp = eval(Symbol(data.ocp_name))
        println("Load problem defined in $(data.ocp_path)")
    end
    on_cancel!(file_chooser) do self::FileChooser
        println("Load cancelled...")
    end
    present!(file_chooser)
    return nothing
end

function on_reload_ocp_clicked(self::Button, data::GUI_data)
    data.current_ocp = nothing
    include(data.ocp_path)
    data.current_ocp = eval(Symbol(data.ocp_name))
    println("Reload problem defined in $(data.ocp_path)")
end

# open file in external editor
function on_edit_ocp_clicked(self::Button, data::GUI_data)
    file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
    on_accept!(file_chooser) do self::FileChooser, file::Vector{FileDescriptor}
        data.ocp_path = get_path(file[1])
        open_file(file[1])
        println("Open $(data.ocp_path)")
    end
    on_cancel!(file_chooser) do self::FileChooser
        println("Open cancelled...")
    end
    present!(file_chooser)
    return nothing
end
# output is currently in julia REPL, try to pass textfield ?
# note: unless we bundle the app we will have the julia repl anyway, so maybe leave the outputs in it ?
# +++ try to use Logging ?
function on_solve_clicked(self::Button, data::GUI_data)

    if isnothing(data.current_ocp)
        println("Please load OCP problem before solving.")
    else
        println("Solve problem...")
        data.current_sol = solve(data.current_ocp)
    end
    return nothing
end

# +++ later ask for name, maybe a filechooser ?
function on_save_sol_clicked(self::Button, data::GUI_data)
    if isnothing(data.current_sol)
        println("Please solve problem before saving solution.")
    else
        print("Save problem solution...")
        save_object("solution.jld2", data.current_sol)
        println(" Done")
    end
    return nothing
end

function on_load_sol_clicked(self::Button, data::GUI_data)
    print("Load problem solution...")
    data.current_sol = load_object("solution.jld2")
    println(" Done")
    return nothing
end

# Note: plot appears in standalone window
function on_plot_clicked(self::Button, data::GUI_data)
    if isnothing(data.current_sol)
        println("Please solve problem or load solution before plotting.")
    else
        print("Plot solution...")
        display(plot(data.current_sol))
        println(" Done")
    end
    return nothing
end


# main window control-toolbox
main() do app::Application

    # +++ use Actions instead

    # use data struct instead of global variables
    data = GUI_data()

    # +++ auto load last problem used
    button_load_ocp = Button()
    set_child!(button_load_ocp, Label("Load OCP"))
    set_tooltip_text!(button_load_ocp, "Load problem definition")
    connect_signal_clicked!(on_load_ocp_clicked, button_load_ocp, data)

    # +++ filemonitor later ?
    button_reload_ocp = Button()
    set_child!(button_reload_ocp, Label("Reload OCP"))
    set_tooltip_text!(button_reload_ocp, "Reload problem definition")
    connect_signal_clicked!(on_reload_ocp_clicked, button_reload_ocp, data)

    button_edit_ocp = Button()
    set_child!(button_edit_ocp, Label("Edit OCP"))
    set_tooltip_text!(button_edit_ocp, "Open problem definition in external editor")
    connect_signal_clicked!(on_edit_ocp_clicked, button_edit_ocp, data)

    # solve ocp
    # +++ add save sol (need function in CTDirect, or use native julia format and just save the variable)
    button_solve = Button()
    set_child!(button_solve, Label("Solve OCP"))
    set_tooltip_text!(button_solve, "Solve problem")
    connect_signal_clicked!(on_solve_clicked, button_solve, data)

    button_save_sol = Button()
    set_child!(button_save_sol, Label("Save solution"))
    set_tooltip_text!(button_save_sol, "Save problem solution after solve")
    connect_signal_clicked!(on_save_sol_clicked, button_save_sol, data)

    # plot solution
    # +++ add save plot
    # +++ auto load last solution (this would open a new window, add as an option)
    # +++ option for new plot or reset previous one (need to add some reuse option to CTBase plot ?)
    # +++ close all plots on exit ?
    button_plot = Button()
    set_child!(button_plot, Label("Plot solution"))
    set_tooltip_text!(button_plot, "Plot solution")
    connect_signal_clicked!(on_plot_clicked, button_plot, data)

    button_load_sol = Button()
    set_child!(button_load_sol, Label("Load solution"))
    set_tooltip_text!(button_load_sol, "Load an OCP solution")
    connect_signal_clicked!(on_load_sol_clicked, button_load_sol, data)

    # +++MenuBar
    # +++reuse bocop2 icons for toolbar set_icon!
    # +++later add 3 tabs below button bar, cf StackSwitcher ?

    # layout blocks: ocp, solve, plot
    #show_ocp_name ocp_name (editable, bouton edit ?)
    #ocp_info = hbox(show_ocp_path, show_ocp_name)
    #ocp_bar = hbox(button_load_ocp, button_reload_ocp, button_edit_ocp)
    #set_spacing!(ocp_bar, 10)
    ocp_bar = CenterBox(ORIENTATION_HORIZONTAL)
    set_start_child!(ocp_bar, button_load_ocp)
    set_center_child!(ocp_bar, button_reload_ocp)
    set_end_child!(ocp_bar, button_edit_ocp)
    block_ocp = vbox(data.show_ocp_path, ocp_bar)
    set_spacing!(block_ocp, 3)
    block_solve = hbox(button_solve, button_save_sol)
    block_plot = hbox(button_plot, button_load_sol)

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
