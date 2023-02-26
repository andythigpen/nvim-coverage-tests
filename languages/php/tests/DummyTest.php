<?php

namespace Tests\NvimCoverage\Php;

use NvimCoverage\Php\Dummy;
use PHPUnit\Framework\Attributes\CoversClass;
use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\TestCase;

#[CoversClass(Dummy::class)]
final class DummyTest extends TestCase
{
    private Dummy $dummy;

    protected function setUp(): void
    {
        $this->dummy = new Dummy();
    }

    #[Test]
    public function itTestSomething(): void
    {
        $this->assertEquals("1 < 2", $this->dummy->generateBranches(1, 2));
        $this->assertEquals("2 = 2", $this->dummy->generateBranches(2, 2));
        $this->assertEquals("3 > 2", $this->dummy->generateBranches(3, 2));
    }
}
