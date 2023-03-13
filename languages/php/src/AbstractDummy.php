<?php

namespace NvimCoverage\Php;

/**
 * Needed to generate a report with `<lines />` in order to make sure the parser handles it correctly
 */
abstract class AbstractDummy implements DummyInterface
{
    abstract public function generateBranches(int $a, int $b): string;
}
