
module Ordenacao
using Juno

export insertionsort

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

        #comparação do elemento chave e reposicionamento dos elementos maiores

        while j > 0 && A[j][4] > chave[4]
            A[j+1] = A[j]
            j = j - 1
        end
        #posicionamento final da chave
        A[j+1] = chave

    end#fim da ordenação
    return A
end






















#---


#
#
# #--- mergesort
# function mergesort(arr::Vector)
#     if length(arr) ≤ 1 return arr end
#     mid = length(arr) ÷ 2
#     lpart = mergesort(arr[1:mid])
#     rpart = mergesort(arr[mid+1:end])
#     rst = similar(arr)
#     i = ri = li = 1
#    while li ≤ length(lpart) && ri ≤ length(rpart)
#         if lpart[li] ≤ rpart[ri]
#             rst[i] = lpart[li]
#             li += 1
#         else
#             rst[i] = rpart[ri]
#             ri += 1
#         end
#         i += 1
#     end
#     if li ≤ length(lpart)
#         copy!(rst, i, lpart, li)
#     else
#         copy!(rst, i, rpart, ri)
#     end
#     return rst
# end
#
# #
# # function mergesort(m)
# #    var list left, right, result
# #    if length(m) ≤ 1
# #        return m
# #    else
# #        var middle = length(m) / 2
# #        for each x in m up to middle - 1
# #            add x to left
# #        for each x in m at and after middle
# #            add x to right
# #        left = mergesort(left)
# #        right = mergesort(right)
# #        if last(left) ≤ first(right)
# #           append right to left
# #           return left
# #        result = merge(left, right)
# #        return result
# #
# # function merge(left,right)
# #    var list result
# #    while length(left) > 0 and length(right) > 0
# #        if first(left) ≤ first(right)
# #            append first(left) to result
# #            left = rest(left)
# #        else
# #            append first(right) to result
# #            right = rest(right)
# #    if length(left) > 0
# #        append rest(left) to result
# #    if length(right) > 0
# #        append rest(right) to result
# #    return result
#
# #--- Heapsort
# swapa(a, i, j) = begin a[i], a[j] = a[j], a[i] end
# ⇋
# function pd!(a, first, last)
#     while (c = 2 * first - 1) < last
#         if c < last && a[c] < a[c + 1]
#             c += 1
#         end
#         if a[first] < a[c]
#             swapa(a, c, first)
#             first = c
#         else
#             break
#         end
#     end
# end
#
# heapify!(a, n) = (f = div(n, 2); while f >= 1 pd!(a, f, n); f -= 1 end)
#
# heapsort!(a) = (n = length(a); heapify!(a, n); l = n; while l > 1 swapa(a, 1, l); l -= 1; pd!(a, 1, l) end; a)
#
# a = shuffle(collect(1:12))
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
# function quicksort!(A,i=1,j=length(A))
#     if j > i
#         pivot = A[rand(i:j)] # random element of A
#         left, right = i, j
#         while left <= right
#             while A[left] < pivot
#                 left += 1
#             end
#             while A[right] > pivot
#                 right -= 1
#             end
#             if left <= right
#                 A[left], A[right] = A[right], A[left]
#                 left += 1
#                 right -= 1
#             end
#         end
#         quicksort!(A,i,right)
#         quicksort!(A,left,j)
#     end
#     return A
# end
#
#
# # This is a simple quicksort algorithm, adapted from Wikipedia.
# #
# # function quicksort(array)
# #     less, equal, greater := three empty arrays
# #     if length(array) > 1
# #         pivot := select any element of array
# #         for each x in array
# #             if x < pivot then add x to less
# #             if x = pivot then add x to equal
# #             if x > pivot then add x to greater
# #         quicksort(less)
# #         quicksort(greater)
# #         array := concatenate(less, equal, greater)
# # A better quicksort algorithm works in place, by swapping elements within the array, to avoid the memory allocation of more arrays.
# #
# # function quicksort(array)
# #     if length(array) > 1
# #         pivot := select any element of array
# #         left := first index of array
# #         right := last index of array
# #         while left ≤ right
# #             while array[left] < pivot
# #                 left := left + 1
# #             while array[right] > pivot
# #                 right := right - 1
# #             if left ≤ right
# #                 swap array[left] with array[right]
# #                 left := left + 1
# #                 right := right - 1
# #         quicksort(array from first index to right)
# #         quicksort(array from left to last index)
#
#
end#module
