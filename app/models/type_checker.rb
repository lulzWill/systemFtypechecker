class TypeChecker
    #takes an object of class Term and an object of type Context as input.
    #TODO: put validations to ensure that 
    def checkType(term,context=Assumption::Context.new())
        if term.is_a? Term::TermVar then
            if context.type(term.instance_variable_get(:@name)) then
                context.type(term.instance_variable_get(:@name))
            else
                raise "Variable is not known: #{term.instance_variable_get(:@name)}"
            end
        elsif term.is_a? Term::Abs then
            Type::TypeApplication.new(term.instance_variable_get(:@type), checkType(term.instance_variable_get(:@term), context.addAssumption(Assumption::TermAssumption.new(term.instance_variable_get(:@name), term.instance_variable_get(:@type)))))
        
        elsif term.is_a? Term::App then
            typeOne = checkType(term.instance_variable_get(:@term1), context)
            typeTwo = checkType(term.instance_variable_get(:@term2), context)

            if (typeOne.is_a? Type::TypeApplication) && (typeOne.instance_variable_get(:@from).equals(typeTwo)) then
                typeOne.instance_variable_get(:@to)
            else
                raise "#{term.instance_variable_get(:@term2)}: #{typeTwo.to_s} is not applicable to #{term.instance_variable_get(:@term1)}: #{typeOne.to_s}"
            end
        elsif term.is_a? Term::TypeAbs then
            Type::TypeForAll.new(term.instance_variable_get(:@name), checkType(term.instance_variable_get(:@term), context.addAssumption(Assumption::TypeAssumption.new(term.instance_variable_get(:@name)))))
            
        elsif term.is_a? Term::TypeApp then
            checkedType = checkType(term.instance_variable_get(:@term), context)
            if checkedType.is_a? Type::TypeForAll then
                substitute(checkedType.instance_variable_get(:@name), term.instance_variable_get(:@type), checkedType.instance_variable_get(:@type))
            else
                raise "type: #{term.instance_variable_get(:@type).to_s} is not applicable to #{term}: #{checkedType.to_s}"
            end
        else
            raise "Input types are not in the correct format. Please use an object of class Term and an object of class Assumption::Context"
        end
    end
    
    def substitute(name, substitution, sub_arg)
        if sub_arg.is_a? Type::TypeVariable then
            if sub_arg.instance_variable_get(:@name) == name then
                return substitution
            else
                return sub_arg
            end
        elsif sub_arg.is_a? Type::TypeApplication then
            return Type::TypeApplication.new(substitute(name, substitution, sub_arg.instance_variable_get(:@from)), substitute(name, substitution, sub_arg.instance_variable_get(:@to)))
        elsif sub_arg.is_a? Type::TypeForAll then
            if sub_arg.instance_variable_get(:@name) != name then
                return Type::TypeForAll.new(sub_arg.instance_variable_get(:@name), substitute(name,substitution,sub_arg.instance_variable_get(:@type)))
            else
                return sub_arg
            end
        end
    end
    
    #generates the term : \x : (X -> X) . x    this should type to (X -> X) -> (X -> X)
    def simpleType
        term_x = Term::TermVar.new("x")
        type_X = Type::TypeVariable.new("X")
        type_XappX = Type::TypeApplication.new(type_X, type_X)
        termAbs = Term::Abs.new("x",type_XappX,term_x)
    end
    
    #generates this term: \-/X.(X -> X) -> (X -> X)
    def genNat
        typeX = Type::TypeVariable.new("X")
        app1 = Type::TypeApplication.new(typeX,typeX)
        app2 = Type::TypeApplication.new(app1,app1)
        nat = Type::TypeForAll.new("X",app2)
    end
    
    #generates 0 : \X: *.\s : (X -> X) . \z : X . z this will type to nat : \-/X.(X -> X) -> (X -> X)
    def genZero
        type_X = Type::TypeVariable.new("X")
        type_XX = Type::TypeApplication.new(type_X, type_X)
        term_z = Term::TermVar.new("z")
        abs_z = Term::Abs.new("z",type_X,term_z)
        abs_s = Term::Abs.new("s",type_XX,abs_z)
        final_term = Term::TypeAbs.new("X",abs_s)
    end
    
    #generates S : \n : (\-/X.((X -> X) -> (X -> X))) . \X: *.\s : (X -> X) . \z : X . s n [X] s z    this should type to nat - > nat: (\-/X.(X -> X) -> (X -> X)) -> \-/X.(X -> X) -> (X -> X)
    def genS
        typeX = Type::TypeVariable.new("X")
        app1 = Type::TypeApplication.new(typeX,typeX)
        term_z = Term::TermVar.new("z")
        term_s = Term::TermVar.new("s")
        term_n = Term::TermVar.new("n")
        term_n_type_app = Term::TypeApp.new(term_n,typeX)
        szApp = Term::App.new(term_n_type_app,term_s)
        nszApp = Term::App.new(szApp,term_z)
        snszApp = Term::App.new(term_s,nszApp)
        zAbs = Term::Abs.new("z",typeX,snszApp)
        sAbs = Term::Abs.new("s",app1,zAbs)
        zsTypeAbs = Term::TypeAbs.new("X",sAbs)
        nAbs = Term::Abs.new("n", genNat,zsTypeAbs)
    end
    
    #generates the plus function : \n : (\-/X.((X -> X) -> (X -> X))) . \m : (\-/X.((X -> X) -> (X -> X))) . n [(\-/X.((X -> X) -> (X -> X)))] \n : (\-/X.((X -> X) -> (X -> X))) . \X: *.\s : (X -> X) . \z : X . s n [X] s z m
    #this should type to (nat -> nat) -> nat : ((\-/X.(X -> X) -> (X -> X)) -> (\-/X.(X -> X) -> (X -> X))) -> \-/X.(X -> X) -> (X -> X)
    def genPlus
        term_m = Term::TermVar.new("m")
        term_n = Term::TermVar.new("n") 

        nTypeApp = Term::TypeApp.new(term_n,genNat)
        smApp = Term::App.new(nTypeApp,genS)
                
        nTypeToSMApp = Term::App.new(smApp,term_m)
        mAbs = Term::Abs.new("m",genNat,nTypeToSMApp)
        nAbs = Term::Abs.new("n",genNat,mAbs)
    end
    
    #generates the term : \y : (X -> X) . x    this term will fail to type as x is unknown
    def failingTermVariableIsNotKnown
        term_x = Term::TermVar.new("x")
        type_X = Type::TypeVariable.new("X")
        type_XappX = Type::TypeApplication.new(type_X, type_X)
        termAbs = Term::Abs.new("y",type_XappX,term_x)
    end
    
    #generates the term : \z : (X -> X) . \x : X . x z     this term cannot be typed since z with type (X -> X) is not applicable to x with type X
    def failingTermApplicationsDontAssign
        term_x = Term::TermVar.new("x")
        term_z = Term::TermVar.new("z")
        term_x_z_app = Term::App.new(term_x, term_z)
        type_X = Type::TypeVariable.new("X")
        type_XappX = Type::TypeApplication.new(type_X, type_X)
        term_abs_x = Term::Abs.new("x",type_X,term_x_z_app)
        term_abs_z = Term::Abs.new("z",type_XappX,term_abs_x)
    end
end