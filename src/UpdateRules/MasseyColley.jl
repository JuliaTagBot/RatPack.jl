export UpdateMasseyColley

"""
    UpdateMasseyColley

 MasseyColley update rule, e.g., see "Whos's #1", Langville and Meyer, p.25
    this is the "Colleyized Massey method", i.e., use Colley's matrix on scores

## Parameters (none)
```
"""
struct UpdateMasseyColley <: UpdateRule
# this is a batch calculation that takes no account of past ratings, and
# has no parameters
end

function update_info( rule::UpdateMasseyColley )
    name = "MasseyColley"
    reference = "\"Whos's #1\", Langville and Meyer, p.25"
    mode = "batch"    # alternatives: "batch", "recursive" 
    input = "score"   # alternatives: "outcome", "score"
    model = "single"  # alternatives: "single", "offence/defence"
    ties = true       # scores based systems can incorporate ties
    factors = false   # can it include extra factors
    parameters = []
    return name, reference, mode, input, model, ties, factors, parameters
end
update_info( ::Type{UpdateMasseyColley} ) =  update_info( UpdateMasseyColley() )

function update_ratings( rule::UpdateMasseyColley,
                         input_ratings::RatingsList,
                         input_competitions::DataFrame)
    n = size(input_competitions,1)
    m = length( input_ratings.players )
    I = player_indexes( input_ratings.players )
    
    # construct Colley matrices and vectors
    C = diagm(0 => 2*ones(Int,m))
    p = zeros(Int, m)
    d = input_competitions # just an abbreviation
    point_diff = d[:,ScoreA] - d[:,ScoreB]
    for i=1:n
        p[ I[d[i,PlayerA]] ] +=  point_diff[i]
        p[ I[d[i,PlayerB]] ] -=  point_diff[i]
        C[ I[d[i,PlayerA]], I[d[i,PlayerB]] ] -= 1
        C[ I[d[i,PlayerB]], I[d[i,PlayerA]] ] -= 1
        C[ I[d[i,PlayerA]], I[d[i,PlayerA]] ] += 1
        C[ I[d[i,PlayerB]], I[d[i,PlayerB]] ] += 1
    end
     
    # solve Colley's equation
    r = C \ p 
    ratings = Dict{String, Float64}()
    for player in input_ratings.players
        ratings[player] = r[ I[player] ]
    end
        
    # output ratings list
    output_ratings = RatingsList(m, input_ratings.players, ratings )   
    return output_ratings
end
