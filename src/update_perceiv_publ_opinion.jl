"""
   update_perceiv_publ_opinion!(state, agent_idx)

Update an agent's perceived public opinion depending on its neighbors and current feed

# Arguments
- `state`: a tuple of the current graph and agent_list
- `agent_idx`: agent index

See also: [`Config`](@ref), [`update_opinion!`](@ref)
"""
function update_perceiv_publ_opinion!(
    state::Tuple{AbstractGraph, AbstractArray},
    agent_idx::Integer
)

    graph, agent_list = state
    this_agent = agent_list[agent_idx]

    input = inneighbors(graph, agent_idx)
    if length(input) != 0
        input_opinion_mean = mean(
            [agent_list[input_agent].opinion for input_agent in input]
        )
    else
        input_opinion_mean = this_agent.opinion
    end

    feed_opinions = [post.opinion for post in this_agent.feed]
    feed_weights = [post.weight for post in this_agent.feed]

    if length(feed_opinions) > 0
        feed_opinion_mean = (
            sum(
                [opinion * weight for (opinion, weight)
                in zip(feed_opinions, feed_weights)]
            )
            / sum(feed_weights)
        )
    else
        feed_opinion_mean = this_agent.opinion
    end

    this_agent.perceiv_publ_opinion = mean(
        [input_opinion_mean, feed_opinion_mean]
    )

    return state
end

# suppress output of include()
;
