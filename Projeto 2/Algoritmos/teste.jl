using DataFrames, BenchmarkTools, Juno


function dividir_e_ordenar_por_empresa(
    vetor_entrada::Vector{Tuple{Int64,Int64,Int64,Float64}};
    funcao_ordenacao = funcao_ordenacao
)::Vector{Tuple{Int64,Int64,Int64,Float64}}

    n = vetor_entrada[end][3]

    vetor_saida = similar(vetor_entrada)
    indice_inicial = 1
    indice_final = 120

    for i = 1:n
        vetor_saida[indice_inicial:indice_final] = funcao_ordenacao(vetor_entrada[indice_inicial:indice_final])
        n -=1
        indice_inicial = indice_final + 1
        indice_final = indice_inicial + n - 1

    end
    return  vetor_saida
end

include("Inicializacao.jl")
include("Algoritmos_Ordenacao.jl")
using BenchmarkTools
var = Inicializacao.inicializar_variaveis("Dados/entrada.txt")

const entrada_vetorizada = var[2]

v = dividir_e_ordenar_por_contrato(entrada_vetorizada[1:7260]; funcao_ordenacao = Algoritmos_Ordenacao.quicksort)
v == entrada_vetorizada[1:7260]

@benchmark dividir_e_ordenar_por_periodo($entrada_vetorizada[1:7260]; funcao_ordenacao = $Algoritmos_Ordenacao.insertionsort)



function ordenar_empresa_individual(
    entrada_matricial::Array{Float64,3},
    empresa::Int64,
)::Vector{Tuple{Int64,Int64,Int64,Float64}}
    matriz = [
        entrada_matricial[empresa, :, x]
        for x in [size(entrada_matricial, 2):-1:1;]
    ]
    mes_final = size(entrada_matricial, 2)
    vetor_indices = map(x -> (1, x), [size(entrada_matricial, 2):-1:1;])
    saida = Vector{Tuple{Int64,Int64,Int64,Float64}}(
        undef,
        Int64(
            size(entrada_matricial, 2) * (size(entrada_matricial, 2) + 1) / 2,
        ),
    )

    @inbounds for j in [length(saida):-1:1;]
        contrato = (empresa, vetor_indices[1]..., popfirst!(matriz[1]))
        saida[j] = contrato
        #remove o valor máximo
        append!(matriz[1], Float64(-Inf))
        #aumenta o mês inicial da coluna que teve o valor copiado
        # if vetor_indices[end][1] < vetor_indices[end][2]
        vetor_indices[1] = vetor_indices[1] .+ (1, 0)
        # end


        max_heapify!(matriz, vetor_indices, 1, 120)

    end

    return saida
end






function ordenar_empresa_individual(
    entrada_matricial::Array{Float64,3},
    empresa::Int64,
)::Vector{Tuple{Int64,Int64,Int64,Float64}}
    matriz = [
        entrada_matricial[empresa, :, x]
        for x in [size(entrada_matricial, 2):-1:1;]
    ]
    mes_final = size(entrada_matricial, 2)
    vetor_indices = map(x -> (1, x), [size(entrada_matricial, 2):-1:1;])
    saida = Vector{Tuple{Int64,Int64,Int64,Float64}}(
        undef,
        Int64(
            size(entrada_matricial, 2) * (size(entrada_matricial, 2) + 1) / 2,
        ),
    )

    @inbounds for j in [length(saida):-1:1;]
        contrato = (empresa, vetor_indices[1]..., popfirst!(matriz[1]))
        saida[j] = contrato
        #remove o valor máximo
        append!(matriz[1], Float64(-Inf))
        #aumenta o mês inicial da coluna que teve o valor copiado
        # if vetor_indices[end][1] < vetor_indices[end][2]
        vetor_indices[1] = vetor_indices[1] .+ (1, 0)
        # end


        max_heapify!(matriz, vetor_indices, 1, 120)

    end

    return saida
end


