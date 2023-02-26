local signs = require("coverage.signs")

describe("languages.php", function()
    vim.api.nvim_set_current_dir("languages/php/")

    local php_coverage = function(bufname)
        local lines = {
            signs.new_covered(bufname, 9),
            signs.new_covered(bufname, 10),
            signs.new_covered(bufname, 11),
            signs.new_covered(bufname, 12),
            signs.new_covered(bufname, 13),
            signs.new_covered(bufname, 14),
            signs.new_uncovered(bufname, 16),
        }
        for _, sign in ipairs(lines) do
            sign["buffer"] = nil
        end
        return lines
    end

    it("places signs", function()
        vim.cmd("edit src/Dummy.php")

        local coverage = require("coverage")
        coverage.load(true)
        local config = require("coverage.config")

        vim.wait(1000)
        local bufname = vim.fn.bufname()
        local placed = vim.fn.sign_getplaced(bufname, { group = config.opts.sign_group })
        assert.equal(1, #placed)
        local placed_signs = placed[1].signs
        for _, sign in ipairs(placed_signs) do
            sign["id"] = nil
        end
        local expected = php_coverage(bufname)
        assert.are.same(#expected, #placed_signs)
        assert.are.same(expected[1], placed_signs[1])
        assert.are.same(expected[2], placed_signs[2])
        assert.are.same(expected[3], placed_signs[3])
        assert.are.same(expected[4], placed_signs[4])
        assert.are.same(expected[5], placed_signs[5])
        assert.are.same(expected[6], placed_signs[6])
    end)

    it("has not signs for interfaces", function()
        vim.cmd("edit src/DummyInterface.php")

        local coverage = require("coverage")
        coverage.load(true)
        local config = require("coverage.config")

        vim.wait(1000)
        local bufname = vim.fn.bufname()
        local placed = vim.fn.sign_getplaced(bufname, { group = config.opts.sign_group })
        assert.equal(1, #placed)
        local placed_signs = placed[1].signs
        local expected = php_coverage(bufname)
        assert.are.same(0, #placed_signs)
    end)
end)
