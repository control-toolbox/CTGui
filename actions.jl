using CTDirect
using CTBase

# for solve
using NLPModelsIpopt
using HSL

# for save/load/export
using JLD2
using JSON3

# for plot
using Plots

# Implement actions independently from GUI framework
# Ideally could be reused from different GUIs

mutable struct GUI_data
    
    current_ocp::Union{Nothing, CTBase.OptimalControlModel}
    current_sol::Union{Nothing, CTBase.OptimalControlSolution}
    ocp_path::String
    ocp_name::String
    sol_path::String
    solve_options::Dict
    use_warmstart::Bool
    warmstart_sol::Union{Nothing, CTBase.OptimalControlSolution}
    warmstart_path::String
    # Labels for Mousetrap gui
    label_show_ocp_path 
    label_show_warmstart_path

    function GUI_data()

        data = new()
        data.current_ocp = nothing
        data.current_sol = nothing
        data.ocp_path = "please load problem"
        data.ocp_name = "ocp"
        data.sol_path = "./test/solution"
        use_warmstart = false
        data.warmstart_sol = nothing
        data.warmstart_path = "please choose solution"
        data.solve_options = Dict(:grid_size=>CTDirect.__grid_size_direct(), :print_level=>CTDirect.__print_level_ipopt(), :mu_strategy=>CTDirect.__mu_strategy_ipopt(), :display=>CTDirect.__display(), :max_iter=>CTDirect.__max_iter(), :tol=>CTDirect.__tol())
        return data
    end
end

# not very useful...
function display_ocp(ocp)
    println(ocp)
end

# +++ later ask for ocp name (default: "ocp")
function load_ocp(data::GUI_data)
    data.current_ocp = nothing
    include(data.ocp_path)
    data.current_ocp = eval(Symbol(data.ocp_name))
    println("Load problem defined in $(data.ocp_path)")
    return nothing
end


function solve_ocp(data::GUI_data)
    if isnothing(data.current_ocp)
        println("Please load OCP problem before solving.")
    else
        println("Solve problem with options... ", data.solve_options)
        data.current_sol = solve(data.current_ocp; data.solve_options...)
    end
    return nothing
end

function save_sol(data::GUI_data)
    if isnothing(data.current_sol)
        println("Please solve problem before saving solution.")
    else
        print("Save problem solution ", data.sol_path, ".jld2 ...")
        save(data.current_sol, filename_prefix=data.sol_path)
        println(" Done")
    end
    return nothing
end

function export_sol(data::GUI_data)
    if isnothing(data.current_sol)
        println("Please solve problem before exporting solution.")
    else
        sol_filename = "./test/solution"
        print("Export problem solution ", sol_filename, ".json ...")
        export_ocp_solution(data.current_sol, filename_prefix=sol_filename)
        println(" Done")
    end
    return nothing
end

function load_sol(data::GUI_data)
    print("Load problem solution ", data.sol_path, ".jld2 ...")
    data.current_sol = load(data.sol_path)
    println(" Done")
    return nothing
end

function load_warmstart_sol(data::GUI_data)
    print("Load warmstart solution ", data.warmstart_path, ".jld2 ...")
    data.warmstart_sol = load(data.warmstart_path)
    println(" Done")
    return nothing
end

# Note: plot appears in standalone window
function plot_sol(data::GUI_data)
    if isnothing(data.current_sol)
        println("Please solve problem or load solution before plotting.")
    else
        print("Plot solution...")
        display(plot(data.current_sol))
        println(" Done")
    end
    return nothing
end

# +++ later ask for name, maybe a filechooser ?
# +++ NB this will close the plot window -_-
# +++ maybe add the plot to data and re-display it ?
function save_plot(data::GUI_data)
    plot_filename = "./test/solution.png"
    print("Save plot as ", plot_filename, " ...")
    Plots.savefig(plot_filename)
    println(" Done")  
    return nothing
end
