TestCompany = inherit(Company)

function TestCompany:constructor()
  outputDebug("TestCompany.constructor")
end

function TestCompany:destructor()
  outputDebug("TestCompany.destructor")
end
