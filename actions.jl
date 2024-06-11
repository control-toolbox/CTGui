using CTDirect
using CTBase #for plot
using JLD2
using Plots

# Implement actions independently from GUI framework
# Ideally could be reused from different GUIs

mutable struct GUI_data
    
    current_ocp::Union{Nothing, CTBase.OptimalControlModel}
    current_sol::Union{Nothing, CTBase.OptimalControlSolution}
    ocp_path::String
    ocp_name::String
    solve_options::Dict
    label_show_ocp_path # Label for Mousetrap

    function GUI_data()

        data = new()
        data.current_ocp = nothing
        data.current_sol = nothing
        data.ocp_path = "please load problem"
        data.ocp_name = "ocp"
        data.solve_options = Dict(:grid_size=>CTDirect.__grid_size_direct(), :print_level=>CTDirect.__print_level_ipopt(), :mu_strategy=>CTDirect.__mu_strategy_ipopt(), :display=>CTDirect.__display(), :max_iter=>1000, :tol=>1e-8) #+++ add ctdirect default for tol and maxiter
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

# +++ later ask for name, maybe a filechooser ?
function save_sol(data::GUI_data)
    if isnothing(data.current_sol)
        println("Please solve problem before saving solution.")
    else
        sol_filename = "./test/solution.jld2"
        print("Save problem solution ", sol_filename, " ...")
        save_object(sol_filename, data.current_sol)
        println(" Done")
    end
    return nothing
end

# +++ later ask for name, maybe a filechooser ?
function load_sol(data::GUI_data)
    sol_filename = "./test/solution.jld2"
    print("Load problem solution ", sol_filename, " ...")
    data.current_sol = load_object(sol_filename)
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
