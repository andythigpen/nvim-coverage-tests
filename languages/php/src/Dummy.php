<?php

namespace NvimCoverage\Php;

final class Dummy extends AbstractDummy implements DummyInterface
{
    public function generateBranches(int $a, int $b): string
    {
        if ($a < $b) {
            return "$a < $b";
        } elseif ($a === $b) {
            return "$a = $b";
        } elseif ($a >= $b && $a !== $b) {
            return "$a > $b";
        } else {
            return "never reach this";
        }
    }
}
