using JSON
using ArgParse

s = ArgParseSettings() 
 
@add_arg_table! s begin 
    "input" 
        arg_type = String 
        required = true
    "output"
        arg_type = String
        required = true
    "--filter"
        help = "filter by genes listed in specific file"
        arg_type = String
        default = ""
    "--ncells"
        help = "maximum number of cells to extract"
        default = 1000000
        arg_type = Int
end 

parsed_args = parse_args(ARGS, s)

filename = parsed_args["input"]
umi_data = CSV.read(filename, DataFrame)

if parsed_args["filter"] != ""
    filename = parsed_args["filter"]
    genelist = CSV.read(filename, DataFrame)
    filter!(x -> x.gene in genelist[:,1], umi_data)
end

ncells = min(size(umi_data, 2), parsed_args["ncells"])
ngenes = size(umi_data, 1)

filename = parsed_args["output"]

genes = Int[]
cells = Int[]
counts = Int[]

for g in 1:ngenes
    gdata = umi_data[g,2:end]
    for c in 1:ncells
        ismissing(gdata[c]) && continue

        push!(genes, g)
        push!(cells, c)
        push!(counts, gdata[c])
    end
end

output = open(filename, "w")
data = (; N=length(counts), ncells=ncells, ngenes=length(idcs), genes=genes, cells=cells, counts=counts)
JSON.print(output, data )
close(output)
