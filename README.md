# Disaster Response Simulation in Julia

## Overview
This is a simple multi-agent simulation script designed to model disaster response scenarios. The script creates a flexible environment where different types of agents (Transport and Medical) collaborate to handle various emergency tasks across a grid-based landscape.

## Key Components

### Environment
- A grid-based simulation space with customizable dimensions
- Supports dynamic task generation
- Tracks agent positions and available resources

### Agent Types
1. **Transport Agent**
   - Carries and delivers resources
   - Can replenish its resource inventory
   - Focuses on delivering critical supplies

2. **Medical Agent**
   - Provides assistance at task locations
   - Specializes in different medical expertise
   - Can negotiate for resources with Transport Agents

### Simulation Features
- Dynamic task creation
- Priority-based task handling
- Agent movement using Manhattan distance
- Resource allocation
- Inter-agent communication

## Getting Started

### Prerequisites
- Julia programming language
- Vahana.jl library

### Running the Simulation

1. Define initial tasks
2. Create an environment
3. Initialize agents
4. Run the simulation for a specified number of steps

#### Example Initialization
```julia
# Create tasks
tasks = [
    Dict("location" => (7, 7), "type" => "deliver", "resource" => "food"),
    Dict("location" => (2, 2), "type" => "assist", "priority" => "critical")
]

# Set up environment
env = DisasterEnvironment((10, 10), tasks)

# Create agents
agents = [
    TransportAgent("Transport_1", (1, 1), Dict("food" => 10, "medicine" => 5)),
    MedicalAgent("Medical_1", (5, 5), "emergency"),
    MedicalAgent("Medical_2", (8, 8), "general")
]

# Run simulation for 50 steps
simulate(env, agents, 50)
```
### Simulation Behavior

- Agents move to task locations
- Transport Agents deliver resources
- Medical Agents provide assistance
- New random tasks are generated every 3 steps
- Tasks are sorted by priority
- Agents communicate and negotiate resources

### Potential Use Cases

- Emergency response planning
- Disaster management training
- Resource allocation strategies
- Multi-agent collaboration modeling

### Customization
Easily extend the simulation by:

- Modifying grid size
- Adding more agent types
- Creating complex task scenarios
- Adjusting resource management rules
