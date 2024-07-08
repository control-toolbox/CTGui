using Mousetrap

# GUI-agnostic actions
include("../actions.jl")


# Mousetrap actions handlers
# +++ later ask for ocp name (default: "ocp")
function on_load_ocp_clicked(self::Button, data::GUI_data)
    file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
    on_accept!(file_chooser) do self::FileChooser, file::Vector{FileDescriptor}
        data.ocp_path = get_path(file[1])
        load_ocp(data)
        set_text!(data.label_show_ocp_path, "Current problem: $(data.ocp_path)")
        return nothing
    end
    on_cancel!(file_chooser) do self::FileChooser
        println("Load cancelled...")
    end
    present!(file_chooser)
    return nothing
end


function on_reload_ocp_clicked(self::Button, data::GUI_data)
    load_ocp(data)
    set_text!(data.label_show_ocp_path, "Current problem: $(data.ocp_path)")
    return nothing
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
    # (re)set warm start
    if data.use_warmstart
        data.solve_options[:init]=data.warmstart_sol
    else
        delete!(data.solve_options, :init)
    end
    # solve ocp
    solve_ocp(data)
    return nothing
end

function on_warmstart_switched(self::Switch, data::GUI_data)
    data.use_warmstart = get_is_active(self)
    return nothing
end


function on_save_sol_clicked(self::Button, data::GUI_data)
    save_sol(data)
    return nothing
end

#+++ filechooser needs to allow creation of new file...
# FILE_CHOOSER_ACTION_SAVE seems broken
function on_save_sol_as_clicked(self::Button, data::GUI_data)
    file_chooser = FileChooser(FILE_CHOOSER_OPEN_FILE)
    on_accept!(file_chooser) do self::FileChooser, file::Vector{FileDescriptor}
        data.sol_path = get_path(file[1])
        save_sol(data)
        return nothing
    end
    on_cancel!(file_chooser) do self::FileChooser
        println("Save cancelled...")
    end
    present!(file_chooser)
end

# +++ add filter .jld2
function on_load_sol_clicked(self::Button, data::GUI_data)
    file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
    on_accept!(file_chooser) do self::FileChooser, file::Vector{FileDescriptor}
        data.sol_path = splitext(get_path(file[1]))[1]
        load_sol(data)
        return nothing
    end
    on_cancel!(file_chooser) do self::FileChooser
        println("Load cancelled...")
    end
    present!(file_chooser)
end

function on_load_warmstart_sol_clicked(self::Button, data::GUI_data)
    file_chooser = FileChooser(FILE_CHOOSER_ACTION_OPEN_FILE)
    on_accept!(file_chooser) do self::FileChooser, file::Vector{FileDescriptor}
        data.warmstart_path = splitext(get_path(file[1]))[1]
        load_warmstart_sol(data)
        set_text!(data.label_show_warmstart_path, "Warmstart: $(data.warmstart_path)")
        return nothing
    end
    on_cancel!(file_chooser) do self::FileChooser
        println("Load cancelled...")
    end
    present!(file_chooser)
end

function on_export_sol_clicked(self::Button, data::GUI_data)
    export_sol(data)
    return nothing
end

function on_print_level_set(self::Entry, data::GUI_data)
    # +++ call generic set_solve_option(key, value)
    println("input ", get_text(self))
    #data.solve_options[:print_level] = parse(Int,get_text(self))
    return nothing
end

# Note: plot appears in standalone window
function on_plot_clicked(self::Button, data::GUI_data)
    plot_sol(data)
    return nothing
end

