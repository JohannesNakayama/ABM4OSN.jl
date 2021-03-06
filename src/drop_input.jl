"""
    drop_input!(state, agent_idx, config)

Drop input for specific agent (~ unfollow on Twitter).

# Arguments
- `state`: A tuple of the current graph and agent_list
- `agent_idx`: Agent index
- `config`: Config object as provided by Config

See also: [`Config`](@ref), [`add_input!`](@ref)
"""
function drop_input!(
    state::Tuple{AbstractGraph, AbstractArray},
    agent_idx::Integer,
    config::Config
)

    graph, agent_list = state
    this_agent = agent_list[agent_idx]

    unfollow_candidates = Array{Tuple{Int64, Int64}, 1}()
    for post in this_agent.feed
        if (
            abs(post.opinion - this_agent.opinion)
            > config.opinion_threshs.unfollow
        )
            if (
                abs(agent_list[post.source_agent].opinion - this_agent.opinion)
                > config.opinion_threshs.unfollow
            )
                if (
                    (
                        outdegree(graph, post.source_agent)
                        / outdegree(graph, agent_idx)
                    ) > 1
                    && rand() > 0.5
                )
                    push!(
                        unfollow_candidates,
                        (post.source_agent, outdegree(graph, post.source_agent))
                    )
                elseif (
                    (
                        outdegree(graph, post.source_agent)
                        / outdegree(graph, agent_idx)
                    ) <= 1
                )
                    push!(
                        unfollow_candidates,
                        (post.source_agent, outdegree(graph, post.source_agent))
                    )
                end
            end
        end
    end

    sort!(unfollow_candidates, by=last)

    drop_count = min(
        length(unfollow_candidates),
        ceil(
            Int64,
            indegree(graph,agent_idx) * config.agent_props.unfollow_rate
        )
    )

    for i in 1:drop_count
        rem_edge!(graph, unfollow_candidates[i][1],agent_idx)
    end

    return state

end

# suppress output of include()
;
