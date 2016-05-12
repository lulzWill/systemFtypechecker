class Term
    class TermVar < Term
        def initialize(name)
            @name = name
        end
        
        def to_s
            @name
        end
    end
    
    class Abs < Term
        def initialize(name,type,term)
            @name = name
            @type = type
            @term = term
        end
        
        def to_s
            "\\#{@name} : #{@type} . #{@term}"
        end
    end
    
    class App < Term
        def initialize(t1,t2)
            @term1 = t1
            @term2 = t2
        end
        
        def to_s
            "#{@term1} #{@term2}"
        end
    end
    
    class TypeAbs < Term
        def initialize(name,term)
            @name = name
            @term = term
        end
        
        def to_s
            "\\#{@name}: *.#{@term}"
        end
    end
    
    class TypeApp < Term
        def initialize(term,type)
            @term = term
            @type = type
        end
        
        def to_s
            "#{@term} [#{@type}]"
        end
    end
end