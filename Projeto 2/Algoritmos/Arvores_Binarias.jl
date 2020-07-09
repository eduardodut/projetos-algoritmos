module Arvores_Binarias

include("Algoritmos_Ordenacao.jl")
export ordenar

# Base.iszero(t::Tuple{Int64,Int64,Int64,Float64}) = iszero(t[4])
# Base.isless(
#     t1::Tuple{Int64,Int64,Int64,Float64},
#     t2::Tuple{Int64,Int64,Int64,Float64},
# ) = isless(t1[4], t2[4])
# Base.isless(t1::Tuple{Int64,Int64,Int64,Float64}, t2::Float64) =
#     isless(t1[4], t2[4])
# Base.copy(t1::Tuple{Int64,Int64,Int64,Float64}) = (t1[1], t1[2], t1[3], t1[4])
# using DataFrames, BenchmarkTools, Juno


mutable struct Heap_Max_1D
    vetor_valores::Array{Tuple{Int64,Int64,Int64,Float64}}
    raiz::Tuple{Int64,Int64,Int64,Float64}
    function Heap_Max_1D(vetor::Array{Tuple{Int64,Int64,Int64,Float64}})
        Algoritmos_Ordenacao.build_max_heap!(vetor)
        new(vetor, vetor[1])
    end
end


function retira_raiz!(heap::Heap_Max_1D)::Tuple{Int64,Int64,Int64,Float64}
    #monta a saida da função com o indice do contrato e o valor do contrato
    saida = heap.vetor_valores[1]
    heap.vetor_valores[1] = (0, 0, 0, Float64(-Inf))
    # Algoritmos_Ordenacao.troca_elementos!(
    #     heap.vetor_valores,
    #     1,
    #     length(heap.vetor_valores),
    # )
    Algoritmos_Ordenacao.max_heapify!(
        heap.vetor_valores,
        1,
        length(heap.vetor_valores),
    )
    heap.raiz = heap.vetor_valores[1]
    return saida
end

mutable struct Heap_Max_2D
    vetor_arvores::Vector{Heap_Max_1D}
    raiz::Heap_Max_1D
    function Heap_Max_2D(matriz::Array{Tuple{Int64,Int64,Int64,Float64},3})
        vetor_arvores = Vector{Heap_Max_1D}(undef, size(matriz, 2))
        tamanho_diag = size(matriz, 2)
        indice_vetor_arvores = [1:1:tamanho_diag;]
        tamanho_diag = size(matriz, 2)
        @inbounds for periodo in [tamanho_diag:-1:1;]# mn² operações
            tamanho_vetor = size(matriz, 1) * (tamanho_diag - periodo + 1)
            # println(tamanho_vetor)
            contratos_do_periodo =
                Vector{Tuple{Int64,Int64,Int64,Float64}}(undef, tamanho_vetor)
            index = [1:1:length(contratos_do_periodo);]
            indice_inicial = 1
            indice_final = size(matriz, 1)
            @inbounds for (mes_i, mes_f) in
                          zip(1:tamanho_diag, periodo:tamanho_diag)# loop crescente de 1 a 120 vezes
                # println(length(matriz[:,mes_i,mes_f]))
                contratos_do_periodo[indice_inicial:indice_final] =
                    matriz[:, mes_i, mes_f]
                # println(indice_inicial, " ", indice_final)
                indice_inicial = indice_final + 1
                indice_final = indice_final + size(matriz, 1)
            end#loop na diagonal de todas as matrizes
            vetor_arvores[popfirst!(indice_vetor_arvores)] =
                Heap_Max_1D(contratos_do_periodo)
        end#loop de período de contratos
        new(vetor_arvores, vetor_arvores[1])
    end
end





function retira_raiz!(
    heap_Max_2D::Heap_Max_2D,
)::Tuple{Int64,Int64,Int64,Float64}
    saida = retira_raiz!(heap_Max_2D.vetor_arvores[1])
    max_heapify!(
        heap_Max_2D.vetor_arvores,
        1,
        length(heap_Max_2D.vetor_arvores),
    )

    return saida
end



function max_heapify!(
    vetor_entrada::Array{Heap_Max_1D,1},
    pai::Int64,
    tam_heap::Int64,
)
    maior = pai
    filho_esquerda = 2 * pai
    filho_direita = 2 * pai + 1
    # println(vetor_entrada[filho_esquerda].raiz[4])

    if filho_esquerda <= tam_heap &&
       vetor_entrada[filho_esquerda].raiz[4] > vetor_entrada[pai].raiz[4]

        maior = filho_esquerda

    end

    if filho_direita <= tam_heap &&
       vetor_entrada[filho_direita].raiz[4] > vetor_entrada[maior].raiz[4]
        maior = filho_direita
    end

    if maior != pai
        troca_elementos!(vetor_entrada, pai, maior)#maior = 2 * i ou  2 * i + 1
        max_heapify!(vetor_entrada, maior, tam_heap)
    end
end

@inline function troca_elementos!(
    vetor_entrada::Array{Heap_Max_1D},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end


function ordenar(
    entrada_matricial::Array{Tuple{Int64,Int64,Int64,Float64},3},
)::Array{Tuple{Int64,Int64,Int64,Float64}}
    arvore2d = Heap_Max_2D(entrada_matricial)
    saida = Array{Tuple{Int64,Int64,Int64,Float64}}(undef, 726000)

    for i in [length(saida):-1:1;]
        saida[i] = retira_raiz!(arvore2d)
    end
    return saida
end

end
