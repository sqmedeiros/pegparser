local ast = require'ast'
local lfs = require'lfs'
local re = require 'relabel'
local ast = require 'ast'


local function isSource (file, ext)
	return string.sub(file, 1, 1) ~= '.' and string.sub(file, #file - #ext + 1) == ext
end


local function getText (file)
	local f = io.open(file)
	local s = f:read('a')
	f:close()
	return s
end


local function testFile (file, p)
	local s = getText(file)
	return p:match(s)
end


local function matchlabel (s1, s2)
	return string.match(string.lower(s1), string.lower(s2))
end


local function testYes (dir, ext, p)
	for file in lfs.dir(dir) do
		if isSource(file, ext) then 
			print("Yes: ", file)
			local r, lab, pos = testFile(dir .. file, p)
			local line, col = '', ''
			if not r then
				line, col = re.calcline(getText(dir .. file), pos)
			end
			assert(r ~= nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
		end
	end
end


local function testNo (dir, ext, p, strict, special)
	for file in lfs.dir(dir) do
		if isSource(file, ext) then
			print("No: ", file)
			local r, lab, pos = testFile(dir .. file, p)
			if lab ~= nil then
				io.write('r = ' .. tostring(r) .. ' lab = ' .. tostring(lab))
			end
			local line, col = '', ''
			if not r then
				line, col = re.calcline(getText(dir .. file), pos)
				io.write(' line: ' .. line .. ' col: ' .. col)
			end
			if strict then
				assert(r == nil and (matchlabel(file, lab) or matchlabel(file, special)), file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
			else
				assert(r == nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
			end
			io.write('\n')
		end
	end
end


local function testNoRec (dir, ext, p)
	local irec, ifail = 0, 0
	local tfail = {}

	for file in lfs.dir(dir) do
		if isSource(file, ext) then
			print("No: ", file)
			local r, lab, pos = testFile(dir .. file, p)
			if not r then
				local line, col = re.calcline(getText(dir .. file), pos)
				io.write('r = ' .. tostring(r) .. ' lab = ' .. tostring(lab))
				io.write(' line: ' .. line .. ' col: ' .. col)
				io.write('\n')
      	ifail = ifail + 1
				tfail[ifail] = { file = file, lab = lab, line = line, col = col }
			else
				irec = irec + 1
				if type(r) == 'table' then
					ast.printAST(r)
					io.write('\n')
				end
			end
		end
	end

	print('irec: ', irec, ' ifail: ', ifail)
	for i, v in ipairs(tfail) do
		print(v.file, v.lab, 'line: ', v.line, 'col: ', v.col)
	end
end


return {
	testYes = testYes,
	testNo = testNo,
	testNoRec = testNoRec,
	testFile = testFile,
}
