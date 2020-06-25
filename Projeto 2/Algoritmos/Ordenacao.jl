module Ordenacao

using Juno
using Base.Threads: nthreads, @spawn

export insertionsort, mergesort, heapsort, quicksort

#--- INSERTION SORT
function insertionsort(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    A = copy(vetor_entrada)

    return insertionsort!(A)
end

function insertionsort!(A::Array{Tuple{Int64,Int64,Int64,Float64}})

    @inbounds Juno.@progress for i = 2:length(A)
        #atribuição da chave de comparação
        chave = A[i]
        #
        j = i - 1

        #comparação do atributo valor ([4]) do elemento chave com os
        #valores de contrato dos elementos anteriores e
        #reposicionamento dos elementos com valores maiores

        while j > 0 && A[j][4] > chave[4]
            A[j+1] = A[j]
            j = j - 1
        end
        #posicionamento final da chave atual
        A[j+1] = chave

    end#fim da ordenação
    return A
end
#--- mergesort
function mergesort_por_empresa(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    m::Int64,
)

    resultado = similar(vetor_entrada)

    vetores_ordenados_por_empresa = similar(vetor_entrada)

    tamanho_array = length(vetor_entrada)
    m = 100
    tamanho_array = 726000

    vetor_indices = [1:1:tamanho_array;]

    n_colunas = Int(tamanho_array / m)

    matriz_indices = reshape(vetor_indices, n_colunas, m)
    matriz_indices[:, 100][1]
    # entrada_vetorial =
    # Array{Tuple{Int64,Int64,Int64,Float64}}(undef, length(linhas))


    @inbounds for i = 1:m
        vetores_ordenados_por_empresa[matriz_indices[:, i]] =
            mergesort(vetor_entrada[matriz_indices[:, i]])

    end

    return mergesort(vetores_ordenados_por_empresa)
    # vetor_indices = vec(ones(Int64, 1, m))
    #
    # lista_empresas = [1:1:m;]
    #
    #
    #
    # separa_contratos_ordenados_empresas(x::Int64) =
    #     vetores_ordenados_por_empresa[matriz_indices[:, x]]
    # empresas_ordenadas = map(separa_contratos_ordenados_empresas, [1:1:m;])
    #
    #
    #
    # busca_empresa_individual(i) = empresas_ordenadas[i][1][4]
    # i = 1
    # while length(lista_empresas) > 1
    #
    #
    #     lista_comparacao = map(busca_empresa_individual, lista_empresas)
    #
    #     valor_min, indice = findmin(lista_comparacao)
    #
    #     resultado[i] = empresas_ordenadas[indice][1]
    #
    #     popfirst!(empresas_ordenadas[indice])
    #
    #     if length(empresas_ordenadas) == 0
    #         delete!(lista_empresas, indice)
    #     end
    #
    #
    #
    #     i += 1
    # end
    #
    # resultado[i:end] = empresas_ordenadas[lista_empresas[1]][1:end]
    #
    # return resultado
end




function mergesort(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    A = copy(vetor_entrada)

    return mergesort!(A)
end

function mergesort!(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    # se o vetor de entrada tiver comprimento de 1, retorna ele mesmo
    if length(vetor_entrada) ≤ 1
        return vetor_entrada
    end
    #calcula o ponto médio do vetor de entrada para sua subdivisão

    p_medio = length(vetor_entrada) ÷ 2

    #chamada de recursão para o vetor da esquerda
    parte_esquerda = mergesort!(vetor_entrada[1:p_medio])
    #chamada de recursão para o vetor da direita
    parte_direita = mergesort!(vetor_entrada[p_medio+1:end])
    #formata o resultado para ser similar ao vetor de entrada
    return integrar(parte_esquerda, parte_direita)


end

function integrar(
    parte_esquerda::Array{Tuple{Int64,Int64,Int64,Float64}},
    parte_direita::Array{Tuple{Int64,Int64,Int64,Float64}},
)
    i = indice_direita = indice_esquerda = 1
    resultado = Array{Tuple{Int64,Int64,Int64,Float64}}(
        undef,
        length(parte_direita) + length(parte_esquerda),
    )
    #ordenação entre a parte esquerda e parte direita dos subvetores
    #enquanto não se chegar ao fim de cada vetor, continua comparando até ordenar
    #os elementos entre os subvetores

    while indice_esquerda ≤ length(parte_esquerda) &&
        indice_direita ≤ length(parte_direita)

        if parte_esquerda[indice_esquerda][4] ≤ parte_direita[indice_direita][4]
            # append!(resultado, parte_esquerda[indice_esquerda])
            resultado[i] = parte_esquerda[indice_esquerda]
            indice_esquerda += 1
        else
            # append!(resultado, parte_direita[indice_direita])
            resultado[i] = parte_direita[indice_direita]
            indice_direita += 1
        end
        i += 1
    end

    #Completa o vetor Resultado com o restante dos vetores da direita ou da esquerda
    #que não foram previamente inseridos.

    #caso o vetor da esquerda tenha sido completamente inserido,
    #o vetor da direita será integrado ao resultado
    if indice_esquerda > length(parte_esquerda)

        resultado[i:end] = parte_direita[indice_direita:end]

    else
        resultado[i:end] = parte_esquerda[indice_esquerda:end]
    end

    return resultado

end # function




#--- Heapsort

#função auxiliar para realizar a troca de posição entre dois elementos
function troca_elementos!(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end


function max_heapify!(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    first::Int64,
    last::Int64,
)   #c = 2*363000-1 = 726599 e last = 726000 na primeira iteração. c referencia elemento de posição à direita do heap
    @inbounds while (c = 2 * first - 1) < last
        #se c for anterior a c e o valor do vetor na posição c for menor que o posterior
        if c < last && vetor_entrada[c][4] < vetor_entrada[c+1][4]
            #aumenta c em 1 para referenciar a próxima posição, para indicar que o elemento
            c += 1
        end
        #first é 363000 na primeira iteração e c pode referenciar o último ou o penúltimo item, a depender do ultimo "if"
        if vetor_entrada[first][4] < vetor_entrada[c][4]
            troca_elementos!(vetor_entrada, c, first)
            first = c
        else
            break
        end
    end
end

function build_max_heap!(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    #726000÷2 = 363000
    f = length(vetor_entrada) ÷ 2
    @inbounds for i in [f:-1:1;]
        # while f >= 1
        max_heapify!(vetor_entrada, i, length(vetor_entrada))
        # f -= 1
    end
end

function heapsort!(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})


    #inicia a construção do primeiro heap max
    build_max_heap!(vetor_entrada)

    @inbounds for l in [length(vetor_entrada):-1:2;] #
        #troca a posição do primeiro nó com o último nó do heap
        troca_elementos!(vetor_entrada, 1, l)

        #reconstitui o heap após o swap do primeiro e ultimo nó pela linha anterior
        max_heapify!(vetor_entrada, 1, l - 1)
    end

    return vetor_entrada
end


function heapsort(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    A = copy(vetor_entrada)

    return heapsort!(A)
end
#
# parent_node(i::Int64) = i ÷ 2
#
# left(i::Int64) = 2i
#
# right(i::Int64) = 2i+1
#
#
# function max_heapfy(A,i)
#     l = left(i)
#     r = right(i)
#     if l <= length(A) && A[l][4] > A[i]
#         maior = l
#     else
#         maior = i
#
#
# end # function




#
# # Pseudocode:
#
# # function heapSort(a, count) is
# #    input: an unordered array a of length count
# #
# #    (first place a in max-heap order)
# #    heapify(a, count)
# #
# #    end := count - 1
# #    while end > 0 do
# #       (swap the root(maximum value) of the heap with the
# #        last element of the heap)
# #       swap(a[end], a[0])
# #       (decrement the size of the heap so that the previous
# #        max value will stay in its proper place)
# #       end := end - 1
# #       (put the heap back in max-heap order)
# #       siftDown(a, 0, end)
# #
# # function heapify(a,count) is
# #    (start is assigned the index in a of the last parent node)
# #    start := (count - 2) / 2
# #
# #    while start ≥ 0 do
# #       (sift down the node at index start to the proper place
# #        such that all nodes below the start index are in heap
# #        order)
# #       siftDown(a, start, count-1)
# #       start := start - 1
# #    (after sifting down the root all nodes/elements are in heap order)
# #
# # function siftDown(a, start, end) is
# #    (end represents the limit of how far down the heap to sift)
# #    root := start
# #
# #    while root * 2 + 1 ≤ end do       (While the root has at least one child)
# #       child := root * 2 + 1           (root*2+1 points to the left child)
# #       (If the child has a sibling and the child's value is less than its sibling's...)
# #       if child + 1 ≤ end and a[child] < a[child + 1] then
# #          child := child + 1           (... then point to the right child instead)
# #       if a[root] < a[child] then     (out of max-heap order)
# #          swap(a[root], a[child])
# #          root := child                (repeat to continue sifting down the child now)
# #       else
# #          return
#
# #--- Quicksort
#
function quicksort!(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    i::Int64,
    j::Int64,
)
    if j > i
        pivô = vetor_entrada[rand(i:j)] # elemento aleatório do vetor
        esquerda, direita = i, j
        while esquerda <= direita
            while vetor_entrada[esquerda][4] < pivô[4]
                esquerda += 1
            end
            while vetor_entrada[direita][4] > pivô[4]
                direita -= 1
            end
            if esquerda <= direita
                troca_elementos!(vetor_entrada, esquerda, direita)

                esquerda += 1
                direita -= 1
            end
        end
        quicksort!(vetor_entrada, i, direita)
        quicksort!(vetor_entrada, esquerda, j)
    end

    return vetor_entrada
end



function quicksort(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    A = copy(vetor_entrada)

    return quicksort!(A, 1, length(A))
end


end#module
