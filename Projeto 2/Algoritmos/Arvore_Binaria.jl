module Estrutura
mutable struct Arvore_Binaria
    vetor::Array{Tuple{Int64,Int64,Int64,Float64}}
    tamanho::Int64
    ponteiro_fim::Int64
    raiz::Tuple{Int64,Int64,Int64,Float64}
    Arvore_Binaria(vetor) = new(vetor, length(vetor), length(vetor), vetor[1])
end

function ceifar!(heap::Arvore_Binaria)
    if heap.ponteiro_fim == 0

        return (1, 1, 1, -Inf)
    else

        saida = (heap.raiz[1], heap.raiz[2], heap.raiz[3], heap.raiz[4])
        if heap.ponteiro_fim > 1
            troca_elementos!(heap.vetor, 1, heap.ponteiro_fim)
            max_heapify!(heap.vetor, 1, heap.ponteiro_fim)
        end

        heap.ponteiro_fim -= 1
        if heap.ponteiro_fim == 0
            heap.raiz = (1, 1, 1, -Inf)
        else
            heap.raiz = heap.vetor[1]
        end
    end

    return saida

end

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







end#module
