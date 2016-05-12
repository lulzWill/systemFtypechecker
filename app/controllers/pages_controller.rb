class PagesController < ApplicationController
    def show
    end
    
    def check
        @term = params[:term][:term]
        @term.gsub!(/\s+/,"")
        
        t = TypeChecker.new
        
        begin
            @type = t.checkType(generateTerm(@term))
                
            if @type then
                flash[:notice] = "Term: " + params[:term][:term] + " can be typed as: " + @type.to_s
            else
                flash[:notice] = "Term: " + params[:term][:term] + " cannot be typed or there was an error in the formatting of the term"
            end
            redirect_to :back
        rescue
            flash[:notice] = "Term: " + params[:term][:term] + " cannot be typed or there was an error in the formatting of the term"
            redirect_to :back
        end
    end
    
    def generateTerm(term)
        puts term
        if term.length == 1 then
            return Term::TermVar.new(term)
        elsif term[0] == "\\" && term[2] == ":" then
            if(term[3] != "A") then
                type = term[/[:].*?[.]/][1,term.length].chomp(".")
                innerTerm = term[/[.].*/][1,term.length]
            else
                type = term[/[:][A].[.].*?[.]/][1,term.length].chomp(".")
                indexOfSecondPeriod = 6
                while indexOfSecondPeriod < term.length
                    if(term[indexOfSecondPeriod] == ".") then
                        break
                    else
                        indexOfSecondPeriod = indexOfSecondPeriod + 1
                    end
                end
            
                innerTerm = term[indexOfSecondPeriod+1,term.length]
            end
            return Term::Abs.new(term[1],genType(type),generateTerm(innerTerm))
        elsif term[0] == "\\" then
            innerTerm = term[/[.].*/][1,term.length]
            return Term::TypeAbs.new(term[1],generateTerm(innerTerm))
        elsif term.match(/[\[].*[\]]\z/) then
            outerTerm = term[/.*[\[]/].chomp("[")
            innerType = term[/[\[].*[\]]/].chomp("]").gsub!("[","")
            return Term::TypeApp.new(generateTerm(outerTerm),genType(innerType))
        elsif term[0] == "(" then
            term1pos = 1
            openb = 1
            while term1pos < term.length do
                if term[term1pos] == "(" then
                    openb = openb + 1
                elsif term[term1pos] == ")" then
                    openb = openb - 1
                end

                if(openb == 0) then
                    term1pos = term1pos + 1
                    break
                else
                    term1pos = term1pos + 1
                end
            end
            term1 = term[0,term1pos]
            term2pos = term1pos + 1
            if term[term1pos] == "(" then
                openb = 1
                while term2pos < term.length do
                    if term[term2pos] == "(" then
                        openb = openb + 1
                    elsif term[term2pos] == ")" then
                        openb = openb - 1
                    end

                    if(openb == 0) then
                        term2pos = term2pos + 1
                        break
                    else
                        term2pos = term2pos + 1
                    end
                end
                term2 = term[term1pos,term2pos]
            else
                raise "Not an application, term is in invalid form"
            end
            return Term::App.new(generateTerm(term1[1,term1pos].chomp(")")), generateTerm(term2[1,term2.length].chomp(")")))
        end
    end
    
    def genType(type)
        if type.length == 1 then
            return Type::TypeVariable.new(type)
        elsif type[0] == "(" && type.match(/[-][>]/) then
            term1pos = 1
            openb = 1
            while term1pos < type.length do
                if type[term1pos] == "(" then
                    openb = openb + 1
                elsif type[term1pos] == ")" then
                    openb = openb - 1
                end

                if(openb == 0) then
                    term1pos = term1pos + 1
                    break
                else
                    term1pos = term1pos + 1
                end
            end
            term1 = type[0,term1pos]
            term2pos = term1pos + 2
            if type[term1pos+2] == "(" then
                openb = 1
                while term2pos < type.length do
                    if type[term2pos] == "(" then
                        openb = openb + 1
                    elsif type[term2pos] == ")" then
                        openb = openb - 1
                    end

                    if(openb == 0) then
                        term2pos = term2pos + 1
                        break
                    else
                        term2pos = term2pos + 1
                    end
                end
                term2 = type[term1pos+2,term2pos]
            else
                raise "Not an application, type is in invalid form"
            end
            
            return Type::TypeApplication.new(genType(term1[1,term1pos].chomp(")")),genType(term2[1,term2.length].chomp(")")))
        elsif type[0] == "A" then
            innerType = type[/[.].*/][1,type.length]
            return Type::TypeForAll.new(type[1],genType(innerType))
        end
    end
end