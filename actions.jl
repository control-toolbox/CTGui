using CTDirect
using CTBase #for plot
using JLD2

# Implement actions independently from GUI framework
# Ideally could be reused from different GUIs

mutable struct GUI_data
    
    current_ocp::Union{Nothing, CTBase.OptimalControlModel}
    current_sol::Union{Nothing, CTBase.OptimalControlSolution}
    ocp_path::String
    ocp_name::String
    label_show_ocp_path # Label for Mousetrap

    function GUI_data()

        data = new()
        data.current_ocp = nothing
        data.current_sol = nothing
        data.ocp_path = "please load problem"
        data.ocp_name = "ocp"
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
        println("Solve problem...")
        data.current_sol = solve(data.current_ocp)
    end
    return nothing
end

# +++ later ask for name, maybe a filechooser ?
function save_sol(data::GUI_data)
    if isnothing(data.current_sol)
        println("Please solve problem before saving solution.")
    else
        print("Save problem solution...")
        save_object("./test/solution.jld2", data.current_sol)
        println(" Done")
    end
    return nothing
end

function load_sol(data::GUI_data)
    print("Load problem solution...")
    data.current_sol = load_object("./test/solution.jld2")
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
