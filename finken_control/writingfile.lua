local writingfile = {}

local filename = "TextFile.txt"

function writingfile.init(self)

    function self.WriteFile()
        -- Opens a file in read
        file = io.open(filename, "w")
        file:write("Name,Age,Sex,Occupation")
        file:close()
    end

    function self.ReadFile()
        file = io.open(filename, "r")
        file:seek("end",-100)
        simAddStatusbarMessage(file:read("*a"))
        file:close()
    end

    function self.AppendFile()
        file = io.open(filename, "a")
        file:write("\nTom,22,M,Student")
        file:close()
    end


    simAddStatusbarMessage("Writingfile self call")
    return self
end
return writingfile