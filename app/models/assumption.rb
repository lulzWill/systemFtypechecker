class Assumption
    class TermAssumption < Assumption
        def initialize(name, type)
            @name = name
            @type = type
            @variable = Term::TermVar.new(@name)
        end
    end
    
    class TypeAssumption < Assumption
        def initialize(name)
            @name = name
            @variable = Type::TypeVariable.new(@name)
        end
    end
    
    class Context
        def initialize
            @assumptions = []
        end
        
        def addAssumption(assumption)
            @assumptions << assumption
            return self
        end
        
        def type(name)
            @assumptions.each do |assumption|
                if assumption.class == Assumption::TermAssumption && assumption.instance_variable_get(:@name) == name then
                    return assumption.instance_variable_get(:@type)
                end
            end
            return false
        end
    end
end