module Arvores_Binarias


export Arvore_Binaria_3D, Arvore_Binaria_2D, proximo_item!

Base.iszero(t::Tuple{Int64,Int64,Int64,Float64}) = iszero(t[4])
Base.isless(
    t1::Tuple{Int64,Int64,Int64,Float64},
    t2::Tuple{Int64,Int64,Int64,Float64},
) = isless(t1[4], t2[4])
Base.isless(t1::Tuple{Int64,Int64,Int64,Float64}, t2::Float64) =
    isless(t1[4], t2[4])
Base.copy(t1::Tuple{Int64,Int64,Int64,Float64}) = (t1[1], t1[2], t1[3], t1[4])
using DataFrames, BenchmarkTools, Juno


mutable struct Arvore_Binaria
    vetor_valores::Array{Float64}
    qtd_elementos::Int64
    mes_final::Int64#fixo
    mes_inicial::Int64#guardará o mes inicial da raiz atual
    raiz::Float64
    function Arvore_Binaria(coluna::Vector{Float64})
        v = filter(!iszero, coluna)
        new(v, length(v), length(v), 1, v[1])
    end
end


function retira_raiz!(arvore::Arvore_Binaria)::Tuple{Int64,Int64,Float64}
    #monta a saida da função com o indice do contrato e o valor do contrato
    saida = (arvore.mes_inicial, arvore.mes_final, arvore.raiz)
    if arvore.qtd_elementos > 0
        # substitui o topo por zero
        arvore.vetor_valores[1] = 0.0
        #filtra o vetor dos zero do topo

        filter!(!iszero, arvore.vetor_valores)
    end

    if length(arvore.vetor_valores) > 0
        arvore.raiz = arvore.vetor_valores[1]
        arvore.mes_inicial += 1
    else
        arvore.raiz = 0.0
    end

    arvore.qtd_elementos > 0.0 ? arvore.qtd_elementos -= 1 : 0.0
    return saida
end


mutable struct Arvore_Binaria_2D
    vetor_arvores::Vector{Arvore_Binaria}
    empresa::Int64
    qtd_elementos::Int64 #quantidade de árvores com elementos
    qtd_contratos::Int64
    raiz::Arvore_Binaria
    prox_valor::Float64
    function Arvore_Binaria_2D(matriz::Array{Float64,2}, empresa)
        vetor = Vector{Arvore_Binaria}(undef, size(matriz)[1])
        # for i in [size(matriz)[1]:-1:1;]
        j = size(matriz)[1]
        for i in [1:1:size(matriz)[1];]
            vetor[j] = Arvore_Binaria(matriz[:, i])
            j -= 1
        end
        valor = vetor[1].raiz

        qtd_contratos = Int64(size(matriz)[1] * (size(matriz)[1] + 1) / 2)
        new(vetor, empresa, size(matriz)[1], qtd_contratos, vetor[1], valor)
    end
end

function retira_raiz!(
    arvore::Arvore_Binaria_2D,
)::Tuple{Int64,Int64,Int64,Float64}
    #monta a saida da função com o indice do contrato e o valor do contrato

    saida = (arvore.empresa, retira_raiz!(arvore.vetor_arvores[1])...)
    if arvore.raiz.qtd_elementos == 0 && arvore.qtd_elementos > 0
        arvore.qtd_elementos -= 1
    end

    for i = 1:length(arvore.vetor_arvores)-1
        if arvore.vetor_arvores[i].raiz < arvore.vetor_arvores[i+1].raiz
            troca_elementos!(arvore.vetor_arvores, i, i + 1)
        else
            break
        end
    end

    arvore.raiz = arvore.vetor_arvores[1]
    arvore.prox_valor = arvore.vetor_arvores[1].raiz
    if arvore.qtd_contratos > 0
        arvore.qtd_contratos -= 1
    end
    return saida
end


