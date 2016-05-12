class Type
    def equals(compare)
        if compare.is_a? Type
            equalInContext(compare)
        else
            false
        end
    end

    class TypeVariable < Type
        #must take a string as input
        def initialize(name)
            @name = name
        end
        
        #takes in a type and a context. here, 
        def equalInContext(type,context={})
            if type.is_a? Type::TypeVariable then
                if context[@name] then
                    type.instance_variable_get(:@name) == context[@name]
                else
                    type.instance_variable_get(:@name) == @name
                end
            else
                false
            end
        end
        
        def to_s
            @name
        end
    end
    
    class TypeApplication < Type
        #must take two types as input
        def initialize(from,to)
            @from = from
            @to = to
        end
        
        #takes in a type and a context. here, 
        def equalInContext(type,context={})
            if type.is_a? Type::TypeApplication then
                @from.equalInContext(type.instance_variable_get(:@from), context) && @to.equalInContext(type.instance_variable_get(:@to), context)
            else
                false
            end
        end
        
        def to_s
            "(#{@from} -> #{@to})"
        end
    end
    
    class TypeForAll < Type
        #must take string and type as input
        def initialize(name,type)
            @name = name
            @type = type
        end
        
        #takes in a type and a context. here, 
        def equalInContext(type,context={})
            if type.is_a? Type::TypeForAll then
                context[@name] = type.instance_variable_get(:@name)
                @type.equalInContext(type.instance_variable_get(:@type), context)
            else
                false
            end
        end
        
        def to_s
            "(\\-/#{@name}.#{@type})"
        end
    end
end