local M = {}

---@type fun(table: table, prop: string | number, mock: any, test: function): any
-- Replaces a value in the {table} with a key {prop} by the {mock], and run the {test}.
-- Then restores an original value of the {table}, when the {test} is completed
-- (despite of errors), and returns thr result of the {test}.
M.use_mocked_table = function(table, prop, mock, test)
    local orig = table[prop]
    table[prop] = mock
    local ok, result = pcall(test)
    table[prop] = orig
    if ok then
        return result
    else
        error(result)
    end
end

---@type fun(module: string, prop: string | number, mock: any, test: function): any
-- Replace a value in the {module} with a key {prop} by the {mock}, and run the {test}.
-- Then unload {module}, when test is completed (despite errors in the {test}).
M.use_mocked_module = function(module, prop, mock, test)
    package.loaded[table] = nil
    local m = require(module)
    m[prop] = mock
    local ok, result = pcall(test)
    package.loaded[table] = nil
    if ok then
        return result
    else
        error(result)
    end
end

return M