function troca_elementos!(
    vetor_entrada::Vector{Arvore_Binaria},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end

#
# @benchmark retira_raiz!(arvore_2D)
# arvore_2D = Arvore_Binaria_2D(entrada_matricial[1,:,:],1)
# saida = Vector{Tuple{Int64, Int64, Int64, Float64}}(undef, 7260)
# arvore_3D = Arvore_Binaria_3D(entrada_matricial)
# @time begin
#
# for arvore_2D in arvore_3D.vetor_arvores_2D
#     # arvore_2D = Arvore_Binaria_2D(entrada_matricial[j,:,:],j)
#     for i in [7260:-1:1;]
#         saida[i] = retira_raiz!(arvore_2D)
#         # println(i, "", saida[i])
#     end
#     issorted(DataFrame(saida)[!, 4]) ? println("até agora todas ordenadas") : println("Empresa ", j," não ordenada")
#
#     end
# end

mutable struct Arvore_Binaria_3D
    vetor_arvores_2D::Vector{Arvore_Binaria_2D}
    # arvore_raiz::Arvore_Binaria_2D
    # contrato_raiz::Tuple{Int64, Int64, Int64, Float64}
    qtd_elementos::Int64
    qtd_contratos::Int64
    possui_valores::Bool
    raiz::Arvore_Binaria_2D
    function Arvore_Binaria_3D(matriz::Array{Float64,3})
        vetor = separa_empresas(matriz)
        build_max_heap!(vetor)
        # valor_raiz = (vetor[1].empresa,vetor[1].raiz.mes_inicial,vetor[1].raiz.mes_final,vetor[1].prox_valor)
        qtd_contratos =
            Int64(length(vetor) * size(matriz)[2] * (size(matriz)[2] + 1) / 2)
        #quantidade de árvores com elementos

        new(vetor, length(vetor), qtd_contratos, true, vetor[1])
    end

    function separa_empresas(
        matriz::Array{Float64,3},
    )::Vector{Arvore_Binaria_2D}
        vetor = Vector{Arvore_Binaria_2D}(undef, size(matriz)[1])
        for i in [1:1:size(matriz)[1];]
            vetor[i] = Arvore_Binaria_2D(matriz[i, :, :], i)
        end
        return vetor
    end
end

function build_max_heap!(vetor_entrada::Vector{Arvore_Binaria_2D})

    f = length(vetor_entrada) ÷ 2
    @inbounds for i in [f:-1:1;]
        # while f >= 1
        max_heapify!(vetor_entrada, i, length(vetor_entrada))
        # f -= 1
    end
end

function max_heapify!(
    vetor_entrada::Vector{Arvore_Binaria_2D},
    primeiro::Int64,
    ultimo::Int64,
)
    while (c = 2 * primeiro - 1) < ultimo
        #se c for anterior a c e o valor do vetor na posição c for menor que o posterior
        if c < ultimo &&
           vetor_entrada[c].prox_valor < vetor_entrada[c+1].prox_valor
            #aumenta c em 1 para referenciar a próxima posição, para indicar que o elemento
            c += 1
        end
        #first é 363000 na primeira iteração e c pode referenciar o último ou o penúltimo item, a depender do ultimo "if"
        if vetor_entrada[primeiro].prox_valor < vetor_entrada[c].prox_valor
            troca_elementos!(vetor_entrada, c, primeiro)
            primeiro = c
        else
            break
        end
    end
end
function troca_elementos!(
    vetor_entrada::Vector{Arvore_Binaria_2D},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end
function remove_elemento!(arvore::Arvore_Binaria_3D)
    if arvore.qtd_elementos > 0
        arvore.qtd_elementos -= 1
    end

end

function proximo_item!(
    arvore::Arvore_Binaria_3D,
)::Tuple{Int64,Int64,Int64,Float64}
    #monta a saida da função com o indice do contrato e o valor do contrato
    saida = retira_raiz!(arvore.raiz) # arrumação das árvores filhas
    qtd_elementos_raiz_atual = arvore.raiz.qtd_contratos

    if arvore.qtd_contratos > 0
        arvore.qtd_contratos -= 1
    end
    if arvore.qtd_contratos == 0
        arvore.possui_valores = false
    end

    max_heapify!(arvore.vetor_arvores_2D, 1, arvore.qtd_elementos)

    arvore.raiz = arvore.vetor_arvores_2D[1]
    return saida

end#
include("Inicializacao.jl")
var = Inicializacao.inicializar_variaveis("Dados/entrada.txt")
entrada_matricial = var[1]
@time begin
    arvore_3D = Arvore_Binaria_3D(entrada_matricial)
end
# # retira_raiz!(arvore_3D)
# arvore_3D = Arvore_Binaria_3D(entrada_matricial)
#
# saida = Vector{Tuple{Int64, Int64, Int64, Float64}}(undef, 726000)
# for i in [726000:-1:1;]
#     saida[i] = retira_raiz!(arvore_3D)
# end
#
# arvore_3D = Arvore_Binaria_3D(entrada_matricial)
# #
# # println(" ","Ordenado? ", issorted(DataFrame(saida)[!, 4]) ? "sim" : "não")
#
# @benchmark ordenar($entrada_matricial)
# saida_func = ordenar(entrada_matricial)
#
#
#
# println(" ","Ordenado? ", issorted(DataFrame(saida_func)[!, 4]) ? "sim" : "não")





# function find_amax(vec::Vector{Matriz_Contratos})::Int64
#     m = length(vec)
#     arr = Array{Tuple{Int64,Int64,Int64,Float64},1}(undef, m)
#     for empresa = 1:m
#         arr[empresa] = vec[empresa].elemento_max
#     end
#     maxind, maxval = firstindex(arr), first(arr)
#     for (i, x) in enumerate(arr)
#         if x > maxval
#             maxind, maxval = i, x
#         end
#     end
#     return maxind
# end
end