@inline function troca_elementos!(
    vetor_entrada::Array{Tuple{Int64,Int64},1},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end
@inline function troca_elementos!(
    vetor_entrada::Array{Array{Float64,1},1},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end

function max_heapify!(
    vetor_entrada::Array{Array{Float64,1},1},
    vetor_indices::Array{Tuple{Int64,Int64},1},
    primeiro::Int64,
    ultimo::Int64,
)   #c = 2*363000-1 = 726599 e last = 726000 na primeira iteração. c referencia elemento de posição à direita do heap
    @inbounds while (c = 2 * primeiro - 1) < ultimo
        #se c for anterior a c e o valor do vetor na posição c for menor que o posterior
        if c < ultimo && vetor_entrada[c][1] < vetor_entrada[c+1][1]
            #aumenta c em 1 para referenciar a próxima posição, para indicar que o elemento
            c += 1
        end
        #first é 363000 na primeira iteração e c pode referenciar o último ou o penúltimo item, a depender do ultimo "if"
        if vetor_entrada[primeiro][1] < vetor_entrada[c][1]
            troca_elementos!(vetor_entrada, c, primeiro)
            troca_elementos!(vetor_indices, c, primeiro)
            primeiro = c
        else
            break
        end
    end
end


function Ordenar(
    entrada_matricial::Array{Float64,3},
)::Vector{Tuple{Int64,Int64,Int64,Float64}}
    m = size(entrada_matricial, 1)
    n = size(entrada_matricial, 2)
    n_contratos = Int64(n * (n + 1) / 2)

    elementos_heap = Vector{Vector{Tuple{Int64,Int64,Int64,Float64}}}(undef, m)


    elementos_heap =
        map(x -> ordenar_empresa_individual(entrada_matricial, x), 1:m)
    # for i = 1:m
    #     elementos_heap[i] = ordenar_empresa_individual(entrada_matricial, i)
    # end
    # num_elementos_heap(elementos_heap)::Int64 = sum(map(x::Array{Tuple{Int64,Int64,Int64,Float64},1}->length(x),elementos_heap).> Int64(0))
    return Intercalar_k_vetores(elementos_heap)
end


using BenchmarkTools
@btime Ordenar(entrada_matricial)

print(
    "Está ordenado? ",
    issorted(DataFrame(Ordenar(entrada_matricial))[!, 4]) ? "sim" : "não",
)

function Intercalar_k_vetores(
    vetores::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1},
)::Vector{Tuple{Int64,Int64,Int64,Float64}}
    m = length(vetores)
    tamanho_saida = m * length(vetores[1])
    build_min_heap!(vetores)
    saida = Vector{Tuple{Int64,Int64,Int64,Float64}}(undef, tamanho_saida)
    i = 1
    @inbounds for i = 1:length(saida)
        saida[i] = popfirst!(vetores)
        if length(vetores[1]) == 0
            vetores[1] = [(0, 0, 0, Float64(Inf64))]
            troca_elementos!(vetores, 1, m)
        end

        # println(length(elementos_heap))
        min_heapify!(vetores, 1, m)


    end

    return saida
end





@inbounds function troca_elementos!(
    vetor_entrada::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end


function min_heapify!(
    vetor_entrada::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1},
    primeiro::Int64,
    ultimo::Int64,
)
    @inbounds while (c = 2 * primeiro - 1) < ultimo
        #se c for anterior a c e o valor do vetor na posição c for menor que o posterior
        if c < ultimo && vetor_entrada[c] > vetor_entrada[c+1]
            #aumenta c em 1 para referenciar a próxima posição, para indicar que o elemento
            c += 1
        end
        #first é 363000 na primeira iteração e c pode referenciar o último ou o penúltimo item, a depender do ultimo "if"
        if vetor_entrada[primeiro] > vetor_entrada[c]
            troca_elementos!(vetor_entrada, c, primeiro)
            primeiro = c
        else
            break
        end
    end
end


function build_min_heap!(
    vetor_entrada::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1},
)


    f = length(vetor_entrada) ÷ 2
    @inbounds for i in [f:-1:1;]
        # while f >= 1
        min_heapify!(vetor_entrada, i, length(vetor_entrada))
        # f -= 1
    end
end




Base.isless(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] < y[4]
Base.:<(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] < y[4]
##maior que
Base.isgreater(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] > y[4];
Base.:>(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] > y[4]
##igualdade
Base.isequal(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] == y[4]
Base.isequal(x::Tuple{Int64,Int64,Int64,Float64}, y::Float64) = x[4] == y

Base.:!=(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] != y[4]
Base.iszero(t::Tuple{Int64,Int64,Int64,Float64}) = isequal(t[4], 0.0)

Base.copy(t1::Tuple{Int64,Int64,Int64,Float64}) = (t1[1], t1[2], t1[3], t1[4])
##
#Operação com vetor de tuplas
#menor que
Base.isless(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = length(x[1]) == 0 ? true : isless(x[1], y[1])
Base.:<(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = length(x[1]) == 0 ? true : isless(x[1], y[1])
#maiorque
Base.isgreater(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = length(x[1]) == 0 ? false : x[1] > y[1]
Base.:>(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = length(x[1]) == 0 ? false : x[1] > y[1]





#igualdade
# Base.isequal(x::Vector{Tuple{Int64,Int64,Int64,Float64}},  y::Vector{Tuple{Int64,Int64,Int64,Float64}}) = length(x[1])


# retirada de elementos de um min_heap
Base.popfirst!(x::Vector{Vector{Tuple{Int64,Int64,Int64,Float64}}}) =
    length(x[1]) > 0 ? popfirst!(x[1]) : (0, 0, 0, Float64(Inf64))
