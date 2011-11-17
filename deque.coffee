
joinBuffer = (buf) ->
    buflen = 0; (buflen += x.length for x in buf);
    joined = Buffer(buflen)
    pos = 0
    for x in buf
        x.copy(joined, pos)
        pos += x.length
    return joined

exports.joinBuffer = joinBuffer

class DequeueNode
    constructor: (@data) ->
        @prev = @next = null

class Dequeue
    constructor: ->
        @head = new DequeueNode
        @tail = new DequeueNode
        @empty()
    
    empty: ->
        @head.next = @tail
        @tail.prev = @head
        @length = 0
    
    isEmpty: ->
        return @head.next == @tail

    push: (data) ->
        node = new DequeueNode(data)
        node.prev = @tail.prev
        node.prev.next = node
        node.next = @tail
        @tail.prev = node
        @length += 1
    
    pop: ->
        if @isEmpty()
            throw "pop() called on empty dequeue"
        else
            node = @tail.prev
            @tail.prev = node.prev
            node.prev.next = @tail
            @length -= 1
            return node.data
    
    unshift: (data) ->
        node = new DequeueNode(data)
        node.next = @head.next
        node.next.prev = node
        node.prev = @head
        @head.next = node
        @length += 1

    shift: ->
        if @isEmpty()
            throw "shift() called on empty dequeue"
        else
            node = @head.next
            @head.next = node.next
            node.next.prev = @head
            @length -= 1
            return node.data

Dequeue::merge_prefix = (size) ->
    if @length < 1
        return
    if (@length == 1) and (@head.next.data.length <= size)
        return
    
    prefix = []
    remaining = size
    while (@length) and (remaining > 0)
        chunk = @shift()
        if (chunk.length > remaining)
            @unshift( chunk.slice(remaining) )
            chunk = chunk.slice(0, remaining)
        prefix.push(chunk)
        remaining -= chunk.length
    if prefix
        joined = joinBuffer(prefix)
        @unshift(joined)
    if @length < 1
        @unshift( Buffer(0) )

exports.Dequeue = Dequeue

