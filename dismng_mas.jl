# Import libraries
using Vahana
using Dates

# === ENVIRONMENT SETUP ===
# Mutable struct to represent the disaster response environment
# Tracks grid size, tasks, and agent positions
mutable struct DisasterEnvironment
    grid_size::Tuple{Int, Int}  # Dimensions of the simulation grid
    tasks::Vector{Dict}  # List of tasks to be accomplished
    agent_positions::Dict{String, Tuple{Int, Int}}  # Tracking agent locations
end

# Constructor to initialize DisasterEnvironment with default empty agent positions
function DisasterEnvironment(grid_size::Tuple{Int, Int}, tasks)
    DisasterEnvironment(grid_size, tasks, Dict{String, Tuple{Int, Int}}())
end

# === AGENT DEFINITIONS ===
# Abstract type to serve as a base for different agent types
abstract type DisasterAgent end

# Transport Agent: responsible for delivering resources
mutable struct TransportAgent <: DisasterAgent
    id::String  # Unique identifier
    position::Tuple{Int, Int}  # Current location
    resources::Dict{String, Int}  # Inventory of available resources
end

# Medical Agent: responsible for providing assistance
mutable struct MedicalAgent <: DisasterAgent
    id::String  # Unique identifier
    position::Tuple{Int, Int}  # Current location
    expertise::String  # Specialization of medical agent
end

# === HELPERS ===
# Calculate Manhattan distance between two positions
function manhattan_distance(pos1::Tuple{Int, Int}, pos2::Tuple{Int, Int})
    # Sum of horizontal and vertical distance
    abs(pos1[1] - pos2[1]) + abs(pos1[2] - pos2[2])
end

# Move an agent to a new location
function move_agent(agent::DisasterAgent, destination::Tuple{Int, Int})
    # Create a new agent instance with updated position
    if isa(agent, TransportAgent)
        agent = TransportAgent(agent.id, destination, agent.resources)
    elseif isa(agent, MedicalAgent)
        agent = MedicalAgent(agent.id, destination, agent.expertise)
    end
    println("Agent $(agent.id) moved to location $destination")
    return agent
end

# === BEHAVIORS ===
# Allocate resources for a specific task
function allocate_resources(agent::TransportAgent, task, env::DisasterEnvironment)
    println("Allocating resources for task: $task by TransportAgent: $(agent.id)")
    resource = task["resource"]
    
    # Check if the required resource is available
    if resource in keys(agent.resources) && agent.resources[resource] > 0
        agent.resources[resource] -= 1
        println("Resource $(resource) allocated successfully. Remaining: $(agent.resources[resource])")
    else
        println("Resource $(resource) unavailable! TransportAgent $(agent.id) is replenishing resources.")
        replenish_resources(agent)
    end
end

# Replenish resources for a Transport Agent
function replenish_resources(agent::TransportAgent)
    println("TransportAgent $(agent.id) replenishing resources...")
    sleep(1)  # Simulate time delay for resource acquisition
    
    # Add 5 units to each resource type
    for key in keys(agent.resources)
        agent.resources[key] += 5
    end
    println("Resources replenished: $(agent.resources)")
end

# Medical Agent provides assistance for a task
function assist(agent::MedicalAgent, task)
    println("MedicalAgent $(agent.id) providing assistance at location: $(task["location"]) with priority: $(task["priority"])")
end

# Negotiate resource transfer between Medical and Transport Agents
function negotiate(agent_a::MedicalAgent, agent_b::TransportAgent, resource)
    println("MedicalAgent $(agent_a.id) negotiating with TransportAgent $(agent_b.id) for resource: $resource")
    
    # Check if resource is available and can be transferred
    if resource in keys(agent_b.resources) && agent_b.resources[resource] > 0
        println("Negotiation successful: $resource granted!")
        agent_b.resources[resource] -= 1
    else
        println("Negotiation failed: $resource unavailable!")
    end
end

# Communication between agents
function communicate(agent_a::DisasterAgent, agent_b::DisasterAgent, message)
    println("Agent $(agent_a.id) sending message to Agent $(agent_b.id): $message")
end

# === SIMULATION ===
# Main simulation function
function simulate(env::DisasterEnvironment, agents, steps)
    for step in 1:steps
        println("\n=== Step $step ===")
        println("Timestamp: $(now())")
        
        # Sort tasks by priority (critical tasks first)
        env.tasks = sort(env.tasks, by = t -> get(t, "priority", "low") == "critical" ? 0 : 1)

        # Process tasks for each agent
        for (i, task) in enumerate(env.tasks)
            for (j, agent) in enumerate(agents)
                # Transport Agent handles delivery tasks
                if isa(agent, TransportAgent) && task["type"] == "deliver"
                    # Move agent to task location if not already there
                    if manhattan_distance(agent.position, task["location"]) > 0
                        agents[j] = move_agent(agent, task["location"])
                    end
                    allocate_resources(agents[j], task, env)
                
                # Medical Agent handles assistance tasks
                elseif isa(agent, MedicalAgent) && task["type"] == "assist"
                    # Move agent to task location if not already there
                    if manhattan_distance(agent.position, task["location"]) > 0
                        agents[j] = move_agent(agent, task["location"])
                    end
                    assist(agents[j], task)
                end
            end
        end

        # Dynamically add a new random task every 3 steps
        if step % 3 == 0
            new_task = Dict("location" => (rand(1:env.grid_size[1]), rand(1:env.grid_size[2])), 
                            "type" => rand(["deliver", "assist"]), 
                            "resource" => "food", 
                            "priority" => rand(["low", "critical"]))
            push!(env.tasks, new_task)
            println("New task added: $new_task")
        end
    end
end

# === INITIALIZATION ===
# Initial set of tasks
tasks = [
    Dict("location" => (7, 7), "type" => "deliver", "resource" => "food"),
    Dict("location" => (2, 2), "type" => "assist", "priority" => "critical")
]

# Create environment
env = DisasterEnvironment((10, 10), tasks)

# Initialize agents with starting positions and resources
agents = [
    TransportAgent("Transport_1", (1, 1), Dict("food" => 10, "medicine" => 5)),
    MedicalAgent("Medical_1", (5, 5), "emergency"),
    MedicalAgent("Medical_2", (8, 8), "general")
]

# === RUN THE SIMULATION ===
# Start the simulation for 50 steps
simulate(env, agents, 50)