function on_save_plot_clicked(self::Button, data::GUI_data)
    save_plot(data)
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
    button_solve = Button()
    set_child!(button_solve, Label("Solve OCP"))
    set_tooltip_text!(button_solve, "Solve problem")
    connect_signal_clicked!(on_solve_clicked, button_solve, data)

    # solution
    button_save_sol = Button()
    set_child!(button_save_sol, Label("Save"))
    set_tooltip_text!(button_save_sol, "Save problem solution")
    connect_signal_clicked!(on_save_sol_clicked, button_save_sol, data)

    button_save_sol_as = Button()
    set_child!(button_save_sol_as, Label("Save as"))
    set_tooltip_text!(button_save_sol_as, "Save problem solution as ...")
    connect_signal_clicked!(on_save_sol_as_clicked, button_save_sol_as, data)

    button_load_sol = Button()
    set_child!(button_load_sol, Label("Load solution"))
    set_tooltip_text!(button_load_sol, "Load an OCP solution")
    connect_signal_clicked!(on_load_sol_clicked, button_load_sol, data)

    button_load_warmstart_sol = Button()
    set_child!(button_load_warmstart_sol, Label("..."))
    set_tooltip_text!(button_load_warmstart_sol, "Choose OCP solution for warmstart")
    connect_signal_clicked!(on_load_warmstart_sol_clicked, button_load_warmstart_sol, data)

    button_export_sol = Button()
    set_child!(button_export_sol, Label("Export"))
    set_tooltip_text!(button_export_sol, "Export problem solution in JSON format")
    connect_signal_clicked!(on_export_sol_clicked, button_export_sol, data)

    #=
    # +++ bug ? get_text always returns empty string -_-
    print_level_entry = Entry()
    set_max_width_chars!(print_level_entry,1)
    set_text!(print_level_entry, string(data.solve_options[:print_level]))
    connect_signal_text_changed!(print_level_entry) do self::Entry
        println("text is now: $(get_text(self))")
    end
    connect_signal_activate!(on_print_level_set, print_level_entry, data)
    =#

    # plot solution
    # +++ auto load last solution (this would open a new window, add as an option)
    # +++ option for new plot or reset previous one (need to add some reuse option to CTBase plot ?)
    # +++ close all plots on exit ?
    button_plot = Button()
    set_child!(button_plot, Label("Plot solution"))
    set_tooltip_text!(button_plot, "Plot solution")
    connect_signal_clicked!(on_plot_clicked, button_plot, data)

    button_save_plot = Button()
    set_child!(button_save_plot, Label("Save plot"))
    set_tooltip_text!(button_save_plot, "Save plot")
    connect_signal_clicked!(on_save_plot_clicked, button_save_plot, data)

    switch_warmstart = Switch()
    set_is_active!(switch_warmstart, false)
    connect_signal_switched!(on_warmstart_switched, switch_warmstart, data)

    # +++MenuBar
    # +++reuse bocop2 icons for toolbar set_icon!
    # +++later add 3 tabs below button bar, cf StackSwitcher ?

    # layout blocks: ocp, solve, plot
    ocp_bar = CenterBox(ORIENTATION_HORIZONTAL)
    set_start_child!(ocp_bar, button_load_ocp)
    set_center_child!(ocp_bar, button_edit_ocp)
    set_end_child!(ocp_bar, button_reload_ocp)
    data.label_show_ocp_path = Label("Current problem: $(data.ocp_path)")
    block_ocp = vbox(data.label_show_ocp_path, ocp_bar)
    set_spacing!(block_ocp, 3)

    block_solve = CenterBox(ORIENTATION_HORIZONTAL)
    set_start_child!(block_solve, button_solve)
    set_center_child!(block_solve, button_save_sol)
    set_end_child!(block_solve, button_export_sol)  

    block_warmstart = CenterBox(ORIENTATION_HORIZONTAL)
    data.label_show_warmstart_path = Label("Warmstart: $(data.warmstart_path)")
    set_start_child!(block_warmstart, switch_warmstart)
    set_center_child!(block_warmstart, data.label_show_warmstart_path)
    set_end_child!(block_warmstart, button_load_warmstart_sol)

    #=
    print_level_input = hbox(Label("print_level"), print_level_entry) # does not get text properly...
    solve_options = hbox()
    =#

    block_plot = CenterBox(ORIENTATION_HORIZONTAL)
    set_start_child!(block_plot, button_plot)
    set_center_child!(block_plot, button_save_plot)
    set_end_child!(block_plot, button_load_sol)

    # main window
    window = Window(app)
    set_title!(window, "control-toolbox")
    sep1 = Separator()
    set_margin!(sep1, 20)
    sep2 = Separator()
    set_margin!(sep2, 20)
    set_child!(window, vbox(block_ocp, sep1, block_solve, block_warmstart, sep2, block_plot))
    present!(window)
end
