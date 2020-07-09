using DataFrames, BenchmarkTools, Juno
include("Inicializacao.jl")

var = Inicializacao.inicializar_variaveis("Dados/entrada.txt")
const entrada_matricial = var[1]



teste_ordenacao(vetor::Vector{Tuple{Int64,Int64,Int64,Float64}})::Bool =
    issorted(DataFrame(vetor)[!, 4]) ? true : false

function Base.popfirst!(
    vetor_contratos::Vector{Tuple{Int64,Int64,Int64,Float64}},
)::Tuple{Int64,Int64,Int64,Float64}

    saida = vetor_contratos[1]
    vetor_contratos[1] = (0, 0, 0, Float64(-Inf))
    troca_elementos!(vetor_contratos, 1, length(vetor_contratos))
    max_heapify!(vetor_contratos, 1, length(vetor_contratos))
    # pop!(vetor_contratos)
    return saida
end

function intercalar_heap_max(
    heap_periodos::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1},
)::Vector{Tuple{Int64,Int64,Int64,Float64}}
    saida = Vector{Tuple{Int64,Int64,Int64,Float64}}(undef, 726000)

    for i in [726000:-1:1;] # mn²
        saida[i] = popfirst!(heap_periodos[1])
        max_heapify!(heap_periodos, 1, 120)
    end
    return saida
end

@benchmark ordenar($entrada_matricial)


@benchmark ordenado = ordenar($entrada_matricial)
teste_ordenacao(ordenar(entrada_matricial))

ordenar(
    entrada_matricial::Array{Float64,3},
)::Vector{Tuple{Int64,Int64,Int64,Float64}} = build_max_heap(entrada_matricial) |> intercalar_heap_max
    # (intercalar_heap_max ∘ build_max_heap)(entrada_matricial)


function build_max_heap(
    dados::Array{Float64,3},
)::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1}
    tamanho_diag = size(dados, 2)
    max_heap =
        Vector{Array{Tuple{Int64,Int64,Int64,Float64},1}}(undef, tamanho_diag)
    @inbounds for periodo in [120:-1:1;]# mn² operações
        contratos_do_periodo = Vector{Tuple{Int64,Int64,Int64,Float64}}(
            undef,
            size(dados, 1) * (tamanho_diag - periodo + 1),
        )
        index = [1:1:length(contratos_do_periodo);]
        @inbounds for emp = 1:size(dados, 1)
            @inbounds for (mes_i, mes_f) in
                          zip(1:tamanho_diag, periodo:tamanho_diag)# loop crescente de 1 a 120 vezes
                contrato = (emp, mes_i, mes_f, dados[emp, mes_i, mes_f])
                contratos_do_periodo[popfirst!(index)] = contrato
            end
        end
        build_max_heap!(contratos_do_periodo)
        max_heap[tamanho_diag-periodo+1] = contratos_do_periodo
    end
    return max_heap
end



function build_max_heap2(
    dados::Array{Float64,3},
)::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1}
    tamanho_diag = size(dados, 2)
    max_heap =
        Vector{Array{Tuple{Int64,Int64,Int64,Float64},1}}(undef, tamanho_diag)

    for i in [120:-1:1;]
        for j in [100:-1:1;]
        contratos_do_periodo =
end
    end


    @inbounds for periodo in [120:-1:1;]# mn² operações
        contratos_do_periodo = Vector{Tuple{Int64,Int64,Int64,Float64}}(
            undef,
            size(dados, 1) * (tamanho_diag - periodo + 1),
        )
        index = [1:1:length(contratos_do_periodo);]
        @inbounds for emp = 1:size(dados, 1)
            @inbounds for (mes_i, mes_f) in
                          zip(1:tamanho_diag, periodo:tamanho_diag)# loop crescente de 1 a 120 vezes
                contrato = (emp, mes_i, mes_f, dados[emp, mes_i, mes_f])
                contratos_do_periodo[popfirst!(index)] = contrato
            end
        end
        build_max_heap!(contratos_do_periodo)
        max_heap[tamanho_diag-periodo+1] = contratos_do_periodo
    end
    return max_heap
end









function build_max_heap!(vetor_entrada::Vector{Tuple{Int64,Int64,Int64,Float64}})
    f = length(vetor_entrada) ÷ 2
    @inbounds for i in [f:-1:1;]
        # while f >= 1
        max_heapify!(vetor_entrada, i, length(vetor_entrada))
        # f -= 1
    end
end

function max_heapify!(vetor_entrada::Vector, primeiro::Int64, ultimo::Int64)
    @inbounds while (c = 2 * primeiro - 1) < ultimo
        if c < ultimo && vetor_entrada[c] < vetor_entrada[c+1]
            c += 1
        end
        if vetor_entrada[primeiro] < vetor_entrada[c]
            troca_elementos!(vetor_entrada, c, primeiro)
            primeiro = c
        else
            break
        end
    end
end





@inline function troca_elementos!(vetor_entrada, i::Int64, j::Int64)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end


### --- Definição de operações com tuplas de 4 elementos Tuple{Int64,Int64,Int64,Float64}
#### menor que
Base.isless(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] < y[4]
Base.:<(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] < y[4]
#### maior que
Base.isgreater(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] > y[4]
Base.:>(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] > y[4]
#### igualdade
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


### Operação com vetor de tuplas
#### menor que
Base.isless(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = isless(x[1], y[1])
Base.:<(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = isless(x[1], y[1])
#### maiorque
Base.isgreater(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = x[1] > y[1]
Base.:>(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = x[1] > y[1]

Tuple{Int64,Int64,Int64,Float64}(0, 0, 0, 300.0) <
Tuple{Int64,Int64,Int64,Float64}(300, 300, 300, 3000.0)
