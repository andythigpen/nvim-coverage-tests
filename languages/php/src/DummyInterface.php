<?php

namespace NvimCoverage\Php;

/**
 * Needed to generate a report with `<classes />` in order to make sure the parser handles it correctly
 */
interface DummyInterface
{
    public function generateBranches(int $a, int $b): string;
}
