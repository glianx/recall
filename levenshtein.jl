module Levenshtein

export compute_diffs, showdiff

function compute_diffs(s1::AbstractString, s2::AbstractString)
    a, b = collect(s1), collect(s2)
    m, n = length(a), length(b)
    dp = fill(0, m+1, n+1)
    for i in 0:m
        dp[i+1,1] = i
    end
    for j in 0:n
        dp[1,j+1] = j
    end
    for i in 1:m
        for j in 1:n
            cost = a[i] == b[j] ? 0 : 1
            dp[i+1,j+1] = min(
                dp[i,j+1] + 1,     # deletion
                dp[i+1,j] + 1,     # insertion
                dp[i,j] + cost     # substitution/match
            )
        end
    end

    i, j = m, n
    diffs = Tuple{Symbol,Char}[]
    while i > 0 || j > 0
        if i>0 && j>0 && dp[i+1,j+1] == dp[i,j] + (a[i]==b[j] ? 0 : 1)
            if a[i]==b[j]
                pushfirst!(diffs, (:match,a[i]))
            else
                pushfirst!(diffs, (:delete,a[i]))
                pushfirst!(diffs, (:insert,b[j]))
            end
            i-=1; j-=1
        elseif i>0 && dp[i+1,j+1] == dp[i,j+1]+1
            pushfirst!(diffs, (:delete,a[i])); i-=1
        elseif j>0 && dp[i+1,j+1] == dp[i+1,j]+1
            pushfirst!(diffs, (:insert,b[j])); j-=1
        else
            break
        end
    end

    distance = dp[m+1,n+1]
    return diffs, distance
end

function showdiff(diffs::Vector{Tuple{Symbol,Char}})
    for (diff,c) in diffs
        if diff==:match
            printstyled(c; color=:white)
        elseif diff==:delete
            printstyled(c; color=:red, bold=true)
        elseif diff==:insert
            printstyled(c; color=:green, bold=true)
        end
    end
    println()
end

end