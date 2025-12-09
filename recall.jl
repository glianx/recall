using Images, ImageView
using CSV, DataFrames
using Random

include("levenshtein.jl")
using .Levenshtein

function getdict(path::AbstractString)
    df = CSV.read(path, DataFrame)

    dict = Dict(
        row.Title => (artist=row.Artist, year=row.Year)
        for row in eachrow(df)
    )

    return dict
end

function recallfile(file::AbstractString, dict::AbstractDict)
    img = load(joinpath("./imgs_rgb", file))
    imshow(img)
    
    println("Enter <Title> <Artist> <Year>: ")
    title = splitext(file)[1]
    response = lowercase(readline())

    expected = lowercase(join([
        title, 
        dict[title].artist, 
        string(dict[title].year)]
    , " "))

    # expected = string(dict[title].year)

    diffs, distance = compute_diffs(response, expected)
    score = 1 - distance / length(expected)
    percent = round(Int, score * 100)

    showdiff(diffs)
    println(expected)
    println("$(percent)%")

    return score
end
    
function main()
    total_score = 0.0

    dict = getdict("imgs.csv")
    files = readdir("./imgs_rgb")
    shuffle!(files)

    tryagain = []

    for file in files
        score = recallfile(file, dict)
        total_score += score
        if score != 1
            pushfirst!(tryagain, file)
        end
    end

    avg_score = round(Int, total_score / length(files) * 100)
    println("AVERAGE SCORE: $(avg_score)%\n\n")

    while length(tryagain) > 0
        file = pop!(tryagain)
        score = recallfile(file, dict)
        if score != 1
            pushfirst!(tryagain, file)
        end
    end
end

while true
    main()
    println("new game!")
end